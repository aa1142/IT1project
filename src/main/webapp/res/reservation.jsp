<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");

String itemName = request.getParameter("itemName");
String quantity = request.getParameter("quantity");
String totalAmount = request.getParameter("totalAmount");
String taxFreeAmount = request.getParameter("taxFreeAmount");
String reservationId = request.getParameter("reservationId");

if (itemName == null) {
  Object attr = request.getAttribute("itemName");
  itemName = attr == null ? null : String.valueOf(attr);
}

if (quantity == null) {
  Object attr = request.getAttribute("quantity");
  quantity = attr == null ? null : String.valueOf(attr);
}

if (totalAmount == null) {
  Object attr = request.getAttribute("totalAmount");
  totalAmount = attr == null ? null : String.valueOf(attr);
}

if (taxFreeAmount == null) {
  Object attr = request.getAttribute("taxFreeAmount");
  taxFreeAmount = attr == null ? null : String.valueOf(attr);
}

if (reservationId == null) {
  Object attr = request.getAttribute("reservationId");
  reservationId = attr == null ? null : String.valueOf(attr);
}

if (itemName == null || itemName.trim().isEmpty()) {
  itemName = "스탠다드 더블 예약금";
}

if (quantity == null || quantity.trim().isEmpty()) {
  quantity = "1";
}

if (totalAmount == null || totalAmount.trim().isEmpty()) {
  totalAmount = "50000";
}

if (taxFreeAmount == null || taxFreeAmount.trim().isEmpty()) {
  taxFreeAmount = "0";
}

if (reservationId == null || reservationId.trim().isEmpty()) {
  reservationId = "1";
}

int displayAmount = 0;
int displayReservationId = 0;
try {
  displayAmount = Integer.parseInt(totalAmount);
} catch (Exception e) {
  displayAmount = 50000;
  totalAmount = "50000";
}

try {
  displayReservationId = Integer.parseInt(reservationId);
} catch (Exception e) {
  displayReservationId = 1;
  reservationId = "1";
}

String displayAmountText = "¥" + String.format("%,d", displayAmount);
String displayReservationNo = String.format("JYP-%06d", displayReservationId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>호텔 예약 결제</title>
<style>
  body { margin: 0; font-family: Arial, 'Noto Sans KR', sans-serif; background: #f5f5f5; color: #222; }
  main { max-width: 720px; margin: 60px auto; padding: 32px; background: #fff; border: 1px solid #ddd; }
  h1 { margin-top: 0; }
  .summary { display: grid; gap: 10px; margin: 24px 0; padding: 20px; background: #fafafa; border: 1px solid #e4e4e4; }
  .row { display: flex; justify-content: space-between; gap: 18px; }
  .pay-button { width: 100%; height: 54px; border: 0; background: #ffeb00; color: #111; font-weight: 900; cursor: pointer; }
  .notice { color: #666; line-height: 1.6; }
</style>
</head>
<body>
<main>
  <h1>호텔 예약 결제</h1>
  <p class="notice">카카오페이 결제를 실행합니다. 결제 버튼을 누르면 카카오페이 결제 화면으로 이동합니다.</p>

  <div class="summary">
    <div class="row"><strong>예약번호</strong><span><%= displayReservationNo %></span></div>
    <div class="row"><strong>상품명</strong><span><%= itemName %></span></div>
    <div class="row"><strong>수량</strong><span><%= quantity %></span></div>
    <div class="row"><strong>결제금액</strong><span><%= displayAmountText %></span></div>
  </div>

  <form action="${pageContext.request.contextPath}/kakaoReady" method="post">
    <input type="hidden" name="itemName" value="<%= itemName %>">
    <input type="hidden" name="quantity" value="<%= quantity %>">
    <input type="hidden" name="totalAmount" value="<%= totalAmount %>">
    <input type="hidden" name="taxFreeAmount" value="<%= taxFreeAmount %>">
    <input type="hidden" name="reservationId" value="<%= reservationId %>">
    <button class="pay-button" type="submit">카카오페이 결제하기</button>
  </form>
</main>
</body>
</html>
