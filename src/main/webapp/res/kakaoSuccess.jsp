<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="com.hotel.payment.PaymentDAO" %>
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
        alert("決済承認情報が失われました。");
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
            PaymentDAO payDao = new PaymentDAO();
            payDao.completeKakaoPayment(bootNo, tid, amount);
            System.out.println("[성공] PAYMENT 테이블 결제 완료 처리!");
        } catch (Exception e) {
            System.out.println("[오류] PAYMENT 테이블 적재 중 실패: " + e.getMessage());
            e.printStackTrace();
        }

        try {
            HotelDAO hotelDao = new HotelDAO();
            hotelDao.appendBootPaymentNote(bootNo, "|카카오페이완료(TID:" + tid + ")");
        } catch (Exception e) {
            e.printStackTrace();
        }

        // -----------------------------------------------------------
        // 결제 완료 메일 발송
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
        alert("カカオペイ決済承認に失敗しました。金額は引き落とされていません。");
        location.href = "<%= request.getContextPath() %>/res/BootSearch.jsp";
    </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>決済完了</title>
</head>
<body style="text-align: center; padding: 50px; font-family: sans-serif;">
    <div style="border: 1px solid #ddd; padding: 30px; display: inline-block; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
        <h1 style="color: #2bc366;">決済が完了しました</h1>
        <p>カカオペイ決済が正常に処理されました。</p>
        <p>ホテル管理者が客室を割り当てると予約が最終確定されます。</p>
        <p><strong>予約番号:</strong> <%= bootNo %></p>
        <p><strong>決済承認金額:</strong> ¥<%= String.format("%,d", amount) %></p>
        <a href="<%= request.getContextPath() %>/testex2/reservationcomplete.jsp?boot_no=<%= bootNo %>" style="display: inline-block; padding: 10px 20px; background: #111; color: #fff; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 16px;">予約受付内訳を見る</a>
        <a href="<%= request.getContextPath() %>/res/BootSearch.jsp" style="display: inline-block; padding: 10px 20px; background: #fee500; color: #000; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 20px;">予約照会へ移動</a>
    </div>
</body>
</html>