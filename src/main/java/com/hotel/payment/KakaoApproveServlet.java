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
import com.jyphotel.HotelDAO;

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

        Object bootNoObj = session.getAttribute("bootNo"); 
        Object amountObj = session.getAttribute("amount");
        Object reservationCodeObj = session.getAttribute("reservationCode");
        Object bookerEmailObj = session.getAttribute("bootEmail");
        Object bookerNameObj = session.getAttribute("bootName");

        if (pgToken == null || tid == null || partnerOrderId == null || partnerUserId == null) {
            System.out.println("[검증 로그] 카카오 세션 필수 정보가 누락되어 실패 구역으로 튕깁니다.");
            request.setAttribute("errorMessage", "결제 승인 필수 정보가 유실되었습니다.");
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        String bootNo = String.valueOf(bootNoObj);
        int amount = parseInt(String.valueOf(amountObj), 50000);
        String reservationCode = reservationCodeObj == null ? "" : String.valueOf(reservationCodeObj);
        String bookerEmail = bookerEmailObj == null ? "" : String.valueOf(bookerEmailObj);
        String bookerName = bookerNameObj == null ? "고객" : String.valueOf(bookerNameObj);

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
            System.out.println("[검증 로그] 카카오 본사 승인 거절됨. 응답코드: " + connection.getResponseCode());
            request.setAttribute("errorMessage", "카카오 최종 승인 실패: " + responseBody);
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }
        System.out.println("[검증 로그] 카카오 승인 성공 완료! 이제 오라클 대상을 타격합니다.");
        System.out.println("[검증 로그] 던질 bootNo 값: [" + bootNo + "]");

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            paymentDAO.completeKakaoPayment(bootNo, tid, amount);
            System.out.println("[검증 로그] PAYMENT 결제 완료 처리");

            HotelDAO hotelDAO = new HotelDAO();
            hotelDAO.appendBootPaymentNote(bootNo, "|카카오페이완료(TID:" + tid + ")");
            System.out.println("[검증 로그] BOOT 예약 확정 완료");

        } catch (Exception e) {
            System.out.println("[💥 검증 로그 에러 발생] 오라클 타격 도중 자바 예외가 발생했습니다!");
            e.printStackTrace();
        }

        try {
            MailService mailService = new MailService();
            mailService.sendReservationCompleteMail(bookerEmail, bookerName, reservationCode, partnerOrderId, amount);
        } catch (Exception e) {
            System.out.println("[검증 로그] 메일 발송 예외 발생 (무시하고 계속 진행)");
        }

        session.setAttribute("partnerOrderId", partnerOrderId);
        session.setAttribute("bootNo", bootNo);
        session.setAttribute("reservationCode", reservationCode);
        session.setAttribute("amount", amount);

        response.sendRedirect(request.getContextPath() + "/res/kakaoSuccess.jsp");
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) { return defaultValue; }
            return Integer.parseInt(value);
        } catch (Exception e) { return defaultValue; }
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
        while ((line = reader.readLine()) != null) { body.append(line); }
        reader.close();
        return body.toString();
    }
}