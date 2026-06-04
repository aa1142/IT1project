package com.hotel.reservation;

import java.io.IOException;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/reservationCreate")
public class ReservationCreateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            ReservationDTO reservation = new ReservationDTO();

            String reservationCode = createReservationCode();
            reservation.setReservationCode(reservationCode);

            String guestName = valueOrDefault(request.getParameter("guestLastName"), "")
                    + valueOrDefault(request.getParameter("guestFirstName"), "");

            String bookerName = valueOrDefault(request.getParameter("bookerLastName"), "")
                    + valueOrDefault(request.getParameter("bookerFirstName"), "");

            reservation.setRoomId(parseInt(request.getParameter("roomId"), 1));
            reservation.setGuestName(guestName);
            reservation.setGuestPhone(request.getParameter("guestPhone"));
            reservation.setBookerName(bookerName);
            reservation.setBookerPhone(request.getParameter("bookerPhone"));
            reservation.setBookerEmail(request.getParameter("bookerEmail"));
            reservation.setCheckInDate(valueOrDefault(request.getParameter("checkInDate"), "2025-01-15"));
            reservation.setCheckOutDate(valueOrDefault(request.getParameter("checkOutDate"), "2025-01-17"));
            reservation.setPeopleCount(parseInt(request.getParameter("peopleCount"), 3));
            reservation.setTotalAmount(parseInt(request.getParameter("totalAmount"), 61600));
            reservation.setReservationStatus("PAYMENT_READY");

            ReservationDAO dao = new ReservationDAO();
            int reservationId = dao.insertReservation(reservation);

            HttpSession session = request.getSession();
            session.setAttribute("reservationId", reservationId);
            session.setAttribute("reservationCode", reservationCode);
            session.setAttribute("bookerEmail", reservation.getBookerEmail());
            session.setAttribute("bookerName", reservation.getBookerName());
            session.setAttribute("amount", reservation.getTotalAmount());

            request.setAttribute("itemName", valueOrDefault(request.getParameter("itemName"), "스탠다드 더블 예약금"));
            request.setAttribute("quantity", valueOrDefault(request.getParameter("quantity"), "1"));
            request.setAttribute("totalAmount", String.valueOf(reservation.getTotalAmount()));
            request.setAttribute("taxFreeAmount", valueOrDefault(request.getParameter("taxFreeAmount"), "0"));
            request.setAttribute("reservationId", reservationId);
            request.setAttribute("reservationCode", reservationCode);

            request.getRequestDispatcher("/res/reservation.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "예약 저장 오류: " + e.getMessage());
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
        }
    }

    private static String createReservationCode() {
        return "JYP-" + UUID.randomUUID().toString()
                .replace("-", "")
                .substring(0, 10)
                .toUpperCase();
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return defaultValue;
            }
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static String valueOrDefault(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value;
    }
}