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

        try {
            HotelDAO hotelDao = new HotelDAO();
            BootVO vo = hotelDao.selectReservationReceipt(bootNo);
            
            if (vo != null) {
                com.hotel.mail.MailService mailService = new com.hotel.mail.MailService();
                mailService.sendReservationCompleteMail(
                    vo.getBoot_email(), 
                    vo.getBoot_name(), 
                    vo.getReservation_code(), 
                    vo.getReservation_code(), 
                    amount
                );
            }
        } catch (Exception e) {
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
    <title>決済完了 (BOOT)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/Boot.css?v=1.1">
</head>
<body>
<main class="receipt-container">
    
    <div class="receipt-header">
        <div class="pay-icon success">✔</div>
        <h2>決済が完了しました！</h2>
        <p class="notice">カカオペイ決済が正常に処理されました。<br>ホテル管理者が客室を割り当てると予約が最終確定されます。</p>
    </div>

    <div class="section-title">決済明細</div>
    <table class="info-table">
        <tr>
            <th>予約識別番号</th>
            <td><%= bootNo %></td> 
        </tr>
        <tr>
            <th>取引番号 (TID)</th>
            <td style="font-size: 11px; color: #a0aec0; word-break: break-all;"><%= tid %></td>
        </tr>
        <tr>
            <th>決済手段</th>
            <td>カカオペイ (KAKAOPAY)</td>
        </tr>
        <tr class="total-row">
            <th>総決済金額</th>
            <td class="highlight-price">
                ₩ <%= String.format("%,d", amount) %>
            </td>
        </tr>
    </table>

    <div class="btn-group" style="display: flex; flex-direction: column;">
        <a href="<%= request.getContextPath	() %>/testex2/reservationcomplete.jsp?boot_no=<%= bootNo %>" class="btn btn-primary">予約受付内訳を見る</a>
    </div>
</main>
</body>
</html>	