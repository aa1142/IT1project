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
import com.hotel.reservation.BootDAO; // ReservationDAO 대신 새 일꾼 임포트

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

        // 1. 카카오페이 인증 후 주소창으로 넘어오는 인증 토큰 낚아채기
        String pgToken = request.getParameter("pg_token");

        // 2. KakaoReadyServlet에서 킵해두었던 세션 바구니 정보들 일제히 인출
        HttpSession session = request.getSession();
        String tid = (String) session.getAttribute("tid");
        String partnerOrderId = (String) session.getAttribute("partnerOrderId");
        String partnerUserId = (String) session.getAttribute("partnerUserId");

        // BOOT 통합 규격에 맞추어 문자열 및 오브젝트 데이터 바인딩
        Object bootNoObj = session.getAttribute("bootNo"); // 기존 reservationId 대체
        Object amountObj = session.getAttribute("amount");
        Object reservationCodeObj = session.getAttribute("reservationCode");
        Object bookerEmailObj = session.getAttribute("bootEmail");
        Object bookerNameObj = session.getAttribute("bootName");

        // 3. 비정상적 진입 세션 유실 체크 방어벽
        if (pgToken == null || tid == null || partnerOrderId == null || partnerUserId == null) {
            request.setAttribute("errorMessage", "결제 승인 필수 정보(세션 데이터 등)가 유실되었습니다.");
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        if (bootNoObj == null) {
            request.setAttribute("errorMessage", "예약 식별 정보(bootNo)가 없습니다. 다시 진행해주세요.");
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        // 4. 안전하게 수집된 데이터를 변수로 매핑 (문자열 PK 체계 적용)
        String bootNo = String.valueOf(bootNoObj);
        int amount = parseInt(String.valueOf(amountObj), 50000);
        String reservationCode = reservationCodeObj == null ? "" : String.valueOf(reservationCodeObj);
        String bookerEmail = bookerEmailObj == null ? "" : String.valueOf(bookerEmailObj);
        String bookerName = bookerNameObj == null ? "고객" : String.valueOf(bookerNameObj);

        if (bootNo.trim().isEmpty() || "null".equalsIgnoreCase(bootNo)) {
            request.setAttribute("errorMessage", "예약 식별 코드가 올바르지 않습니다.");
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        // 5. 카카오 최종 승인 API용 JSON 통신 데이터 셋업
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

        // 카카오 서버 승인 실패 시 조기 예외 처리
        if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
            request.setAttribute("errorMessage", "카카오 최종 승인 실패: " + responseBody);
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        // 6. 카카오 최종 확인이 떨어졌으므로 PAYMENT 내역 가방 바인딩 및 DB INSERT
        PaymentDTO payment = new PaymentDTO();
        payment.setBootNo(bootNo); // 내부적으로 bootNo를 엮을 수 있게 변경 지원
        payment.setTid(tid);
        payment.setPartnerOrderId(partnerOrderId);
        payment.setPaymentMethod("KAKAOPAY");
        payment.setAmount(amount);
        payment.setPaymentStatus("PAID");

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            paymentDAO.insertPayment(payment);

            // [핵심 변경] 새 부트 DAO를 호출하고 상태값을 숫자 '1'(결제완료)로 업데이트
            BootDAO bootDAO = new BootDAO();
            bootDAO.updateReservationStatus(bootNo, 1);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "결제 내역 DB 영속화 실패: " + e.getMessage());
            request.getRequestDispatcher("/res/kakaoFail.jsp").forward(request, response);
            return;
        }

        // 7. 예약 확정 이메일 비동기 발송 파트
        try {
            MailService mailService = new MailService();
            mailService.sendReservationCompleteMail(
                    bookerEmail,
                    bookerName,
                    reservationCode,
                    partnerOrderId,
                    amount
            );
            session.setAttribute("mailStatus", "예약 확인 메일이 성공적으로 발송되었습니다.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("mailStatus", "메일 서버 오류로 발송은 누락되었으나 결제 및 예약은 정상 등록되었습니다.");
        }

        // 8. 사용 완료된 휘발성 세션 키값 정리 및 성공 화면 전달 데이터 바인딩
        session.removeAttribute("tid");
        session.removeAttribute("partnerUserId");

        session.setAttribute("partnerOrderId", partnerOrderId);
        session.setAttribute("bootNo", bootNo);
        session.setAttribute("reservationCode", reservationCode);
        session.setAttribute("amount", amount);

        // 결과 가시화 처리를 위한 성공 페이지로 리다이렉트
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