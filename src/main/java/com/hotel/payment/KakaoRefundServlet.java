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

import com.hotel.reservation.BootDAO; // [수정] 새 부트 DAO 임포트

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
            // 1. [수정] 파라미터를 숫자가 아닌 고유 문자열 PK인 bootNo로 수집
            String bootNo = request.getParameter("bootNo");

            if (bootNo == null || bootNo.trim().isEmpty()) {
                request.setAttribute("errorMessage", "예약 식별 번호(bootNo) 정보가 올바르지 않습니다.");
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            // 2. [수정] PaymentDAO에 bootNo(문자열)를 넘겨 환불 대상 영수증 낚아채기
            PaymentDAO paymentDAO = new PaymentDAO();
            PaymentDTO payment = paymentDAO.findPaidPaymentByBootNo(bootNo); 

            if (payment == null) {
                request.setAttribute("errorMessage", "환불 가능한 결제 내역을 찾을 수 없습니다.");
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            // 3. 카카오페이 환불(Cancel) API 통신용 JSON 데이터 구성
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

            // 카카오측 환불 거절 또는 통신 장애 시 차단
            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                request.setAttribute("errorMessage", "카카오페이 환불 실패: " + responseBody);
                request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
                return;
            }

            // 4. 카카오 환불 컨펌 확인 완료 후 우리 DB 정비 작업
            // [수정] PAYMENT 테이블의 결제 상태를 REFUNDED로 업데이트 (bootNo 기준)
            paymentDAO.updatePaymentStatus(bootNo, "REFUNDED");

            // [수정] BOOT 테이블의 예약 승인 코드를 '2'(취소/환불완료) 숫자로 리셋
            BootDAO bootDAO = new BootDAO();
            bootDAO.updateReservationStatus(bootNo, 2);

            request.setAttribute("message", "환불 및 예약 취소가 완전히 처리되었습니다.");
            
            // [수정] 최종 리다이렉트 파일명을 통합 선언된 bootSearch.jsp로 정비
            response.sendRedirect(request.getContextPath() + "/bootSearch.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "환불 처리 중 백엔드 내부 오류 발생: " + e.getMessage());
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
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