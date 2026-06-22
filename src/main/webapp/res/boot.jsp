<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.HotelDAO" %>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.hotel.payment.PaymentDAO" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");
    DecimalFormat nf = new DecimalFormat("#,###");

    // 1. 세션에서 단일 열쇠 인출
    String bootNo = (String) session.getAttribute("bootNo");

    if (bootNo == null || bootNo.trim().isEmpty()) {
%>
    <script>
        alert("予約情報の有効期限が切れているか、無効なアクセスです。");
        location.href = "<%= request.getContextPath() %>/testex2/hotelsearch.jsp";
    </script>
<%
        return; 
    }

    // 2. 오라클 BOOT 테이블 장부 조회 (예약자명, 고유코드 확보)
    HotelDAO dao = new HotelDAO();
    BootVO vo = dao.selectReservationReceipt(bootNo);
    
    if (vo == null) {
%>
    <script>
        alert("DBから予約情報を照会できません。");
        location.href = "<%= request.getContextPath() %>/testex2/hotelsearch.jsp";
    </script>
<%
        return;
    }

    // 3. 요금 산출 로직
    int roomTotal = 0;
    if (vo != null) {
        if (session.getAttribute("amount") != null) {
            roomTotal = (Integer) session.getAttribute("amount");
        }
    }

    if (roomTotal == 0) {
        roomTotal = 150000; 
    }

    String reservationCode = vo.getReservation_code();
    String bootName = vo.getBoot_name();
    String itemName = vo.getRoom_grade();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ホテル予約決済 (BOOT)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/Boot.css?v=1.1">

</head>
<body>
<main class="receipt-container">
    
    <div class="receipt-header">
        <div class="pay-icon">💳</div>
        <h2>ホテル予約決済</h2>
        <p class="notice">カカオペイ決済を実行します。決済ボタンを押すとカカオペイ決済画面に移動します。</p>
    </div>

    <div class="section-title">予約および決済情報</div>
    <table class="info-table">
        <tr>
            <th>予約識別番号</th>
            <td><%= bootNo %></td>
        </tr>
        <tr>
            <th>通信固有コード</th>
            <td><%= reservationCode %></td>
        </tr>
        <tr>
            <th>予約者名</th>
            <td><%= bootName %></td>
        </tr>
        <tr>
            <th>商品名</th>
            <td><%= itemName %></td>
        </tr>
        <tr>
            <th>数量</th>
            <td>1</td>
        </tr>
        <tr>
            <th>決済金額</th>
            <td class="highlight-price" id="reserveTotal">₩ <%= nf.format(roomTotal) %></td>
        </tr>
    </table>

    <form action="${pageContext.request.contextPath}/res/kakaoReady.jsp" method="post" class="btn-group">
        <input type="hidden" name="bootNo" value="<%= bootNo %>">
        <input type="hidden" name="bootPayCheck" value="<%= roomTotal %>"> 
        <button class="btn btn-primary" type="submit">カカオペイで決済する</button>
    </form>
</main>
</body>
</html>