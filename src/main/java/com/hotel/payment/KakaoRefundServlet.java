package com.hotel.payment;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.hotel.payment.PaymentDAO;
import com.hotel.payment.PaymentDTO;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/kakaoRefund")
public class KakaoRefundServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 1. BootDetail.jsp 가 히든으로 던져준 예약식별번호(bootNo) 수집
        String bootNo = request.getParameter("bootNo");

        if (bootNo == null || bootNo.trim().isEmpty()) {
            out.println("<script>alert('예약 번호가 유실되었습니다.'); history.go(-1);</style>");
            return;
        }

        try {
            // 2. 팀원의 PaymentDAO를 깨워서 PAYMENT 테이블에 저장된 영수증(TID, 금액) 긁어오기
            PaymentDAO payDao = new PaymentDAO();
            PaymentDTO payDto = payDao.findPaidPaymentByBootNo(bootNo.trim());

            if (payDto == null) {
                out.println("<script>alert('승인된 결제 내역(TID)을 찾을 수 없어 환불이 불가능합니다.'); history.go(-1);</script>");
                return;
            }

            // 팀원 가방에서 카카오 고유 거래번호와 결제됐던 진짜 금액 인출
            String tid = payDto.getTid();
            int cancelAmount = payDto.getAmount();

            // 3. 🚀 카카오페이 환불(Cancel) 오픈 API 타격 시작
            URL url = new URL("https://open-api.kakaopay.com/online/v1/payment/cancel");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            
            conn.setRequestMethod("POST");
            // 우리 프로젝트 전용 카카오페이 정품 어드민 시크릿 키 장착
            conn.setRequestProperty("Authorization", "SECRET_KEY DEVC377EA1FE352A2FD439A893097F76D602E5D1");
            conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            conn.setDoOutput(true);

            // 카카오 규격에 맞춘 환불 JSON 페이로드 구성
            String jsonPayload = "{"
                + "\"cid\":\"TC0ONETIME\","
                + "\"tid\":\"" + tid + "\","
                + "\"cancel_amount\":" + cancelAmount + ","
                + "\"cancel_tax_free_amount\":0"
                + "}";

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes("UTF-8");
                os.write(input, 0, input.length);
            }

            // 4. 카카오 서버 응답 코드 확인
            int responseCode = conn.getResponseCode();
            
            if (responseCode == 200) { // 🎉 카카오페이 실시간 돈 빼내기 성공!
                
                // ---------------------------------------------------------------
                // [A작업] 팀원 PAYMENT 테이블 상태 변경 (PAID -> REFUNDED)
                // ---------------------------------------------------------------
                payDao.updatePaymentStatus(bootNo, "REFUNDED");

                // ---------------------------------------------------------------
                // [B작업] 우리 BOOT 테이블 상태 변경 (BOOT_CONFIRM = 2 취소완료)
                // ---------------------------------------------------------------
                updateBootTableToCancel(bootNo);

                out.println("<script>alert('카카오페이 환불 및 예약 취소가 정상 완료되었습니다.'); location.href='" 
                            + request.getContextPath() + "/res/BootSearch.jsp';</script>");
            } else {
                // 카카오 서버가 환불 거절했을 때 에러 로그 파싱
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "UTF-8"));
                String line;
                StringBuilder sb = new StringBuilder();
                while ((line = br.readLine()) != null) { sb.append(line); }
                br.close();
                
                System.out.println("[카카오 환불 거절 로그]: " + sb.toString());
                out.println("<script>alert('카카오페이 API 환불 승인 거절되었습니다.\\n이미 환불되었거나 금액 오류입니다.'); history.go(-1);</script>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('환불 처리 중 서버 오류 발생: " + e.getMessage() + "'); history.go(-1);</script>");
        }
    }

    /**
     * 오라클 BOOT 테이블의 확정 상태값을 취소(2)로 쾅 박아버리는 동기화 메서드
     */
    private void updateBootTableToCancel(String bootNo) {
        String sql = "UPDATE BOOT SET BOOT_CONFIRM = 2, BOOT_PLEASE = BOOT_PLEASE || ? WHERE BOOT_NO = ?";
        try (Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "SCOTT", "tiger");
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, "|카카오환불완료");
            pstmt.setString(2, bootNo);
            pstmt.executeUpdate();
            System.out.println("[시스템 로그] BOOT 테이블 취소 상태(2) 업데이트 성공");
            
        } catch (Exception e) {
            System.out.println("[오류] BOOT 테이블 상태 업데이트 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
}