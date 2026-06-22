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
    private static final String SECRET_KEY = "api code";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 1. 기본 인프라 정보 수집
        String contextPath = request.getContextPath();
        String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + contextPath;
        String partnerUserId = "hotel-user-001"; // 가맹점 회원 아이디 기본값

        // 2. boot.jsp hidden 필드로부터 넘어온 신규 파라미터 수집
        String bootNo = request.getParameter("bootNo"); // 새 테이블의 고유 문자열 PK (B2026...)
        String reservationCode = request.getParameter("reservationCode"); // 통신용 ORD... 코드
        String itemName = valueOrDefault(request.getParameter("itemName"), "호텔 예약 객실");
        int quantity = parseInt(request.getParameter("quantity"), 1);
        int bootPayCheck = parseInt(request.getParameter("bootPayCheck"), 50000); // 바뀐 금액 변수
        int taxFreeAmount = parseInt(request.getParameter("taxFreeAmount"), 0);

        // 3. [개선] 카카오페이 주문 번호(partner_order_id)에 실제 DB 식별 번호인 bootNo를 직접 맵핑합니다.
        String partnerOrderId = bootNo; 

        // 4. 카카오페이 서버에 전송할 JSON 데이터 조립
        String json = "{"
                + "\"cid\":\"" + CID + "\","
                + "\"partner_order_id\":\"" + partnerOrderId + "\","
                + "\"partner_user_id\":\"" + partnerUserId + "\","
                + "\"item_name\":\"" + escapeJson(itemName) + "\","
                + "\"quantity\":" + quantity + ","
                + "\"total_amount\":" + bootPayCheck + ","
                + "\"tax_free_amount\":" + taxFreeAmount + ","
                + "\"approval_url\":\"" + baseUrl + "/kakaoApprove?orderId=" + urlEncode(partnerOrderId) + "\","
                + "\"cancel_url\":\"" + baseUrl + "/kakaoCancel\","
                + "\"fail_url\":\"" + baseUrl + "/kakaoFail\""
                + "}";

        // 5. HttpURLConnection 통신 시작
        HttpURLConnection connection = (HttpURLConnection) new URL(KAKAO_READY_URL).openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "SECRET_KEY " + SECRET_KEY);
        connection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        connection.setDoOutput(true);

        try (OutputStream outputStream = connection.getOutputStream()) {
            outputStream.write(json.getBytes(StandardCharsets.UTF_8));
        }

        String responseBody = readBody(connection);

        // 통신 오류 시 즉각 예외 처리 및 실패 페이지 포워딩
        if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
            request.setAttribute("errorMessage", "카카오 통신 오류: " + responseBody);
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        // 6. JSON 응답 결과에서 고유 거래 거래번호(tid)와 카카오 팝업창 URL 추출
        String tid = extractJsonValue(responseBody, "tid");
        String redirectUrl = extractJsonValue(responseBody, "next_redirect_pc_url");
        if (redirectUrl == null || redirectUrl.isEmpty()) {
            redirectUrl = extractJsonValue(responseBody, "next_redirect_mobile_url");
        }

        // 7. [중요] 카카오페이 승인(Approve) 및 DB 반영 시 참조할 수 있도록 세션 보관함에 킵(Keep)
        HttpSession session = request.getSession();
        session.setAttribute("tid", tid);
        session.setAttribute("partnerOrderId", partnerOrderId);
        session.setAttribute("partnerUserId", partnerUserId);
        session.setAttribute("bootNo", bootNo);                  // 새 고유 ID 저장
        session.setAttribute("amount", bootPayCheck);             // 금액 세션 보관
        session.setAttribute("itemName", itemName);
        session.setAttribute("reservationCode", reservationCode); 
       
        // 8. 브라우저를 카카오페이 결제창 비밀번호 입력 화면으로 강제 리다이렉트
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