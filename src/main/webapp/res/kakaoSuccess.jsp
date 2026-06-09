<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>카카오페이 결제 완료</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/kakaoSuccess.css">

</head>
<body>
  <main class="page">
    <div class="title">결제 내역</div>

    <section class="success-box">
      <div class="icon">✓</div>
      <h1>카카오페이 결제 완료</h1>
      <p class="message">호텔 예약금 결제가 완료되었습니다.</p>
      <p class="order-number">주문번호: ${partnerOrderId}</p>
      <a class="button" href="${pageContext.request.contextPath}/res/main.jsp">홈으로 돌아가기</a>
    </section>
  </main>
</body>
</html>