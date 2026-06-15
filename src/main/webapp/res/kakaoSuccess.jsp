<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="com.hotel.payment.PaymentDAO" %>
<%@ page import="com.hotel.payment.PaymentDTO" %>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.jyphotel.HotelDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String pgToken = request.getParameter("pg_token");
    String tid = (String) session.getAttribute("tid");
    String bootNo = (String) session.getAttribute("bootNo");
    
    int amount = 0;
    if (session.getAttribute("amount") != null) {
        amount = (Integer) session.getAttribute("amount");
    }

    if (pgToken == null || tid == null || bootNo == null) {
%>
    <script>
        alert("결제 승인 정보가 유실되었습니다.");
        location.href = "<%= request.getContextPath() %>/res/BootSearch.jsp";
    </script>
<%
        return;
    }

    String cid = "TC0ONETIME"; 
    String partnerOrderId = bootNo;
    String partnerUserId = "JYP_HOTEL_GUEST";
    boolean isSuccess = false;

    try {
        URL url = new URL("https://open-api.kakaopay.com/online/v1/payment/approve");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Authorization", "SECRET_KEY DEVC377EA1FE352A2FD439A893097F76D602E5D1");
        conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        conn.setDoOutput(true);

        String jsonPayload = "{"
            + "\"cid\":\"" + cid + "\","
            + "\"tid\":\"" + tid + "\","
            + "\"partner_order_id\":\"" + partnerOrderId + "\","
            + "\"partner_user_id\":\"" + partnerUserId + "\","
            + "\"pg_token\":\"" + pgToken + "\""
            + "}";

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonPayload.getBytes("UTF-8");
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            isSuccess = true; 
        } else {
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "UTF-8"));
            String line;
            StringBuilder sb = new StringBuilder();
            while ((line = br.readLine()) != null) { sb.append(line); }
            br.close();
            System.out.println("[카카오 승인 실패 에러로그]: " + sb.toString());
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    if (isSuccess) {
        
        try {
            PaymentDTO payDto = new PaymentDTO();
            payDto.setBootNo(bootNo);               
            payDto.setTid(tid);                     
            payDto.setPartnerOrderId(bootNo);       
            payDto.setPaymentMethod("KAKAOPAY");    
            payDto.setAmount(amount);               
            payDto.setPaymentStatus("PAID");        
            
            PaymentDAO payDao = new PaymentDAO();
            payDao.insertPayment(payDto); 
            System.out.println("[성공] PAYMENT 테이블 영수증 적재 완료!");
        } catch (Exception e) {
            System.out.println("[오류] PAYMENT 테이블 적재 중 실패: " + e.getMessage());
            e.printStackTrace();
        }

        Connection dbConn = null;
        PreparedStatement pstmt = null;
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            dbConn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "SCOTT", "tiger");
            
            String sql = "UPDATE BOOT SET BOOT_CONFIRM = 1, BOOT_PLEASE = BOOT_PLEASE || ? WHERE BOOT_NO = ?";
            pstmt = dbConn.prepareStatement(sql);
            pstmt.setString(1, "|카카오페이완료(TID:" + tid + ")");
            pstmt.setString(2, bootNo);
            pstmt.executeUpdate();
            System.out.println("[성공] BOOT 테이블 예약 상태 완료(1) 변경 성공!");
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(pstmt != null) try{ pstmt.close(); }catch(Exception e){}
            if(dbConn != null) try{ dbConn.close(); }catch(Exception e){}
        }

        // -----------------------------------------------------------
        // 📧 [수정 완료] RESERVATION_CODE 컬럼 값을 예약번호 파라미터로 매핑
        // -----------------------------------------------------------
        try {
            HotelDAO hotelDao = new HotelDAO();
            BootVO vo = hotelDao.selectReservationReceipt(bootNo);
            
            if (vo != null) {
                com.hotel.mail.MailService mailService = new com.hotel.mail.MailService();
                // 맨 끝 파라미터 두 개에 전부 vo.getReservation_code()를 꽂아 RESERVATION_CODE로 발송되게 고정합니다.
                mailService.sendReservationCompleteMail(
                    vo.getBoot_email(), 
                    vo.getBoot_name(), 
                    vo.getReservation_code(), 
                    vo.getReservation_code(), 
                    amount
                );
                System.out.println("[메일로그] 카카오페이 결제완료 확인 메일 전송 완료!");
            }
        } catch (Exception e) {
            System.out.println("[메일오류] 결제완료 메일 발송 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        session.removeAttribute("tid");
    } else {
%>
    <script>
        alert("카카오페이 결제 승인에 실패했습니다. 돈이 출금되지 않았습니다.");
        location.href = "<%= request.getContextPath() %>/res/BootSearch.jsp";
    </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>결제 완료</title>
</head>
<body style="text-align: center; padding: 50px; font-family: sans-serif;">
    <div style="border: 1px solid #ddd; padding: 30px; display: inline-block; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
        <h1 style="color: #2bc366;">🎉 결제가 정상 완료되었습니다!</h1>
        <p>호텔 예약 및 결제 영수증 발행이 완료되었습니다.</p>
        <p>입력하신 메일 주소로 확정 내역서가 전송되었습니다.</p>
        <p><strong>예약 번호:</strong> <%= bootNo %></p>
        <p><strong>결제 승인금액:</strong> ₩<%= String.format("%,d", amount) %></p>
        <a href="<%= request.getContextPath() %>/res/BootSearch.jsp" style="display: inline-block; padding: 10px 20px; background: #fee500; color: #000; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 20px;">예약 조회하러 가기</a>
    </div>
</body>
</html>