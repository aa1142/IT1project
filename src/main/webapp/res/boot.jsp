<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String bootNo = (String) request.getAttribute("bootNo");
    if (bootNo == null) bootNo = request.getParameter("bootNo");

    String reservationCode = (String) request.getAttribute("reservationCode");
    if (reservationCode == null) reservationCode = request.getParameter("reservationCode");

    String itemName = (String) request.getAttribute("itemName");
    if (itemName == null) itemName = request.getParameter("itemName");

    String bootPayCheck = (String) request.getAttribute("bootPayCheck");
    if (bootPayCheck == null) bootPayCheck = request.getParameter("bootPayCheck");

    String bootName = (String) request.getAttribute("bootName");
    if (bootName == null) bootName = request.getParameter("bootName");

    String bootEmail = (String) request.getAttribute("bootEmail");
    if (bootEmail == null) bootEmail = request.getParameter("bootEmail");

    String quantity = request.getParameter("quantity");
    String taxFreeAmount = request.getParameter("taxFreeAmount");

    // 2. 비정상적 다이렉트 접근 및 데이터 유실 차단 방어벽
    if (bootNo == null || bootNo.trim().isEmpty()) {
%>
    <script>
        alert("예약(BOOT) 정보가 만료되었거나 올바르지 않은 접근입니다. 다시 진행해 주세요.");
        location.href = "${pageContext.request.contextPath}/index.jsp";
    </script>
<%
        return;
    }

    // 기본값 방어벽 구성
    if (reservationCode == null || reservationCode.trim().isEmpty()) reservationCode = "ORD-UNKNOWN";
    if (itemName == null || itemName.trim().isEmpty()) itemName = "호텔 객실 예약금";
    if (bootPayCheck == null || bootPayCheck.trim().isEmpty()) bootPayCheck = "50000";
    if (quantity == null || quantity.trim().isEmpty()) quantity = "1";
    if (taxFreeAmount == null || taxFreeAmount.trim().isEmpty()) taxFreeAmount = "0";
    if (bootName == null || bootName.trim().isEmpty()) bootName = "고객";
    if (bootEmail == null || bootEmail.trim().isEmpty()) bootEmail = "";

    int displayAmount = 0;
    try {
        displayAmount = Integer.parseInt(bootPayCheck);
    } catch (Exception e) {
        displayAmount = 50000;
    }
    String displayAmountText = String.format("%,d", displayAmount) + "원";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>호텔 예약 결제 (BOOT)</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/boot.css">

</head>
<body>
<main>
  <h1>호텔 예약 결제</h1>
  <p class="notice">카카오페이 결제를 실행합니다. 결제 버튼을 누르면 카카오페이 결제 화면으로 이동합니다.</p>

  <div class="summary">
    <div class="row"><strong>예약 식별번호</strong><span><%= bootNo %></span></div>
    <div class="row"><strong>통신용 고유코드</strong><span><%= reservationCode %></span></div>
    <div class="row"><strong>예약자명</strong><span><%= bootName %></span></div>
    <div class="row"><strong>상품명</strong><span><%= itemName %></span></div>
    <div class="row"><strong>수량</strong><span><%= quantity %></span></div>
    <div class="row"><strong>결제금액</strong><span style="color: #d9383a; font-weight: bold;"><%= displayAmountText %></span></div>
  </div>

  <form action="${pageContext.request.contextPath}/kakaoReady" method="post">
    <input type="hidden" name="bootNo" value="<%= bootNo %>">
    <input type="hidden" name="reservationCode" value="<%= reservationCode %>">
    <input type="hidden" name="itemName" value="<%= itemName %>">
    <input type="hidden" name="quantity" value="<%= quantity %>">
    <input type="hidden" name="bootPayCheck" value="<%= bootPayCheck %>">
    <input type="hidden" name="taxFreeAmount" value="<%= taxFreeAmount %>">
    <input type="hidden" name="bootName" value="<%= bootName %>">
    <input type="hidden" name="bootEmail" value="<%= bootEmail %>">
    
    <button class="pay-button" type="submit">카카오페이 결제하기</button>
  </form>
</main>
</body>
</html>