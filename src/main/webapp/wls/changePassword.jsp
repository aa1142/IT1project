<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // ログインセキュリティ検証
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    if (sessionUserId == null) {
        out.print("<script>alert('ログインが必要なサービスです。'); location.href='login.jsp';</script>");
        return;
    }
%>
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>パスワード変更 | JYP HOTEL</title>
<style>
  @import url("https://googleapis.com");
  :root {
    --main: #111111;
    --point: #c8a96b;
    --line: #e6dfd3;
    --bg: #f8f6f2;
    --text: #222222;
  }
  * { margin:0; padding:0; box-sizing:border-box; font-family:"Noto Sans JP",sans-serif; }
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
  <h2>パスワード変更</h2>
  
  <form action="<%= request.getContextPath() %>/changePasswordAction" method="post" onsubmit="return validateForm()">
    <div class="input-group">
      <label>現在のパスワード</label>
      <input type="password" id="currentPw" name="currentPw" placeholder="現在のパスワードを入力してください">
    </div>
    
    <div class="input-group">
      <label>新しいパスワード</label>
      <input type="password" id="newPw" name="newPw" placeholder="新しいパスワードを入力してください">
      <span class="info-text">8〜15文字の半角英数字の組み合わせ</span>
    </div>
    
    <div class="input-group">
      <label>新しいパスワード（確認）</label>
      <input type="password" id="newPwConfirm" name="newPwConfirm" placeholder="新しいパスワードをもう一度入力してください">
    </div>
    
    <div class="submit-wrap">
      <button type="submit" class="btn-submit btn-save">変更完了</button>
      <button type="button" class="btn-submit btn-cancel" onclick="history.back()">キャンセル</button>
    </div>
  </form>
</div>

<script>
function validateForm() {
  const currentPw = document.getElementById("currentPw").value;
  const newPw = document.getElementById("newPw").value;
  const newPwConfirm = document.getElementById("newPwConfirm").value;

  if(currentPw.trim() === "") { alert("現在のパスワードを入力してください。"); return false; }
  if(newPw.trim() === "") { alert("新しいパスワードを入力してください。"); return false; }
  if(newPwConfirm.trim() === "") { alert("新しいパスワード（確認）を入力してください。"); return false; }
  
  if(newPw === currentPw) {
    alert("新しいパスワードは現在のパスワードと異なるものを設定してください。");
    return false;
  }
  
  if(newPw !== newPwConfirm) {
    alert("新しいパスワードが一致しません。");
    return false;
  }
  
  return true;
}
</script>
</body>
</html>