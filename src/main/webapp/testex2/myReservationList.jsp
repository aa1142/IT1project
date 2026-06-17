<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    Vector<BootVO> list = new Vector<BootVO>();
    if (sessionUserId != null) {
        list = dao.selectReservationHistoryByMember(sessionUserId);
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>JYP HOTEL | 予約履歴</title>
  <link href="hotel-common.css" type="text/css" rel="stylesheet">
  <link href="restyle.css" type="text/css" rel="stylesheet">
  <style>
    .list-page { max-width:900px; margin:30px auto 80px; padding:0 2rem; }
    .res-item { border:1px solid #e4e4e7; border-radius:6px; padding:16px; margin-bottom:12px; }
    .empty-box { text-align:center; padding:60px 20px; color:#71717a; }
  </style>
</head>
<body>
  <jsp:include page="siteNav.jsp" />

  <div class="list-page">
    <h2 style="margin-bottom:20px;">予約履歴</h2>

    <% if (sessionUserId == null) { %>
      <div class="empty-box">
        <p>ログイン後にご確認いただけます。</p>
        <p style="margin-top:12px;"><a href="../wls/login.jsp">ログイン</a></p>
      </div>
    <% } else if (list.isEmpty()) { %>
      <div class="empty-box">
        <p>予約履歴がありません。</p>
        <p style="margin-top:12px;"><a href="hotelsearch.jsp">ホテルを予約する</a></p>
      </div>
    <% } else {
        for (int i = 0; i < list.size(); i++) {
            BootVO b = list.get(i);
            int nights = HotelPriceUtil.calcNights(b.getBoot_checkin(), b.getBoot_checkout());
            String resCode = b.getReservation_code();
            String listTitle = (resCode != null && !resCode.trim().isEmpty())
                    ? resCode : ("予約番号 " + b.getBoot_no());
            boolean onsitePending = b.getBoot_pay_check() == 1 && b.getBoot_confirm() == 0
                    && (resCode == null || resCode.trim().isEmpty());
    %>
      <div class="res-item">
        <h3><%= b.getCompany_name() %> · <%= listTitle %></h3>
        <p><%= b.getRoom_grade_ui() %> <%= b.getRoom_type_name() %> · <%= nights %>泊</p>
        <p><%= b.getBoot_checkin() %> ~ <%= b.getBoot_checkout() %></p>
        <p>予約者: <%= b.getBoot_name() %>
          <% if (onsitePending) { %><span style="color:#b45309;"> · 承認待ち</span>
          <% } else if (b.getBoot_confirm() == 0) { %><span style="color:#b45309;"> · 決済待ち</span><% } else { %><span style="color:#15803d;"> · 確定</span><% } %>
        </p>
        <p><a href="reservationcomplete.jsp?boot_no=<%= b.getBoot_no() %>">詳細を見る</a></p>
      </div>
    <%   }
       } %>
  </div>
</body>
</html>
