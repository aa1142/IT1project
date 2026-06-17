<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String navCtx = request.getContextPath();
    String navUserId = (String) session.getAttribute("sessionUserId");
    String navUserName = (String) session.getAttribute("sessionUserName");
    boolean navLogin = (navUserId != null);
%>
<div class="site-nav">
  <div class="site-nav-inner">
    <div>
      <a href="<%= navCtx %>/wls/index.jsp"><strong>JYP HOTEL</strong></a>
      <a href="<%= navCtx %>/testex2/hotelsearch.jsp">호텔 예약</a>
      <a href="<%= navCtx %>/res/BootSearch.jsp">예약 조회</a>
    </div>
    <div>
      <% if (!navLogin) { %>
        <a href="<%= navCtx %>/wls/login.jsp" class="point">로그인</a>
        <a href="<%= navCtx %>/wls/signup.jsp">회원가입</a>
      <% } else { %>
        <span class="point"><%= navUserName %>님</span>
        <a href="<%= navCtx %>/wls/myPage.jsp">마이페이지</a>
        <a href="<%= navCtx %>/testex2/myReservationList.jsp">예약 내역</a>
        <a href="<%= navCtx %>/wls/logout.jsp">로그아웃</a>
      <% } %>
    </div>
  </div>
</div>
