<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>카카오페이 결제 취소</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/kakaoCancel.css">

</head>
<body>
  <main class="page">
    <div class="title">결제 취소 안내</div>

    <section class="cancel-box">
      <div class="icon">!</div>
      <h1>카카오페이 결제 취소</h1>
      <p class="message">
        고객님께서 카카오페이 결제를 취소하셨습니다.<br>
        결제가 정상적으로 이루어지지 않았으므로 예약 대기 상태가 해제됩니다.
      </p>
      
      <a class="button" href="${pageContext.request.contextPath}/res/roomDetail.jsp">다시 예약 진행하기</a>
    </section>
  </main>
</body>
</html>