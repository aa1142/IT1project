<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>예약 내역 확인</title>
<style>
  * {
    box-sizing: border-box;
  }

  body {
    margin: 0;
    min-height: 100vh;
    font-family: Arial, 'Noto Sans KR', sans-serif;
    background:
      linear-gradient(rgba(10, 10, 10, 0.78), rgba(10, 10, 10, 0.82)),
      radial-gradient(circle at top, #2d2412 0%, #050505 58%);
    color: #f8fafc;
  }

  main {
    max-width: 540px;
    margin: 90px auto;
    padding: 42px 38px;
    background: rgba(18, 18, 18, 0.92);
    border: 1px solid rgba(212, 175, 55, 0.55);
    border-radius: 10px;
    box-shadow:
      0 24px 70px rgba(0, 0, 0, 0.45),
      inset 0 1px 0 rgba(255, 255, 255, 0.06);
  }

  h1 {
    margin: 0 0 8px;
    font-size: 30px;
    font-weight: 900;
    letter-spacing: 0.5px;
    color: #f6d36b;
  }

  .sub-text {
    margin: 0 0 32px;
    color: #cbd5e1;
    font-size: 14px;
    line-height: 1.6;
  }

  label {
    display: block;
    margin: 20px 0 8px;
    color: #f6d36b;
    font-weight: 800;
    font-size: 14px;
  }

  input {
    width: 100%;
    height: 48px;
    padding: 0 14px;
    border: 1px solid rgba(212, 175, 55, 0.45);
    border-radius: 6px;
    background: #0f172a;
    color: #f8fafc;
    font-size: 15px;
    outline: none;
  }

  input::placeholder {
    color: #94a3b8;
  }

  input:focus {
    border-color: #f6d36b;
    box-shadow: 0 0 0 3px rgba(246, 211, 107, 0.16);
  }

  button {
    width: 100%;
    height: 52px;
    margin-top: 30px;
    border: 0;
    border-radius: 6px;
    background: linear-gradient(135deg, #d4af37, #f6d36b);
    color: #111827;
    font-size: 16px;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 12px 26px rgba(212, 175, 55, 0.22);
  }

  button:hover {
    background: linear-gradient(135deg, #f6d36b, #d4af37);
  }

  .error {
    min-height: 20px;
    margin-top: 18px;
    color: #f87171;
    font-weight: 700;
    line-height: 1.5;
  }

  .brand {
    margin-bottom: 28px;
    color: #fff;
    font-size: 14px;
    font-weight: 800;
    letter-spacing: 2px;
  }

  .divider {
    height: 1px;
    margin: 24px 0;
    background: linear-gradient(90deg, transparent, rgba(212, 175, 55, 0.65), transparent);
  }
</style>
</head>
<body>
<main>
  <div class="brand">JYP HOTEL</div>
  <h1>예약 내역 확인</h1>
  <p class="sub-text">예약번호와 예약자 전화번호 또는 이메일을 입력하면 예약 내역을 확인할 수 있습니다.</p>

  <div class="divider"></div>

  <form action="${pageContext.request.contextPath}/reservationSearch" method="post">
    <label for="reservationNo">예약번호</label>
    <input type="text" id="reservationNo" name="reservationNo" placeholder="JYP-A1B2C3D4E5">

    <label for="bookerKeyword">예약자 전화번호 또는 이메일</label>
    <input type="text" id="bookerKeyword" name="bookerKeyword" placeholder="010-1234-5678 또는 example@email.com">

    <button type="submit">예약 조회</button>
  </form>

  <p class="error">${errorMessage}</p>
</main>
</body>
</html>