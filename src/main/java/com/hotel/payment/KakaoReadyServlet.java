package com.hotel.payment;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/kakaoReady")
public class KakaoReadyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String KAKAO_READY_URL = "https://open-api.kakaopay.com/online/v1/payment/ready";
    private static final String CID = "TC0ONETIME";
    private static final String SECRET_KEY = "DEVC377EA1FE352A2FD439A893097F76D602E5D1";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();
        String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + contextPath;
        String partnerOrderId = "hotel-" + System.currentTimeMillis();
        String partnerUserId = "hotel-user-001";

        String itemName = valueOrDefault(request.getParameter("itemName"), "호텔 예약금");
        int quantity = parseInt(request.getParameter("quantity"), 1);
        int totalAmount = parseInt(request.getParameter("totalAmount"), 50000);
        int taxFreeAmount = parseInt(request.getParameter("taxFreeAmount"), 0);
        int reservationId = parseInt(request.getParameter("reservationId"), 1);

        String json = "{"
                + "\"cid\":\"" + CID + "\","
                + "\"partner_order_id\":\"" + partnerOrderId + "\","
                + "\"partner_user_id\":\"" + partnerUserId + "\","
                + "\"item_name\":\"" + escapeJson(itemName) + "\","
                + "\"quantity\":" + quantity + ","
                + "\"total_amount\":" + totalAmount + ","
                + "\"tax_free_amount\":" + taxFreeAmount + ","
                + "\"approval_url\":\"" + baseUrl + "/kakaoApprove?orderId=" + urlEncode(partnerOrderId) + "\","
                + "\"cancel_url\":\"" + baseUrl + "/kakaoCancel.jsp\","
                + "\"fail_url\":\"" + baseUrl + "/kakaoFail.jsp\""
                + "}";

        HttpURLConnection connection = (HttpURLConnection) new URL(KAKAO_READY_URL).openConnection();
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

        String tid = extractJsonValue(responseBody, "tid");
        String redirectUrl = extractJsonValue(responseBody, "next_redirect_pc_url");
        if (redirectUrl == null || redirectUrl.isEmpty()) {
            redirectUrl = extractJsonValue(responseBody, "next_redirect_mobile_url");
        }

        HttpSession session = request.getSession();
        session.setAttribute("tid", tid);
        session.setAttribute("partnerOrderId", partnerOrderId);
        session.setAttribute("partnerUserId", partnerUserId);

        // 결제 승인 후 DB 저장용 값
        session.setAttribute("reservationId", reservationId); // 테스트용 예약번호
        session.setAttribute("amount", totalAmount);
        session.setAttribute("itemName", itemName);

        response.sendRedirect(redirectUrl);

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

    private static String extractJsonValue(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = json.indexOf(pattern);
        if (start < 0) {
            return null;
        }
        start += pattern.length();
        int end = json.indexOf("\"", start);
        if (end < 0) {
            return null;
        }
        return json.substring(start, end).replace("\\/", "/");
    }

    private static String valueOrDefault(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value;
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static String escapeJson(String value) {
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String urlEncode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
