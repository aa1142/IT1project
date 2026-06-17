<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    String boot_no = request.getParameter("boot_no");
    if (boot_no == null) boot_no = "";

    BootVO boot = dao.selectReservationReceipt(boot_no);
    if (boot == null) {
        response.sendRedirect("hotelsearch.jsp");
        return;
    }

    int nights = HotelPriceUtil.calcNights(boot.getBoot_checkin(), boot.getBoot_checkout());
    String please = boot.getBoot_please();
    int roomTotal = HotelPriceUtil.parsePleaseAmount(please, "객실요금");
    int breakfastTotal = HotelPriceUtil.parsePleaseAmount(please, "조식요금");
    int fastCheckinTotal = HotelPriceUtil.parsePleaseAmount(please, "빠른체크인요금");
    int total = HotelPriceUtil.parsePleaseAmount(please, "총요금");
    if (total <= 0) {
        total = roomTotal + breakfastTotal + fastCheckinTotal;
    }
    boolean hasBreakfast = HotelPriceUtil.parsePleaseFlag(please, "조식");
    boolean hasFastCheckin = HotelPriceUtil.parsePleaseFlag(please, "빠른체크인");
    int guestCount = HotelPriceUtil.getGuestCount(boot.getBoot_adult(), boot.getBoot_child());

    boolean isOnsite = boot.getBoot_pay_check() == 1;
    boolean isConfirmed = boot.getBoot_confirm() == 1;
    String resCode = boot.getReservation_code();
    boolean hasResCode = resCode != null && !resCode.trim().isEmpty();
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.JAPAN);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>JYP HOTEL | 予約完了</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link href="hotel-common.css" type="text/css" rel="stylesheet">
  <link href="restyle.css" type="text/css" rel="stylesheet">
  <style>
    .complete-page { max-width:720px; margin:40px auto 80px; padding:0 2rem; }
    .success-banner { text-align:center; padding:40px 20px; margin-bottom:20px; }
    .detail-row { display:flex; justify-content:space-between; margin-bottom:8px; font-size:14px; }
    .complete-actions { display:flex; gap:10px; margin-top:20px; }
    .complete-actions a { flex:1; text-align:center; padding:14px; border-radius:6px; text-decoration:none; font-weight:600; }
    .btn-home { background:#d4af37; color:#111; }
    .btn-list { border:1px solid #ddd; color:#111; }
  </style>
</head>
<body>
  <jsp:include page="siteNav.jsp" />

  <main class="complete-page">
    <div class="card success-banner">
      <% if (isConfirmed) { %>
      <h2>ご予約が確定しました</h2>
      <% } else if (isOnsite) { %>
      <h2>ご予約の申込を受け付けました</h2>
      <p style="color:#b45309;margin-top:8px;">管理者が予約を確認し客室を割り当てると最終確定となります。チェックイン時に現地でお支払いください。</p>
      <% } else { %>
      <h2>ご予約を受け付けました</h2>
      <p style="color:#b45309;margin-top:8px;">オンライン決済完了後、管理者が客室を割り当てると最終確定となります。</p>
      <% } %>
      <p>予約番号 <strong><%= boot.getBoot_no() %></strong>
        <% if (hasResCode) { %>
        · 予約コード <strong><%= resCode %></strong>
        <% } else if (isOnsite && !isConfirmed) { %>
        <br><span style="font-size:13px;color:#71717a;">予約コードは管理者承認後、メールでご案内します。</span>
        <% } %>
      </p>
    </div>

    <div class="card" style="padding:24px;">
      <div class="detail-row"><span>ホテル</span><span><%= boot.getCompany_name() %></span></div>
      <div class="detail-row"><span>客室</span><span><%= boot.getRoom_grade_ui() %> · <%= boot.getRoom_type_name() %></span></div>
      <div class="detail-row"><span>チェックイン</span><span><%= boot.getBoot_checkin() %></span></div>
      <div class="detail-row"><span>チェックアウト</span><span><%= boot.getBoot_checkout() %></span></div>
      <div class="detail-row"><span>人数</span><span>大人 <%= boot.getBoot_adult() %> / 子供 <%= boot.getBoot_child() %></span></div>
      <div class="detail-row"><span>予約者</span><span><%= boot.getBoot_name() %></span></div>
      <div class="detail-row"><span>電話</span><span><%= boot.getBoot_phone() %></span></div>
      <div class="detail-row"><span>宿泊</span><span><%= nights %>泊</span></div>
      <% if (roomTotal > 0) { %>
      <div class="detail-row"><span>客室料金 (<%= guestCount %>名 × <%= nights %>泊)</span><span>¥<%= nf.format(roomTotal) %></span></div>
      <% } %>
      <% if (hasBreakfast && breakfastTotal > 0) { %>
      <div class="detail-row"><span>朝食ビュッフェ (<%= guestCount %>名 × <%= nights %>泊)</span><span>¥<%= nf.format(breakfastTotal) %></span></div>
      <% } %>
      <% if (hasFastCheckin && fastCheckinTotal > 0) { %>
      <div class="detail-row"><span>アーリーチェックイン</span><span>¥<%= nf.format(fastCheckinTotal) %></span></div>
      <% } %>
      <% if (total > 0) { %>
      <div class="detail-row" style="font-weight:600;margin-top:8px;"><span>合計</span><span>¥<%= nf.format(total) %></span></div>
      <% } %>

      <div class="complete-actions">
        <a href="myReservationList.jsp" class="btn-list">予約履歴</a>
        <a href="hotelsearch.jsp" class="btn-list">別の予約</a>
        <a href="<%= request.getContextPath() %>/res/BootSearch.jsp" class="btn-list">予約照会</a>
        <a href="../wls/index.jsp" class="btn-home">ホームへ</a>
      </div>
    </div>
  </main>
</body>
</html>
