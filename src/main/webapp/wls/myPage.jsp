<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 💡 서블릿이 보낸 세션 정보와 request 데이터를 받아와서 변수에 정렬합니다.
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");
    String address = (String) request.getAttribute("address");
    String grade = (String) request.getAttribute("grade");
    Integer count = (Integer) request.getAttribute("count");
    
    if(count == null) count = 0;
%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>마이페이지 | JYP HOTEL</title>
<style>
  @import url("https://googleapis.com");
  :root { --main: #111111; --point: #c8a96b; --bg: #f8f6f2; --text: #222222; --line: #e6dfd3; }
  * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Noto Sans KR", sans-serif; }
  body { background-color: var(--bg); color: var(--text); }
  header { display: flex; justify-content: space-between; align-items: center; padding: 15px 40px; background: #333; }
  .logo { font-size: 1.5rem; font-weight: 900; color: white; text-decoration: none; }
  .logo span { color: var(--point); }
  nav ul { display: flex; list-style: none; gap: 20px; }
  nav ul li a { text-decoration: none; color:#f5f5f5; font-weight: 700; font-size: 14px; }
  .mypage-container { max-width: 1000px; margin: 50px auto; display: flex; gap: 30px; padding: 0 20px; }
  .sidebar { width: 250px; background: white; border: 1px solid var(--line); padding: 30px 20px; border-radius: 12px; }
  .welcome-box { text-align: center; padding-bottom: 25px; border-bottom: 1px solid var(--line); margin-bottom: 25px; }
  .menu-list { list-style: none; }
  .menu-list li a { text-decoration: none; color: #555; font-size: 15px; font-weight: 700; display: block; padding: 10px 15px; border-radius: 6px; }
  .menu-list li a.active, .menu-list li a:hover { background: var(--main); color: var(--point); }
  .content-area { flex: 1; background: white; border: 1px solid var(--line); padding: 40px; border-radius: 12px; }
  .section-title { font-size: 22px; font-weight: 900; color: var(--main); margin-bottom: 25px; border-bottom: 2px solid var(--main); padding-bottom: 10px; }
  .info-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
  .info-table th { width: 150px; text-align: left; padding: 15px; background: #fafafa; border-bottom: 1px solid var(--line); }
  .info-table td { padding: 15px; border-bottom: 1px solid var(--line); }
  footer { background: #333; color: #ccc; padding: 30px 20px; text-align: center; font-size: 13px; }
</style>
</head>
<body>
  <header>
    <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
    <nav>
      <ul>
        <li><a href="index.jsp">메인으로</a></li>
        <li><a href="logout.jsp">로그아웃</a></li>
      </ul>
    </nav>
  </header>
  <div class="mypage-container">
    <aside class="sidebar">
      <div class="welcome-box">
        <h3><%= sessionUserName %> 님</h3>
        <p>등급: <span style="color:var(--point); font-weight:bold;"><%= grade %></span></p>
      </div>
      <ul class="menu-list">
        <li><a href="myPage.jsp" class="active">내 정보 관리</a></li>
        <li><a href="memberModify.jsp">회원정보 수정</a></li>
        <li><a href="<%= request.getContextPath() %>/changePasswordAction">비밀번호 변경</a></li>
        <li><a href="#" onclick="deleteAccount()" style="color:#d93025;">회원 탈퇴</a></li>
        <script>
// 회원 탈퇴 버튼을 눌렀을 때 발동하는 자바스크립트 함수
function deleteAccount() {
  if (confirm("정말로 JYP HOTEL을 탈퇴하시겠습니까?\n탈퇴 시 모든 예약 내역과 정보가 삭제되며 복구할 수 없습니다.")) {
	  location.href = "<%= request.getContextPath() %>/deleteAccountAction";
  }
}
</script>
      </ul>
    </aside>
    <main class="content-area">
      <h2 class="section-title">내 정보 관리</h2>
      <table class="info-table">
        <tr><th>성명</th><td><%= sessionUserName %></td></tr>
        <tr><th>이메일 주소</th><td><%= email %></td></tr>
        <tr><th>휴대전화</th><td><%= phone %></td></tr>
        <tr><th>자택주소</th><td><%= address %></td></tr>
        <tr><th>누적 예약 횟수</th><td><%= count %>회</td></tr>
      </table>
    </main>
  </div>
  <footer><p>&copy; 2026 JYP HOTEL. All rights reserved.</p></footer>
</body>
</html>
