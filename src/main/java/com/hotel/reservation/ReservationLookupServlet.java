package com.hotel.reservation;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/reservationSearch")
public class ReservationLookupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String reservationNo = request.getParameter("reservationNo");
            String bookerKeyword = request.getParameter("bookerKeyword");

            if (reservationNo == null || reservationNo.trim().isEmpty()
                    || bookerKeyword == null || bookerKeyword.trim().isEmpty()) {
                request.setAttribute("errorMessage", "예약번호와 전화번호 또는 이메일을 모두 입력해주세요.");
                request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
                return;
            }

            String reservationCode = reservationNo.trim().toUpperCase();
            String keyword = bookerKeyword.trim();

            ReservationDAO dao = new ReservationDAO();
            ReservationDTO reservation =
                    dao.findByReservationCodeAndPhoneOrEmail(reservationCode, keyword);

            if (reservation == null) {
                request.setAttribute("errorMessage", "예약 정보를 찾을 수 없습니다.");
                request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
                return;
            }

            request.setAttribute("reservation", reservation);
            request.getRequestDispatcher("/reservationDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "예약 조회 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/reservationSearch.jsp").forward(request, response);
        }
    }
}