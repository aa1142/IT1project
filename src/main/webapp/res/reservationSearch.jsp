<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>예약 내역 확인</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/reservationSearch.css">

</head>
<body>
<main>
  <div class="brand">JYP HOTEL</div>
  <h1>예약 내역 확인</h1>
  <p class="sub-text">예약번호와 예약자 전화번호 또는 이메일을 입력하면 예약 내역을 확인할 수 있습니다.</p>

  <div class="divider"></div>

  <form action="${pageContext.request.contextPath}/reservationSearch" method="post">
    <label for="reservationNo">예약번호</label>
    <input type="text" id="reservationNo" name="reservationNo" placeholder="ORD20260606123456" required>

    <label for="bookerKeyword">예약자 전화번호 또는 이메일</label>
    <input type="text" id="bookerKeyword" name="bookerKeyword" placeholder="010-1234-5678 또는 example@email.com" required>

    <button type="submit">예약 조회</button>
  </form>

  <p class="error">${errorMessage}</p>
</main>
</body>
</html>