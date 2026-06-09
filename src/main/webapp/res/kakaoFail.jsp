<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>카카오페이 결제 실패</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/kakaoFail.css">

</head>
<body>
  <main class="page">
    <div class="title">결제 내역</div>

    <section class="fail-box">
      <div class="icon">!</div>
      <h1>카카오페이 결제에 실패했습니다.</h1>
      <p class="message">${errorMessage}</p>
      <p class="guide">다시 결제 해주세요</p>
      
      <a class="button" href="${pageContext.request.contextPath}/res/roomDetail.jsp">예약 화면으로 돌아가기</a>
    </section>
  </main>
</body>
</html>