<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>가입완료 | JYP HOTEL</title>

<style>
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700;900&display=swap");

:root{
  --main:#111111;
  --point:#c8a96b;
  --bg:#f8f6f2;
  --text:#222222;
}

*{
  margin:0;
  padding:0;
  box-sizing:border-box;
  font-family:"Noto Sans KR",sans-serif;
}

body{
  background:var(--bg);
  color:var(--text);
}

/* HEADER */

header{
  height:80px;
  background:#333;

  display:flex;
  align-items:center;
  justify-content:space-between;

  padding:0 40px;

  border-bottom:1px solid rgba(255,255,255,0.08);
}

.logo{
  font-size:28px;
  font-weight:900;
  color:white;
}

.logo span{
  color:var(--point);
}

/* STEP */

.step-wrap{
  max-width:900px;
  margin:50px auto 20px;

  display:flex;
  justify-content:center;
  gap:20px;
}

.step{
  width:180px;
  height:50px;

  border-radius:999px;

  background:#ece7dd;

  display:flex;
  align-items:center;
  justify-content:center;

  font-size:14px;
  font-weight:700;

  color:#666;
}

.step.active{
  background:#111111;
  color:#c8a96b;
}

/* CONTAINER */

.container{
  max-width:800px;
  margin:0 auto 80px;

  background:white;

  border:1px solid #e6dfd3;

  padding:70px 50px;

  border-radius:20px;

  box-shadow:0 10px 30px rgba(0,0,0,0.08);

  text-align:center;
}

/* ICON */

.complete-icon{
  width:110px;
  height:110px;

  margin:0 auto 30px;

  border-radius:50%;

  background:#f4ede1;

  border:2px solid #c8a96b;

  display:flex;
  align-items:center;
  justify-content:center;

  font-size:50px;
  font-weight:900;

  color:#111111;
}

/* TITLE */

h2{
  font-size:38px;
  color:#111111;
  margin-bottom:18px;
  font-weight:900;
  letter-spacing:-1px;
}

/* TEXT */

.desc{
  font-size:16px;
  line-height:1.8;
  color:#666;

  margin-bottom:40px;
}

/* INFO BOX */

.info-box{
  background:#faf8f3;

  border:1px solid #e6dfd3;

  border-radius:14px;

  padding:25px;

  margin-bottom:40px;
}

.info-box p{
  margin:8px 0;
  font-size:15px;
}

/* BUTTONS */

.btn-wrap{
  display:flex;
  justify-content:center;
  gap:15px;
  flex-wrap:wrap;
}

.btn{
  min-width:180px;
  height:54px;

  border:none;

  border-radius:10px;

  font-size:15px;
  font-weight:700;

  cursor:pointer;

  transition:0.2s;
}

.btn-main{
  background:#111111;
  color:white;
}

.btn-main:hover{
  background:#c8a96b;
  color:#111111;
  transform:translateY(-2px);
}

.btn-sub{
  background:#ece7dd;
  color:#111111;
}

.btn-sub:hover{
  background:#c8a96b;
  color:#111111;
  transform:translateY(-2px);
}

/* FOOTER */

footer{
  background:#333;
  color:#ccc;

  text-align:center;

  padding:30px 20px;

  font-size:13px;
}

/* MOBILE */

@media(max-width:768px){

  header{
    padding:0 20px;
  }

  .container{
    margin:20px;
    padding:50px 25px;
  }

  h2{
    font-size:30px;
  }

  .step{
    width:140px;
    font-size:12px;
  }

  .btn{
    width:100%;
  }

  .btn-wrap{
    flex-direction:column;
  }
}
</style>
</head>

<body>

<header>
  <div class="logo">
    JYP <span>HOTEL</span>
  </div>
</header>

<div class="step-wrap">
  <div class="step">01 회원정보 입력</div>
  <div class="step active">02 가입완료</div>
</div>

<div class="container">

  <div class="complete-icon">
    ✓
  </div>

  <h2>회원가입이 완료되었습니다</h2>

  <p class="desc">
    JYP HOTEL 회원이 되신 것을 환영합니다.<br>
    로그인 후 다양한 예약 서비스를 이용하실 수 있습니다.
  </p>

  <div class="info-box">
    <p><strong>이용안내 :</strong> 로그인 후 객실 예약 및 예약 조회가 가능합니다.</p>
  </div>

  <div class="btn-wrap">

    <button class="btn btn-main"
      onclick="goLogin()">
      로그인 하기
    </button>

    <button class="btn btn-sub"
      onclick="goMain()">
      메인으로 이동
    </button>

  </div>

</div>

<footer>
  <p>© 2026 JYP HOTEL. All rights reserved.</p>
</footer>

<script>

function goMain(){
  location.href = "index.jsp";
}

function goLogin(){
  location.href = "login-2.html";
}

</script>

</body>
</html>
