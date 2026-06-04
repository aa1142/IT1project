package com.hotel.payment;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.hotel.reservation.ReservationDAO;

@WebServlet("/kakaoRefund")
public class KakaoRefundServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String KAKAO_CANCEL_URL = "https://open-api.kakaopay.com/online/v1/payment/cancel";
    private static final String CID = "TC0ONETIME";
    private static final String SECRET_KEY = "DEVC377EA1FE352A2FD439A893097F76D602E5D1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            int reservationId = parseInt(request.getParameter("reservationId"), 0);

            if (reservationId == 0) {
                request.setAttribute("errorMessage", "예약번호 정보가 올바르지 않습니다.");
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            PaymentDAO paymentDAO = new PaymentDAO();
            PaymentDTO payment = paymentDAO.findPaidPaymentByReservationId(reservationId);

            if (payment == null) {
                request.setAttribute("errorMessage", "환불 가능한 결제 내역을 찾을 수 없습니다.");
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            String json = "{"
                    + "\"cid\":\"" + CID + "\","
                    + "\"tid\":\"" + payment.getTid() + "\","
                    + "\"cancel_amount\":" + payment.getAmount() + ","
                    + "\"cancel_tax_free_amount\":0"
                    + "}";

            HttpURLConnection connection = (HttpURLConnection) new URL(KAKAO_CANCEL_URL).openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Authorization", "SECRET_KEY " + SECRET_KEY);
            connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            connection.setDoOutput(true);

            try (OutputStream outputStream = connection.getOutputStream()) {
                outputStream.write(json.getBytes(StandardCharsets.UTF_8));
            }

            String responseBody = readBody(connection);

            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                request.setAttribute("errorMessage", "카카오페이 환불 실패: " + responseBody);
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            paymentDAO.updatePaymentStatus(reservationId, "REFUNDED");

            ReservationDAO reservationDAO = new ReservationDAO();
            reservationDAO.updateReservationStatus(reservationId, "CANCEL");

            request.setAttribute("message", "환불이 완료되었습니다.");
            response.sendRedirect(request.getContextPath() + "/reservationSearch.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "환불 처리 중 오류가 발생했습니다: " + e.getMessage());
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
        }
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

    private static String readBody(HttpURLConnection connection) throws IOException {
        BufferedReader reader;

        if (connection.getResponseCode() >= 200 && connection.getResponseCode() < 300) {
            reader = new BufferedReader(new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8));
        } else {
            reader = new BufferedReader(new InputStreamReader(connection.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder body = new StringBuilder();
        String line;

        while ((line = reader.readLine()) != null) {
            body.append(line);
        }

        reader.close();
        return body.toString();
    }
}