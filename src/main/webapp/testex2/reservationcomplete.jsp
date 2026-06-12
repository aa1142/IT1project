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

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.KOREA);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>JYP 호텔 | 예약 완료</title>
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
      <h2>예약이 완료되었습니다</h2>
      <p>예약코드 <strong><%= boot.getReservation_code() %></strong></p>
      <% if (boot.getBoot_confirm() == 0) { %>
      <p style="color:#b45309;margin-top:8px;">결제 대기 중입니다. 미결제 시 예약이 취소될 수 있습니다.</p>
      <% } %>
    </div>

    <div class="card" style="padding:24px;">
      <div class="detail-row"><span>호텔</span><span><%= boot.getCompany_name() %></span></div>
      <div class="detail-row"><span>객실</span><span><%= boot.getRoom_grade_ui() %> · <%= boot.getRoom_type_name() %></span></div>
      <div class="detail-row"><span>체크인</span><span><%= boot.getBoot_checkin() %></span></div>
      <div class="detail-row"><span>체크아웃</span><span><%= boot.getBoot_checkout() %></span></div>
      <div class="detail-row"><span>인원</span><span>성인 <%= boot.getBoot_adult() %> / 어린이 <%= boot.getBoot_child() %></span></div>
      <div class="detail-row"><span>예약자</span><span><%= boot.getBoot_name() %></span></div>
      <div class="detail-row"><span>전화</span><span><%= boot.getBoot_phone() %></span></div>
      <div class="detail-row"><span>숙박</span><span><%= nights %>박</span></div>
      <% if (roomTotal > 0) { %>
      <div class="detail-row"><span>객실 요금 (<%= guestCount %>인 × <%= nights %>박)</span><span>₩<%= nf.format(roomTotal) %></span></div>
      <% } %>
      <% if (hasBreakfast && breakfastTotal > 0) { %>
      <div class="detail-row"><span>조식 뷔페 (<%= guestCount %>인 × <%= nights %>박)</span><span>₩<%= nf.format(breakfastTotal) %></span></div>
      <% } %>
      <% if (hasFastCheckin && fastCheckinTotal > 0) { %>
      <div class="detail-row"><span>빠른 체크인</span><span>₩<%= nf.format(fastCheckinTotal) %></span></div>
      <% } %>
      <% if (total > 0) { %>
      <div class="detail-row" style="font-weight:600;margin-top:8px;"><span>합계</span><span>₩<%= nf.format(total) %></span></div>
      <% } %>

      <div class="complete-actions">
        <a href="myReservationList.jsp" class="btn-list">예약 내역</a>
        <a href="hotelsearch.jsp" class="btn-list">다른 예약</a>
        <a href="<%= request.getContextPath() %>/res/bootSearch.jsp" class="btn-list">예약 조회</a>
        <a href="../wls/index.jsp" class="btn-home">홈으로</a>
      </div>
    </div>
  </main>
</body>
</html>
