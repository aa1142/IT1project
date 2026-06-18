package com.jyphotel;

import com.hotel.payment.PaymentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * 예약 접수 — boot(대기) + payment 저장. 방 배정·확정은 관리자 처리.
 */
@WebServlet("/testex2/reservationProc")
public class ReservationProcServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HotelDAO dao = new HotelDAO();
        PaymentDAO payDao = new PaymentDAO();

        int company_no = HotelPriceUtil.toInt(req.getParameter("company_no"), 0);
        int room_type = HotelPriceUtil.toInt(req.getParameter("room_type"), 0);
        String room_grade = RoomTypeUtil.toDbGrade(req.getParameter("room_grade"));

        String boot_checkin = req.getParameter("boot_checkin");
        int nights = HotelPriceUtil.toInt(req.getParameter("nights"), 1);
        int boot_adult = HotelPriceUtil.toInt(req.getParameter("boot_adult"), 1);
        int boot_child = HotelPriceUtil.toInt(req.getParameter("boot_child"), 0);
        String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

        String paymentMethod = req.getParameter("payment_method");
        if (paymentMethod == null) {
            paymentMethod = "online";
        }
        boolean isOnlinePay = "online".equalsIgnoreCase(paymentMethod);

        RoomVO room = dao.selectSingleRoomTypePriceInfo(company_no, room_grade, room_type,
                boot_checkin, boot_checkout);
        if (room == null) {
            sendAlertBack(resp, "予約可能な客室がありません。（空室・グレード・人数をご確認ください）");
            return;
        }

        CompanyVO company = dao.selectBranchDetailByNo(company_no);
        String companyName = (company != null) ? company.getCompany_name() : "JYP HOTEL";

        String booker_last = nullToEmpty(req.getParameter("booker_last_name"));
        String booker_first = nullToEmpty(req.getParameter("booker_first_name"));
        String guest_last = nullToEmpty(req.getParameter("guest_last_name"));
        String guest_first = nullToEmpty(req.getParameter("guest_first_name"));

        String guest_phone = HotelPriceUtil.normalizeBootPhone(req.getParameter("guest_phone"));
        String boot_phone = HotelPriceUtil.normalizeBootPhone(req.getParameter("boot_phone"));
        if (!HotelPriceUtil.isValidBootPhone(boot_phone)) {
            sendAlertBack(resp, "電話番号は010-0000-0000形式で入力してください。");
            return;
        }

        String boot_email = nullToEmpty(req.getParameter("boot_email"));
        String breakfast_yn = nullToDefault(req.getParameter("breakfast_yn"), "N");
        String fast_checkin_yn = nullToDefault(req.getParameter("fast_checkin_yn"), "N");

        boolean breakfast = "Y".equalsIgnoreCase(breakfast_yn);
        boolean fastCheckin = "Y".equalsIgnoreCase(fast_checkin_yn);

        int roomTotal = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, boot_adult, boot_child);
        int breakfastTotal = breakfast ? HotelPriceUtil.calcBreakfastTotal(boot_adult, boot_child, nights) : 0;
        int fastCheckinTotal = fastCheckin ? HotelPriceUtil.FAST_CHECKIN_UNIT : 0;
        int grandTotal = roomTotal + breakfastTotal + fastCheckinTotal;

        String payTypeLabel = isOnlinePay ? "online" : "onsite";
        String boot_please = "숙박자:" + guest_last + guest_first
                + "|숙박자전화:" + guest_phone
                + "|조식:" + breakfast_yn
                + "|빠른체크인:" + fast_checkin_yn
                + "|객실요금:" + roomTotal
                + "|조식요금:" + breakfastTotal
                + "|빠른체크인요금:" + fastCheckinTotal
                + "|총요금:" + grandTotal
                + "|결제방식:" + payTypeLabel;

        BootVO vo = new BootVO();
        vo.setCompany_no(company_no);
        vo.setRoom_no(0);
        vo.setRoom_grade(room_grade);
        vo.setRoom_type(room_type);
        vo.setBoot_phone(boot_phone);
        vo.setBoot_name(booker_last + booker_first);
        vo.setBoot_email(boot_email);
        vo.setBoot_checkin(boot_checkin);
        vo.setBoot_checkout(boot_checkout);
        vo.setBoot_adult(boot_adult);
        vo.setBoot_child(boot_child);
        vo.setBoot_please(boot_please);
        vo.setBoot_pay_check(isOnlinePay ? HotelDAO.PAY_CHECK_ONLINE : HotelDAO.PAY_CHECK_ONSITE);
        vo.setBoot_confirm(HotelDAO.CONFIRM_PENDING);

        HttpSession session = req.getSession();
        String memberId = dao.resolveMemberIdForReservation((String) session.getAttribute("sessionUserId"));
        if (memberId != null) {
            vo.setMember_id(memberId);
        }

        if (!dao.executeInsertReservation(vo)) {
            String detail = dao.getLastDbError();
            String msg = "予約の保存に失敗しました。";
            if (detail != null && detail.contains("ORA-02291")) {
                msg = "予約の保存に失敗しました。会員・支店・客室グレードのデータをご確認ください。";
            }
            sendAlertBack(resp, msg);
            return;
        }

        try {
            if (isOnlinePay) {
                payDao.insertPendingPayment(vo.getBoot_no(), grandTotal, "KAKAOPAY");
            } else {
                payDao.insertOnsitePayment(vo.getBoot_no(), grandTotal);
            }
        } catch (Exception e) {
            System.err.println("[ReservationProcServlet] payment insert failed: " + e.getMessage());
            e.printStackTrace();
            sendAlertBack(resp, "決済情報の保存に失敗しました。管理者にお問い合わせください。");
            return;
        }

        if (isOnlinePay) {
            session.setAttribute("bootNo", vo.getBoot_no());
            session.setAttribute("bootEmail", vo.getBoot_email());
            session.setAttribute("bootName", vo.getBoot_name());
            session.setAttribute("reservationCode", vo.getReservation_code());
            session.setAttribute("amount", grandTotal);

            String itemName = companyName + " " + RoomTypeUtil.toUiGrade(room_grade)
                    + " " + RoomTypeUtil.getDisplayName(room_grade, room_type);

            req.setAttribute("bootNo", vo.getBoot_no());
            req.setAttribute("reservationCode", vo.getReservation_code());
            req.setAttribute("bootPayCheck", String.valueOf(grandTotal));
            req.setAttribute("bootName", vo.getBoot_name());
            req.setAttribute("bootEmail", vo.getBoot_email());
            req.setAttribute("itemName", itemName);
            req.setAttribute("quantity", "1");
            req.setAttribute("taxFreeAmount", "0");

            req.getRequestDispatcher("/res/boot.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/testex2/reservationcomplete.jsp?boot_no="
                + java.net.URLEncoder.encode(vo.getBoot_no(), "UTF-8"));
    }

    private static String nullToEmpty(String s) {
        return s == null ? "" : s;
    }

    private static String nullToDefault(String s, String def) {
        return s == null ? def : s;
    }

    private void sendAlertBack(HttpServletResponse resp, String message) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("<script type=\"text/javascript\">");
        out.println("alert(" + jsonString(message) + ");");
        out.println("history.go(-1);");
        out.println("</script>");
    }

    private String jsonString(String s) {
        if (s == null) {
            return "''";
        }
        return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "")
                .replace("\n", "\\n") + "'";
    }
}
