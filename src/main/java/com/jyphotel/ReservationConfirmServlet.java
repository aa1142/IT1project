package com.jyphotel;

import com.jyphotel.ReservationDAO;
import com.jyphotel.ReservationVO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * =====================================================================
 * ReservationConfirmServlet.java  —  예약 확정 처리 서블릿
 * =====================================================================
 * hotelreservation.jsp 의 handleReserve() 에서 fetch POST 로 호출됩니다.
 *
 * [URL 매핑]
 *   /reservation/confirm
 *
 * [흐름]
 *   hotelreservation.jsp (폼 입력)
 *     → POST /reservation/confirm
 *     → ReservationConfirmServlet
 *     → ReservationDAO.insertReservation()
 *     → Oracle DB INSERT
 *     → reservationcomplete.jsp (예약 완료 페이지) 로 forward
 *
 * [hotelreservation.jsp 수정 필요 부분]
 *   handleReserve() 함수 내 setTimeout 을 아래 fetch 코드로 교체:
 *
 *   fetch('${pageContext.request.contextPath}/reservation/confirm', {
 *     method: 'POST',
 *     headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
 *     body: new URLSearchParams({
 *       guestLastName    : document.getElementById('guestLastName').value,
 *       guestFirstName   : document.getElementById('guestFirstName').value,
 *       guestPhone       : document.getElementById('guestPhone').value,
 *       bookerLastName   : document.getElementById('bookerLastName').value,
 *       bookerFirstName  : document.getElementById('bookerFirstName').value,
 *       bookerPhone      : document.getElementById('bookerPhone').value,
 *       bookerEmail      : document.getElementById('bookerEmail').value,
 *       postalCode       : document.getElementById('postalCode').value,
 *       address          : document.getElementById('address').value,
 *       breakfastYn      : state.selectedPlans.includes('breakfast')   ? 'Y' : 'N',
 *       fastCheckinYn    : state.selectedPlans.includes('fastCheckin') ? 'Y' : 'N',
 *       paymentMethod    : state.paymentMethod,
 *       // 서버에서 이미 받은 예약 기본 정보 그대로 재전송
 *       hotelName        : '${hotelName}',
 *       roomGrade        : '${roomGrade}',
 *       roomClass        : '${roomClass}',
 *       capacity         : '${capacity}',
 *       checkin          : '${checkin}',
 *       checkout         : '${checkout}',
 *       checkinLabel     : '${checkinLabel}',
 *       checkoutLabel    : '${checkoutLabel}',
 *       nights           : '${nights}',
 *       rooms            : '${rooms}',
 *       adults           : '${adults}',
 *       children         : '${children}',
 *       basePrice        : '${basePrice}',
 *       totalPrice       : '${totalPrice}'
 *     })
 *   })
 *   .then(res => res.json())
 *   .then(data => {
 *     if (data.success) {
 *       window.location.href = 'reservationcomplete.jsp?no=' + data.reservationNo;
 *     } else {
 *       alert('예약 처리 중 오류가 발생했습니다: ' + data.message);
 *       btn.disabled  = false;
 *       btn.innerHTML = '예약하기';
 *     }
 *   });
 * =====================================================================
 */
@WebServlet("/reservation/confirm")
public class ReservationConfirmServlet extends HttpServlet {

    private final ReservationDAO dao = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        /* ── 인코딩 설정 ── */
        req.setCharacterEncoding("UTF-8");
        res.setContentType("application/json; charset=UTF-8");

        /* ── VO 에 파라미터 채우기 ── */
        ReservationVO vo = new ReservationVO();

        // 호텔 / 객실 정보 (hotelreservation.jsp 에서 hidden 으로 재전송)
        vo.setHotelName     (req.getParameter("hotelName"));
        vo.setRoomGrade     (req.getParameter("roomGrade"));
        vo.setRoomClass     (req.getParameter("roomClass"));
        vo.setCapacity      (req.getParameter("capacity"));
        vo.setCheckin       (req.getParameter("checkin"));
        vo.setCheckout      (req.getParameter("checkout"));
        vo.setCheckinLabel  (req.getParameter("checkinLabel"));
        vo.setCheckoutLabel (req.getParameter("checkoutLabel"));

        vo.setNights    (parseIntSafe(req.getParameter("nights"),    1));
        vo.setRooms     (parseIntSafe(req.getParameter("rooms"),     1));
        vo.setAdults    (parseIntSafe(req.getParameter("adults"),    2));
        vo.setChildren  (parseIntSafe(req.getParameter("children"),  0));
        vo.setBasePrice (parseIntSafe(req.getParameter("basePrice"), 0));
        vo.setTotalPrice(parseIntSafe(req.getParameter("totalPrice"),0));

        // 숙박자 정보
        vo.setGuestLastName  (req.getParameter("guestLastName"));
        vo.setGuestFirstName (req.getParameter("guestFirstName"));
        vo.setGuestPhone     (req.getParameter("guestPhone"));

        // 예약자 정보
        vo.setBookerLastName  (req.getParameter("bookerLastName"));
        vo.setBookerFirstName (req.getParameter("bookerFirstName"));
        vo.setBookerPhone     (req.getParameter("bookerPhone"));
        vo.setBookerEmail     (req.getParameter("bookerEmail"));
        vo.setPostalCode      (req.getParameter("postalCode"));
        vo.setAddress         (req.getParameter("address"));

        // 추가 옵션
        String breakfastYn   = "Y".equals(req.getParameter("breakfastYn"))   ? "Y" : "N";
        String fastCheckinYn = "Y".equals(req.getParameter("fastCheckinYn")) ? "Y" : "N";
        vo.setBreakfastYn   (breakfastYn);
        vo.setFastCheckinYn (fastCheckinYn);

        // 조식 요금 계산: 총인원 × 25,000 × nights
        int totalGuests = vo.getAdults() + vo.getChildren();
        int breakfastPrice   = "Y".equals(breakfastYn)   ? totalGuests * 25000 * vo.getNights() : 0;
        int fastCheckinPrice = "Y".equals(fastCheckinYn) ? 10000 : 0;
        vo.setBreakfastPrice  (breakfastPrice);
        vo.setFastCheckinPrice(fastCheckinPrice);

        // 결제 방법
        vo.setPaymentMethod(req.getParameter("paymentMethod"));

        // 최종 금액 자동 계산
        vo.calcFinalPrice();

        /* ── DB INSERT ── */
        int reservationNo = dao.insertReservation(vo);

        /* ── JSON 응답 반환 ── */
        java.io.PrintWriter out = res.getWriter();
        if (reservationNo > 0) {
            out.print("{\"success\":true,\"reservationNo\":" + reservationNo + "}");
        } else {
            out.print("{\"success\":false,\"message\":\"DB 저장 실패\"}");
        }
        out.flush();
    }


    /* ── null·파싱 실패 방어 ── */
    private int parseIntSafe(String value, int defaultVal) {
        try {
            return (value != null && !value.isEmpty()) ? Integer.parseInt(value) : defaultVal;
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}