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
import javax.servlet.http.HttpSession;

import com.hotel.mail.MailService;
import com.hotel.reservation.ReservationDAO;

@WebServlet("/kakaoApprove")
public class KakaoApproveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String KAKAO_APPROVE_URL = "https://open-api.kakaopay.com/online/v1/payment/approve";
    private static final String CID = "TC0ONETIME";
    private static final String SECRET_KEY = "DEVC377EA1FE352A2FD439A893097F76D602E5D1";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String pgToken = request.getParameter("pg_token");

        HttpSession session = request.getSession();
        String tid = (String) session.getAttribute("tid");
        String partnerOrderId = (String) session.getAttribute("partnerOrderId");
        String partnerUserId = (String) session.getAttribute("partnerUserId");

        Object reservationIdObj = session.getAttribute("reservationId");
        Object amountObj = session.getAttribute("amount");
        Object reservationCodeObj = session.getAttribute("reservationCode");
        Object bookerEmailObj = session.getAttribute("bookerEmail");
        Object bookerNameObj = session.getAttribute("bookerName");

        if (pgToken == null || tid == null || partnerOrderId == null || partnerUserId == null) {
            request.setAttribute("errorMessage", "결제 승인 정보가 없습니다.");
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
            return;
        }

        if (reservationIdObj == null) {
            request.setAttribute("errorMessage", "예약번호 정보가 없습니다. 다시 예약을 진행해주세요.");
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
            return;
        }

        int reservationId = parseInt(String.valueOf(reservationIdObj), 0);
        int amount = parseInt(String.valueOf(amountObj), 50000);
        String reservationCode = reservationCodeObj == null ? "" : String.valueOf(reservationCodeObj);
        String bookerEmail = bookerEmailObj == null ? "" : String.valueOf(bookerEmailObj);
        String bookerName = bookerNameObj == null ? "고객" : String.valueOf(bookerNameObj);

        if (reservationId == 0) {
            request.setAttribute("errorMessage", "예약번호 정보가 올바르지 않습니다.");
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
            return;
        }

        String json = "{"
                + "\"cid\":\"" + CID + "\","
                + "\"tid\":\"" + tid + "\","
                + "\"partner_order_id\":\"" + partnerOrderId + "\","
                + "\"partner_user_id\":\"" + partnerUserId + "\","
                + "\"pg_token\":\"" + pgToken + "\""
                + "}";

        HttpURLConnection connection = (HttpURLConnection) new URL(KAKAO_APPROVE_URL).openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "SECRET_KEY " + SECRET_KEY);
        connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        connection.setDoOutput(true);

        try (OutputStream outputStream = connection.getOutputStream()) {
            outputStream.write(json.getBytes(StandardCharsets.UTF_8));
        }

        String responseBody = readBody(connection);

        if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
            request.setAttribute("errorMessage", responseBody);
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
            return;
        }

        PaymentDTO payment = new PaymentDTO();
        payment.setReservationId(reservationId);
        payment.setTid(tid);
        payment.setPartnerOrderId(partnerOrderId);
        payment.setPaymentMethod("KAKAOPAY");
        payment.setAmount(amount);
        payment.setPaymentStatus("PAID");

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            paymentDAO.insertPayment(payment);

            ReservationDAO reservationDAO = new ReservationDAO();
            reservationDAO.updateReservationStatus(reservationId, "PAID");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "DB 저장 오류: " + e.getMessage());
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
            return;
        }

        try {
            MailService mailService = new MailService();
            mailService.sendReservationCompleteMail(
                    bookerEmail,
                    bookerName,
                    reservationCode,
                    partnerOrderId,
                    amount
            );
            session.setAttribute("mailStatus", "예약 확인 메일이 발송되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("mailStatus", "메일 발송은 실패했지만 결제는 정상 완료되었습니다.");
        }

        session.removeAttribute("tid");
        session.removeAttribute("partnerUserId");

        session.setAttribute("partnerOrderId", partnerOrderId);
        session.setAttribute("reservationId", reservationId);
        session.setAttribute("reservationCode", reservationCode);
        session.setAttribute("amount", amount);

        response.sendRedirect(request.getContextPath() + "/kakaoSuccess.jsp");
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