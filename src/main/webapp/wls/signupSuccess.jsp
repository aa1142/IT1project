<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 💡 登録した人の名前をアドレスバーのパラメータから取得します (例: signupSuccess.jsp?name=山田)
    String name = request.getParameter("name");
    if(name == null || name.trim().equals("")) {
        name = "お客様"; // 名前がない場合のデフォルト値処理
    }
%>
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>会員登録完了 | JYP HOTEL</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400;700;900&display=swap");

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
  font-family:"Noto Sans JP",sans-serif;
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

.desc span{
  color: var(--point);
  font-weight: 700;
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
  header{ padding:0 20px; }
  .container{ margin:20px; padding:50px 25px; }
  h2{ font-size:30px; }
  .step{ width:140px; font-size:12px; }
  .btn{ width:100%; }
  .btn-wrap{ flex-direction:column; }
}
</style>
</head>
<body>

<header>
  <div class="logo">JYP <span>HOTEL</span></div>
</header>

<div class="step-wrap">
  <div class="step">01 会員情報の入力</div>
  <div class="step active">02 登録完了</div>
</div>

<div class="container">
  <div class="complete-icon">✓</div>

  <h2>会員登録が完了しました</h2>

  <p class="desc">
    <span><%= name %></span> 様、JYP HOTELの会員にご登録いただき、誠にありがとうございます。<br>
    ログイン後、様々な宿泊予約サービスをご利用いただけます。
  </p>

  <div class="info-box">
    <p><strong>ご利用案内：</strong> ログイン後、客室のご予約および予約状況の照会が可能になります。</p>
  </div>

  <div class="btn-wrap">
    <button class="btn btn-main" onclick="goLogin()">ログインする</button>
    <button class="btn btn-sub" onclick="goMain()">メインへ戻る</button>
  </div>
</div>

<footer>
  <p>© 2026 JYP HOTEL. All rights reserved.</p>
</footer>

<script>
function goMain(){
  // 💡 メインページのファイル名を指定してください
  location.href = "<%= request.getContextPath() %>/wls/index.jsp";
}

function goLogin(){
  // 💡 作成するログインページのファイル名を事前に指定します
   location.href = "<%= request.getContextPath() %>/wls/login.jsp";
}
</script>
</body>
</html>