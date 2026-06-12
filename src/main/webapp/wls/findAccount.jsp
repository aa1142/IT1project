<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>계정 찾기 | JYP HOTEL</title>
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
  
  header { height:80px; background:#333; display:flex; align-items:center; padding:0 40px; }
  .logo { font-size:28px; font-weight:900; color:white; text-decoration:none; }
  .logo span { color:var(--point); }

  .container { max-width:500px; margin:60px auto; background:white; border:1px solid #e6dfd3; padding:40px; border-radius:18px; box-shadow:0 10px 30px rgba(0,0,0,0.08); }
  
  /* TAB STYLE */
  .tab-menu { display:flex; margin-bottom:30px; border-bottom:2px solid var(--line); }
  .tab-btn { flex:1; text-align:center; padding:15px 0; font-size:16px; font-weight:700; color:#888; cursor:pointer; transition:0.2s; }
  .tab-btn.active { color:var(--main); border-bottom:3px solid var(--point); margin-bottom:-2px; }
  
  .tab-content { display:none; }
  .tab-content.active { display:block; }

  h2 { font-size:24px; margin-bottom:25px; color:var(--main); font-weight:900; text-align:center; }
  .input-group { margin-bottom:20px; }
  .input-group label { display:block; font-size:13px; font-weight:700; margin-bottom:8px; color:#555; }
  input { width:100%; height:48px; border:1px solid var(--line); border-radius:8px; padding:0 14px; font-size:14px; outline:none; }
  input:focus { border-color:var(--point); box-shadow:0 0 0 4px rgba(200,169,107,0.15); }
  
  .btn-submit { width:100%; height:50px; border:none; border-radius:10px; background:var(--main); color:white; font-size:15px; font-weight:700; cursor:pointer; margin-top:10px; transition:0.2s; }
  .btn-submit:hover { background:var(--point); color:var(--main); transform:translateY(-2px); }
  
  .link-wrap { text-align:center; margin-top:20px; font-size:13px; }
  .link-wrap a { color:#666; text-decoration:none; }
  .link-wrap a:hover { color:var(--point); text-decoration:underline; }
</style>
</head>
<body>

<header>
  <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
</header>

<div class="container">
  <!-- 상단 탭 스위치 버튼 -->
  <div class="tab-menu">
    <div class="tab-btn active" onclick="switchTab(0)">아이디 찾기</div>
    <div class="tab-btn" onclick="switchTab(1)">비밀번호 찾기</div>
  </div>

  <!-- 🆔 1. 아이디 찾기 폼 구역 -->
  <div id="tab-id" class="tab-content active">
    <h2>Find ID</h2>
   <form action="<%= request.getContextPath() %>/findAccountAction" method="post">
      <input type="hidden" name="findType" value="id">
      <div class="input-group">
        <label>성명 (국문)</label>
        <input type="text" name="name" placeholder="가입하신 성명을 입력해주세요" required>
      </div>
      <div class="input-group">
        <label>이메일 주소</label>
        <input type="email" name="email" placeholder="가입하신 이메일을 입력해주세요" required>
      </div>
      <button type="submit" class="btn-submit">아이디 찾기</button>
    </form>
  </div>

  <!-- 🔒 2. 비밀번호 찾기 폼 구역 -->
  <div id="tab-pw" class="tab-content">
    <h2>Find Password</h2>
   <form action="<%= request.getContextPath() %>/findAccountAction" method="post">
      <input type="hidden" name="findType" value="pw">
      <div class="input-group">
        <label>아이디</label>
        <input type="text" name="userid" placeholder="아이디를 입력해주세요" required>
      </div>
      <div class="input-group">
        <label>성명 (국문)</label>
        <input type="text" name="name" placeholder="가입하신 성명을 입력해주세요" required>
      </div>
      <div class="input-group">
        <label>이메일 주소</label>
        <input type="email" name="email" placeholder="가입하신 이메일을 입력해주세요" required>
      </div>
      <button type="submit" class="btn-submit">임시 비밀번호 발급</button>
    </form>
  </div>

  <div class="link-wrap">
    <a href="login.jsp">로그인 화면으로 돌아가기</a>
  </div>
</div>

<script>
// 탭 전환용 자바스크립트 함수
function switchTab(index) {
  const tabs = document.querySelectorAll('.tab-btn');
  const contents = document.querySelectorAll('.tab-content');
  
  tabs.forEach(tab => tab.classList.remove('active'));
  contents.forEach(content => content.classList.remove('active'));
  
  tabs[index].classList.add('active');
  contents[index].classList.add('active');
}
</script>
</body>
</html>
