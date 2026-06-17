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
      <a href="<%= navCtx %>/testex2/hotelsearch.jsp">ホテル予約</a>
      <a href="<%= navCtx %>/res/BootSearch.jsp">予約照会</a>
    </div>
    <div>
      <% if (!navLogin) { %>
        <a href="<%= navCtx %>/wls/login.jsp" class="point">ログイン</a>
        <a href="<%= navCtx %>/wls/signup.jsp">会員登録</a>
      <% } else { %>
        <span class="point"><%= navUserName %>様</span>
        <a href="<%= navCtx %>/wls/myPage.jsp">マイページ</a>
        <a href="<%= navCtx %>/testex2/myReservationList.jsp">予約履歴</a>
        <a href="<%= navCtx %>/wls/logout.jsp">ログアウト</a>
      <% } %>
    </div>
  </div>
</div>
