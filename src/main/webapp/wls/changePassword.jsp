<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 로그인 보안 검증
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
        return;
    }
%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>비밀번호 변경 | JYP HOTEL</title>
<style>
  @import url("https://googleapis.com");
  :root {
    --main: #111111;
    --point: #c8a96b;
    --line: #e6dfd3;
    --bg: #f8f6f2;
    --text: #222222;
  }
  * { margin:0; padding:0; box-sizing:border-box; font-family:"Noto Sans KR",sans-serif; }
  body { background: var(--bg); color: var(--text); }
  
  header { height:80px; background:#333; display:flex; align-items:center; justify-content:space-between; padding:0 40px; }
  .logo { font-size:28px; font-weight:900; color:white; text-decoration:none; }
  .logo span { color:var(--point); }

  .container { max-width:550px; margin:60px auto; background:white; border:1px solid #e6dfd3; padding:40px; border-radius:18px; box-shadow:0 10px 30px rgba(0,0,0,0.08); }
  h2 { font-size:26px; margin-bottom:30px; color:var(--main); font-weight:900; text-align:center; }
  
  .input-group { margin-bottom:20px; }
  .input-group label { display:block; font-size:13px; font-weight:700; margin-bottom:8px; color:#555; }
  input { width:100%; height:48px; border:1px solid var(--line); border-radius:8px; padding:0 14px; font-size:14px; outline:none; }
  input:focus { border-color:var(--point); box-shadow:0 0 0 4px rgba(200,169,107,0.15); }
  
  .info-text { font-size:12px; color:#888; margin-top:5px; display:block; }
  
  .submit-wrap { text-align:center; display:flex; justify-content:center; gap:15px; margin-top:30px; }
  .btn-submit { width:50%; height:50px; border:none; border-radius:10px; font-size:15px; font-weight:700; cursor:pointer; transition:0.2s; }
  .btn-save { background: var(--main); color:white; }
  .btn-save:hover { background: var(--point); color:var(--main); transform:translateY(-2px); }
  .btn-cancel { background: #ece7dd; color:#111; }
  .btn-cancel:hover { background: #ddd; }
</style>
</head>
<body>

<header>
  <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
</header>

<div class="container">
  <h2>비밀번호 변경</h2>
  
  <form action="<%= request.getContextPath() %>/changePasswordAction" method="post" onsubmit="return validateForm()">
    <div class="input-group">
      <label>현재 비밀번호</label>
      <input type="password" id="currentPw" name="currentPw" placeholder="현재 비밀번호를 입력해주세요">
    </div>
    
    <div class="input-group">
      <label>새 비밀번호</label>
      <input type="password" id="newPw" name="newPw" placeholder="새 비밀번호를 입력해주세요">
      <span class="info-text">8~15자 영문/숫자 조합</span>
    </div>
    
    <div class="input-group">
      <label>새 비밀번호 확인</label>
      <input type="password" id="newPwConfirm" name="newPwConfirm" placeholder="새 비밀번호를 다시 입력해주세요">
    </div>
    
    <div class="submit-wrap">
      <button type="submit" class="btn-submit btn-save">변경 완료</button>
      <button type="button" class="btn-submit btn-cancel" onclick="history.back()">취소</button>
    </div>
  </form>
</div>

<script>
function validateForm() {
  const currentPw = document.getElementById("currentPw").value;
  const newPw = document.getElementById("newPw").value;
  const newPwConfirm = document.getElementById("newPwConfirm").value;

  if(currentPw.trim() === "") { alert("현재 비밀번호를 입력해주세요."); return false; }
  if(newPw.trim() === "") { alert("새 비밀번호를 입력해주세요."); return false; }
  if(newPwConfirm.trim() === "") { alert("새 비밀번호 확인을 입력해주세요."); return false; }
  
  if(newPw === currentPw) {
    alert("새 비밀번호는 현재 비밀번호와 다르게 설정해야 합니다.");
    return false;
  }
  
  if(newPw !== newPwConfirm) {
    alert("새 비밀번호가 서로 일치하지 않습니다.");
    return false;
  }
  
  return true;
}
</script>
</body>
</html>
