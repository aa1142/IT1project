<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>카카오페이 결제 실패</title>
<style>
  * {
    box-sizing: border-box;
  }

  body {
    margin: 0;
    min-height: 100vh;
    font-family: Arial, 'Noto Sans KR', sans-serif;
    color: #222;
    background: #eef2f7;
  }

  body::before {
    content: "";
    position: fixed;
    inset: 0;
    background: url("file:///C:/ProjectPicture/park.jpeg") center / cover no-repeat;
    opacity: 0.8;
    z-index: -2;
  }

  body::after {
    content: "";
    position: fixed;
    inset: 0;
    background: rgba(255, 255, 255, 0.18);
    z-index: -1;
  }

  .page {
    min-height: 100vh;
    padding: 42px 24px;
  }

  .title {
    max-width: 980px;
    margin: 0 auto 18px;
    font-size: 28px;
    font-weight: 800;
  }

  .fail-box {
    max-width: 980px;
    min-height: 430px;
    margin: 0 auto;
    padding: 72px 48px;
    border: 1px solid #dfe5ee;
    background: rgba(255, 255, 255, 0.92);
    text-align: center;
    box-shadow: 0 18px 45px rgba(15, 23, 42, 0.16);
  }

  .icon {
    width: 64px;
    height: 64px;
    margin: 0 auto 24px;
    border-radius: 50%;
    background: #ffe2e2;
    color: #e54848;
    font-size: 38px;
    font-weight: 800;
    line-height: 64px;
  }

  h1 {
    margin: 0 0 18px;
    font-size: 24px;
  }

  .message {
    min-height: 24px;
    margin: 0 0 12px;
    color: #555;
    line-height: 1.6;
  }

  .guide {
    margin: 0 0 38px;
    color: #333;
    font-weight: 700;
  }

  .button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 190px;
    height: 48px;
    padding: 0 24px;
    background: #3f8cff;
    color: #fff;
    font-weight: 800;
    text-decoration: none;
    border: 0;
  }

  .button:hover {
    background: #2677ef;
  }
</style>
</head>
<body>
  <main class="page">
    <div class="title">결제 내역</div>

    <section class="fail-box">
      <div class="icon">!</div>
      <h1>카카오페이 결제에 실패했습니다.</h1>
      <p class="message">${errorMessage}</p>
      <p class="guide">다시 결제 해주세요</p>
      <a class="button" href="${pageContext.request.contextPath}/reservation.jsp">예약 화면으로 돌아가기</a>
    </section>
  </main>
</body>
</html>