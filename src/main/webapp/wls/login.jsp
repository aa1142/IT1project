<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ログイン | JYP HOTEL</title>
<style>
@import url("https://googleapis.com");

:root{
  --main:#111111;
  --point:#c8a96b;
  --line:#e6dfd3;
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

/* CONTAINER */
.container{
  max-width:500px;
  margin:80px auto;
  background:white;
  border:1px solid #e6dfd3;
  padding:50px 40px;
  border-radius:18px;
  box-shadow:0 10px 30px rgba(0,0,0,0.08);
}

h2{
  font-size:30px;
  margin-bottom:35px;
  color:var(--main);
  font-weight:900;
  text-align:center;
}

/* INPUT GROUP */
.input-group {
  margin-bottom:20px;
}

.input-group label {
  display:block;
  font-size:13px;
  font-weight:700;
  margin-bottom:8px;
  color:#555;
}

input[type="text"], input[type="password"] {
  width:100%;
  height:48px;
  border:1px solid var(--line);
  border-radius:8px;
  padding:0 14px;
  font-size:14px;
  outline:none;
  transition:0.2s;
}

input:focus {
  border-color:var(--point);
  box-shadow:0 0 0 4px rgba(200,169,107,0.15);
}

/* BUTTON */
.btn-submit {
  width:100%;
  height:52px;
  border:none;
  border-radius:10px;
  background:var(--main);
  color:white;
  font-size:16px;
  font-weight:700;
  cursor:pointer;
  margin-top:15px;
  transition:0.2s;
}

.btn-submit:hover {
  background:var(--point);
  color:var(--main);
  transform:translateY(-2px);
}

/* LINKS */
.find-wrap {
  display:flex;
  justify-content:center;
  gap:15px;
  margin-top:25px;
  font-size:13px;
  color:#666;
}

.find-wrap a {
  color:#666;
  text-decoration:none;
}

.find-wrap a:hover {
  color:var(--point);
  text-decoration:underline;
}

.find-wrap span {
  color:#ccc;
}

/* FOOTER */
footer{
  background:#333;
  color:#aaa;
  text-align:center;
  padding:30px 20px;
  font-size:13px;
  position: fixed;
  bottom: 0;
  width: 100%;
}

@media(max-width:768px){
  .container{ margin:40px 20px; padding:35px 20px; }
  footer { position: static; }
}
</style>
</head>
<body>

<header>
  <div class="logo">JYP <span>HOTEL</span></div>
</header>

<div class="container">
 <form action="<%= request.getContextPath() %>/loginAction" method="post" onsubmit="return validateForm()">
    <h2>LOGIN</h2>
    
    <div class="input-group">
      <label for="userid">ユーザーID</label>
      <input type="text" id="userid" name="userid" placeholder="ユーザーIDを入力してください">
    </div>
    
    <div class="input-group">
      <label for="userpw">パスワード</label>
      <input type="password" id="userpw" name="userpw" placeholder="パスワードを入力してください">
    </div>
    
    <button type="submit" class="btn-submit">ログイン</button>
    
    <div class="find-wrap">
  <a href="<%= request.getContextPath() %>/findAccountAction">IDをお忘れの方</a>
  <span>|</span>
  <a href="<%= request.getContextPath() %>/findAccountAction">パスワードをお忘れの方</a>
  <span>|</span>
  <a href="<%= request.getContextPath() %>/wls/signup.jsp">会員登録</a>
</div>
  </form>
</div>

<footer>
  <p>© 2026 JYP HOTEL. All rights reserved.</p>
</footer>

<script>
function validateForm() {
  const userid = document.getElementById("userid").value;
  const userpw = document.getElementById("userpw").value;
  
  if(userid.trim() === "") {
    alert("ユーザーIDを入力してください。");
    return false;
  }
  if(userpw.trim() === "") {
    alert("パスワードを入力してください。");
    return false;
  }
  return true;
}
</script>
</body>
</html>