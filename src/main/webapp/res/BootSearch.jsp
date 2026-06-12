<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");

// ReservationCreateServlet에서 request.setAttribute("reservation", dto)로 넘겨준 객체 수신
Object repoObj = request.getAttribute("reservation");
com.hotel.reservation.BootDTO rDto = (repoObj instanceof com.hotel.reservation.BootDTO) ? (com.hotel.reservation.BootDTO)repoObj : null;

// 객체가 있으면 객체에서, 없으면 parameter/attribute에서 백업 데이터 가져오기
String reservationId = (rDto != null) ? String.valueOf(rDto.getReservationCode()) : request.getParameter("reservationId");
String reservationCode = (rDto != null) ? rDto.getReservationCode() : request.getParameter("reservationCode");
String itemName = (rDto != null) ? rDto.getRoomGrade() : request.getParameter("itemName");
/* String totalAmount = (rDto != null) ? String.valueOf(rDto.getTotalAmount()) : request.getParameter("totalAmount"); */
String bookerName = (rDto != null) ? rDto.getBootName() : request.getParameter("bookerName");
String bookerEmail = (rDto != null) ? rDto.getBootEmail() : request.getParameter("bookerEmail");
String quantity = request.getParameter("quantity");
String taxFreeAmount = request.getParameter("taxFreeAmount");

if (reservationId == null || reservationId.trim().isEmpty()) reservationId = "1";
if (reservationCode == null || reservationCode.trim().isEmpty()) reservationCode = "ORD-UNKNOWN";
if (itemName == null || itemName.trim().isEmpty()) itemName = "스탠다드 더블 예약금";
/* if (totalAmount == null || totalAmount.trim().isEmpty()) totalAmount = "50000"; */
if (quantity == null || quantity.trim().isEmpty()) quantity = "1";
if (taxFreeAmount == null || taxFreeAmount.trim().isEmpty()) taxFreeAmount = "0";
if (bookerName == null || bookerName.trim().isEmpty()) bookerName = "고객";
if (bookerEmail == null || bookerEmail.trim().isEmpty()) bookerEmail = "";

int displayAmount = 0;
/* try {
    displayAmount = Integer.parseInt(totalAmount);
} catch (Exception e) {
    displayAmount = 50000;
} */
String displayAmountText = String.format("%,d", displayAmount) + "원";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>호텔 예약 결제</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/Boot.css">

</head>
<body>
<main>
  <h1>호텔 예약 결제</h1>
  <p class="notice">카카오페이 결제를 실행합니다. 결제 버튼을 누르면 카카오페이 결제 화면으로 이동합니다.</p>

  <div class="summary">
    <div class="row"><strong>예약 고유코드</strong><span><%= reservationCode %></span></div>
    <div class="row"><strong>예약자명</strong><span><%= bookerName %></span></div>
    <div class="row"><strong>상품명</strong><span><%= itemName %></span></div>
    <div class="row"><strong>수량</strong><span><%= quantity %></span></div>
    <div class="row"><strong>결제금액</strong><span style="color: #d9383a; font-weight: bold;"><%= displayAmountText %></span></div>
  </div>

  <form action="${pageContext.request.contextPath}/kakaoReady" method="post">
    <input type="hidden" name="reservationId" value="<%= reservationId %>">
    <input type="hidden" name="reservationCode" value="<%= reservationCode %>">
    <input type="hidden" name="itemName" value="<%= itemName %>">
    <input type="hidden" name="quantity" value="<%= quantity %>">
    <%-- <input type="hidden" name="totalAmount" value="<%= totalAmount %>"> --%>
    <input type="hidden" name="taxFreeAmount" value="<%= taxFreeAmount %>">
    <input type="hidden" name="bookerName" value="<%= bookerName %>">
    <input type="hidden" name="bookerEmail" value="<%= bookerEmail %>">
    
    <button class="pay-button" type="submit">카카오페이 결제하기</button>
  </form>
</main>
</body>
</html>