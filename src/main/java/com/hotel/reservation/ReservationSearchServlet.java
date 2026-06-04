//package com.hotel.reservation;
//
//import java.io.IOException;
//
//import javax.servlet.ServletException;
//import javax.servlet.annotation.WebServlet;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//
//@WebServlet("/reservationSearchOld")
//public class ReservationSearchServlet extends HttpServlet {
//    private static final long serialVersionUID = 1L;
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        request.setCharacterEncoding("UTF-8");
//
//        try {
//            String reservationNo = request.getParameter("reservationNo");
//            String bookerPhone = request.getParameter("bookerPhone");
//
//            if (reservationNo == null || reservationNo.trim().isEmpty()
//                    || bookerPhone == null || bookerPhone.trim().isEmpty()) {
//                request.setAttribute("errorMessage", "예약번호와 전화번호를 모두 입력해주세요.");
//                request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
//                return;
//            }
//
//            int reservationId = parseReservationNo(reservationNo);
//
//            ReservationDAO dao = new ReservationDAO();
//            ReservationDTO reservation = dao.findByReservationIdAndPhone(reservationId, bookerPhone.trim());
//
//            if (reservation == null) {
//                request.setAttribute("errorMessage", "예약 정보를 찾을 수 없습니다.");
//                request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
//                return;
//            }
//
//            request.setAttribute("reservation", reservation);
//            request.getRequestDispatcher("/reservationDetail.jsp").forward(request, response);
//
//        } catch (NumberFormatException e) {
//            request.setAttribute("errorMessage", "예약번호 형식이 올바르지 않습니다.");
//            request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
//        } catch (Exception e) {
//            e.printStackTrace();
//            request.setAttribute("errorMessage", "예약 조회 중 오류가 발생했습니다: " + e.getMessage());
//            request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
//        }
//    }
//
//    private int parseReservationNo(String reservationNo) {
//        String value = reservationNo.trim().toUpperCase();
//
//        if (value.startsWith("JYP-")) {
//            value = value.substring(4);
//        }
//
//        value = value.replaceFirst("^0+", "");
//        if (value.length() == 0) {
//            value = "0";
//        }
//
//        return Integer.parseInt(value);
//    }
//}
