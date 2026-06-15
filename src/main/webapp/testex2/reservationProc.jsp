<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    int room_type = HotelPriceUtil.toInt(request.getParameter("room_type"), 0);
    String room_grade = RoomTypeUtil.toDbGrade(request.getParameter("room_grade"));

    String boot_checkin = request.getParameter("boot_checkin");
    int nights = HotelPriceUtil.toInt(request.getParameter("nights"), 1);
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);
    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);
    String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

    String paymentMethod = request.getParameter("payment_method");
    if (paymentMethod == null) paymentMethod = "online";
    boolean isOnlinePay = "online".equalsIgnoreCase(paymentMethod);

    RoomVO room = dao.selectSingleRoomTypePriceInfo(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    if (room == null) {
%>
<script type="text/javascript">
    alert("예약 가능한 객실이 없습니다.");
    history.go(-1);
</script>
<%
        return;
    }

    int room_no = dao.assignEmptyRoomNumber(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    if (room_no <= 0) {
%>
<script type="text/javascript">
    alert("배정 가능한 객실이 없습니다.");
    history.go(-1);
</script>
<%
        return;
    }

    CompanyVO company = dao.selectBranchDetailByNo(company_no);
    String companyName = (company != null) ? company.getCompany_name() : "JYP HOTEL";

    String booker_last = request.getParameter("booker_last_name");
    String booker_first = request.getParameter("booker_first_name");
    if (booker_last == null) booker_last = "";
    if (booker_first == null) booker_first = "";

    String guest_last = request.getParameter("guest_last_name");
    String guest_first = request.getParameter("guest_first_name");
    if (guest_last == null) guest_last = "";
    if (guest_first == null) guest_first = "";

    String guest_phone = HotelPriceUtil.normalizeBootPhone(request.getParameter("guest_phone"));
    String boot_phone = HotelPriceUtil.normalizeBootPhone(request.getParameter("boot_phone"));
    if (!HotelPriceUtil.isValidBootPhone(boot_phone)) {
%>
<script type="text/javascript">
    alert("전화번호는 010-0000-0000 형식으로 입력해 주세요.");
    history.go(-1);
</script>
<%
        return;
    }
    String boot_email = request.getParameter("boot_email");
    if (boot_email == null) boot_email = "";

    String breakfast_yn = request.getParameter("breakfast_yn");
    if (breakfast_yn == null) breakfast_yn = "N";
    String fast_checkin_yn = request.getParameter("fast_checkin_yn");
    if (fast_checkin_yn == null) fast_checkin_yn = "N";

    boolean breakfast = "Y".equalsIgnoreCase(breakfast_yn);
    boolean fastCheckin = "Y".equalsIgnoreCase(fast_checkin_yn);

    int roomTotal = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, rooms, boot_adult, boot_child);
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
    vo.setRoom_no(room_no);
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

    if (isOnlinePay) {
        vo.setBoot_pay_check(HotelDAO.PAY_CHECK_ONLINE);
        vo.setBoot_confirm(HotelDAO.CONFIRM_PENDING);
    } else {
        vo.setBoot_pay_check(HotelDAO.PAY_CHECK_ONSITE);
        vo.setBoot_confirm(HotelDAO.CONFIRM_DONE);
    }

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId != null) {
        vo.setMember_id(sessionUserId);
    }

    boolean flag = dao.executeInsertReservation(vo);

    if (!flag) {
%>
<script type="text/javascript">
    alert("예약 저장에 실패했습니다. DB 연결과 boot 테이블을 확인해 주세요.");
    history.go(-1);
</script>
<%
        return;
    }

    if (isOnlinePay) {
        session.setAttribute("bootNo", vo.getBoot_no());
        session.setAttribute("bootEmail", vo.getBoot_email());
        session.setAttribute("bootName", vo.getBoot_name());
        session.setAttribute("reservationCode", vo.getReservation_code());
        session.setAttribute("amount", grandTotal);

        String itemName = companyName + " " + RoomTypeUtil.toUiGrade(room_grade) + " 예약금";

        request.setAttribute("bootNo", vo.getBoot_no());
        request.setAttribute("reservationCode", vo.getReservation_code());
        request.setAttribute("bootPayCheck", String.valueOf(grandTotal));
        request.setAttribute("bootName", vo.getBoot_name());
        request.setAttribute("bootEmail", vo.getBoot_email());
        request.setAttribute("itemName", itemName);
        request.setAttribute("quantity", "1");
        request.setAttribute("taxFreeAmount", "0");

        request.getRequestDispatcher("/res/boot.jsp").forward(request, response);
        return;
    }

    response.sendRedirect("reservationcomplete.jsp?boot_no=" + java.net.URLEncoder.encode(vo.getBoot_no(), "UTF-8"));
%>
