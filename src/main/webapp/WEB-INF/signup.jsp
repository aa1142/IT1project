<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>회원정보 입력 | JYP HOTEL</title>

<!-- 💡 중요: 카카오 주소 API 사용을 위한 외부 스크립트 추가 -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

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
  border-bottom:1px solid rgba(255,255,255,0.08);
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:0 40px;
  border-bottom:1px solid #eee;
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
  color:#666;
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:14px;
  font-weight:700;
}

.step.active{
  background:#111111;
  color:#c8a96b;
}

/* CONTAINER */
.container{
  max-width:900px;
  margin:0 auto 80px;
  background:white;
  border:1px solid #e6dfd3;
  padding:50px;
  border-radius:18px;
  box-shadow:0 10px 30px rgba(0,0,0,0.08);
}

/* TITLE */
h2{
  font-size:34px;
  margin-bottom:40px;
  color:var(--main);
  font-weight:900;
}

/* TABLE */
table{
  width:100%;
  border-collapse:collapse;
  font-size:14px;
}

th{
  width:180px;
  text-align:left;
  padding:18px 14px;
  background:#fafafa;
  border-bottom:1px solid var(--line);
  vertical-align:middle;
}

td{
  padding:16px 14px;
  border-bottom:1px solid var(--line);
}

/* INPUT */
input, select{
  height:46px;
  border:1px solid var(--line);
  border-radius:8px;
  padding:0 14px;
  font-size:14px;
  outline:none;
  transition:0.2s;
}

input:focus, select:focus{
  border-color:var(--point);
  box-shadow:0 0 0 4px rgba(200,169,107,0.15);
}

/* INLINE */
.inline{
  display:flex;
  gap:10px;
  align-items:center;
  flex-wrap:wrap;
}

/* BUTTON */
.btn{
  height:46px;
  padding:0 18px;
  border:none;
  border-radius:8px;
  background:var(--main);
  color:#fff;
  font-size:13px;
  font-weight:700;
  cursor:pointer;
  transition:0.2s;
}

.btn:hover{
  background:var(--point);
  transform:translateY(-2px);
}

/* INFO */
.info{
  font-size:12px;
  color:#888;
}

/* SECTION TITLE */
.section-title{
  margin-top:40px;
  margin-bottom:15px;
  font-size:20px;
  font-weight:800;
  color:var(--main);
}

/* REQUIRED */
.required{
  color:#d93025;
}

/* SUBMIT */
.submit-wrap{
  text-align:center;
  margin-top:40px;
}

.submit{
  width:240px;
  height:54px;
  border:none;
  border-radius:10px;
  background:#111111;
  color:white;
  font-size:16px;
  font-weight:700;
  cursor:pointer;
  transition:0.2s;
}

.submit:hover{
  background:#c8a96b;
  color:#111111;
  transform:translateY(-2px);
}

/* FOOTER */
footer{
  background:#333;
  color:#aaa;
  text-align:center;
  padding:30px 20px;
  font-size:13px;
}

/* MOBILE */
@media(max-width:768px){
  header{ padding:0 20px; }
  .container{ margin:20px; padding:25px; }
  th{ width:120px; font-size:13px; }
  .inline{ flex-direction:column; align-items:flex-start; }
  input, select{ width:100%; }
  .submit{ width:100%; }
  .step{ width:140px; font-size:12px; }
}
</style>
</head>

<body>

<header>
  <div class="logo">JYP <span>HOTEL</span></div>
</header>

<div class="step-wrap">
  <div class="step active">01 회원정보 입력</div>
  <div class="step">02 가입완료</div>
</div>

<div class="container">

<form action="signupAction.jsp" method="post">

<h2>회원정보 입력</h2>

<table>
<tr>
  <th>성명 (국문) <span class="required">*</span></th>
  <td>
    <div class="inline">
      <select id="gender">
        <option>남</option>
        <option>여</option>
      </select>
      <input type="text" name="name" placeholder="이름을 입력해주세요">
    </div>
  </td>
</tr>

<tr>
  <th>성명 (영문) <span class="required">*</span></th>
  <td>
    <div class="inline">
      <input type="text" placeholder="First name">
      <input type="text" placeholder="Last name">
    </div>
  </td>
</tr>

<tr>
  <th>생년월일 <span class="required">*</span></th>
  <td>
    <input type="date" id="birthdate" style="width:220px;">
  </td>
</tr>

<tr>
  <th>이메일 <span class="required">*</span></th>
  <td>
    <input type="text" name="email" placeholder="이메일을 입력해주세요">
  </td>
</tr>

<tr>
  <th>휴대전화 <span class="required">*</span></th>
  <td>
    <div class="inline">
      <select>
        <option>010</option>
        <option>070</option>
        <option>011</option>
        <option>02</option>
      </select>
      -
<input type="text" name="phone2" style="width:100px">
-
<input type="text" name="phone3" style="width:100px">
    </div>
  </td>
</tr>

<tr>
  <th>자택주소</th>
  <td>
    <div class="inline">
      <!-- 💡 중요: id="address" 추가 -->
      <input type="text" id="address" name="address" style="width:300px" readonly placeholder="주소찾기를 이용해주세요">
      <!-- 💡 중요: onclick="openAddressSearch()" 추가 -->
      <button type="button" class="btn" onclick="openAddressSearch()">주소찾기</button>
    </div>
    <div style="margin-top:10px">
      <input type="text" name="address_detail" style="width:100%" placeholder="상세주소를 입력해주세요">
    </div>
  </td>
</tr>
</table>

<div class="section-title">웹사이트 비밀번호 입력</div>

<table>
<tr>
  <th>아이디 <span class="required">*</span></th>
  <td>
    <div class="inline">
      <input type="text" name="userid">
      <!-- 💡 중요: onclick="checkDuplicateId()" 추가 -->
      <button type="button" class="btn" onclick="checkDuplicateId()">중복확인</button>
    </div>
  </td>
</tr>

<tr>
  <th>비밀번호 <span class="required">*</span></th>
  <td>
    <input type="password" name="password" id="pw" style="width:320px">
    <span class="info">8~15자 영문/숫자</span>
  </td>
</tr>

<tr>
  <th>비밀번호 확인 <span class="required">*</span></th>
  <td>
    <input type="password" id="pw2" style="width:320px">
  </td>
</tr>
</table>

<div class="submit-wrap">
  <button type="button" class="submit" onclick="submitForm()">가입 완료</button>
</div>

</form>

</div>

<footer>
  <p>© 2026 JYP HOTEL. All rights reserved.</p>
</footer>

<script>
// 안전장치 변수 선언
let isIdChecked = false; 
let checkedId = ""; 

// 1. 카카오 주소 API 기능 구현
function openAddressSearch() {
  new daum.Postcode({
    oncomplete: function(data) {
      document.getElementById("address").value = data.address;
    }
  }).open();
}

// 2. 아이디 중복 확인 기능 구현
function checkDuplicateId() {
  const userid = document.querySelector("input[name='userid']").value;
  
  if (userid.trim() === "") {
    alert("아이디를 입력해주세요.");
    return;
  }

  fetch("checkIdAction.jsp?userid=" + encodeURIComponent(userid))
    .then(response => response.text())
    .then(data => {
      const result = data.trim();
      
      if (result === "usable") {
        alert("사용 가능한 아이디입니다.");
        isIdChecked = true;
        checkedId = userid; 
      } else if (result === "duplicated") {
        alert("이미 존재하는 아이디입니다. 다른 아이디를 입력해주세요.");
        isIdChecked = false;
      } else if (result === "empty") {
        alert("아이디를 올바르게 입력해주세요.");
        isIdChecked = false;
      } else {
        alert("서버 오류가 발생했습니다. 다시 시도해주세요.");
        isIdChecked = false;
      }
    })
    .catch(error => {
      console.error("Error:", error);
      alert("요청 처리 중 문제가 발생했습니다.");
      isIdChecked = false;
    });
}

// 사용자가 아이디를 다시 타이핑하면 중복확인 리셋
document.querySelector("input[name='userid']").addEventListener("input", function() {
  isIdChecked = false;
  checkedId = "";
});

// 3. 폼 전송 기능 구현
function submitForm(){
  const userid = document.querySelector("input[name='userid']").value;
  const pw1 = document.getElementById("pw").value;
  const pw2 = document.getElementById("pw2").value;
  const name = document.querySelector("input[name='name']").value;
  const email = document.querySelector("input[name='email']").value;

  if(name.trim() === "") { alert("성명을 입력해주세요."); return; }
  if(email.trim() === "") { alert("이메일을 입력해주세요."); return; }
  if(userid.trim() === "") { alert("아이디를 입력해주세요."); return; }
  if(pw1.trim() === "") { alert("비밀번호를 입력해주세요."); return; }

  if(!isIdChecked || userid !== checkedId) {
    alert("아이디 중복확인을 완료해주세요.");
    return;
  }

  if(pw1 !== pw2){
    alert("비밀번호가 일치하지 않습니다.");
    return;
  }
  
  document.querySelector("form").submit();
}
</script>


</body>
</html>
