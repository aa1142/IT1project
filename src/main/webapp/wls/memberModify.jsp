<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 💡 [백엔드 최적화]: 이제 자바 서블릿(MemberModifyServlet)이 오라클 DB 데이터를 대신 조회해서 배달해 줍니다!
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='" + request.getContextPath() + "/wls/login.jsp';</script>");
        return;
    }

    // 서블릿이 request 상자에 담아 보낸 데이터들을 안전하게 낚아챕니다.
    String nameKo = (String) request.getAttribute("name");
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");
    String address = (String) request.getAttribute("address");

    // 혹시라도 서블릿을 거치지 않고 주소창에 직접 쳐서 들어왔을 때를 대비한 방어 코드
    if (nameKo == null) {
        out.print("<script>location.href='" + request.getContextPath() + "/memberModifyAction';</script>");
        return;
    }
%>
<!doctype html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>회원정보 수정 | JYP HOTEL</title>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<style>
  @import url("https://googleapis.com");
  :root { --main: #111111; --point: #c8a96b; --line: #e6dfd3; --bg: #f8f6f2; }
  * { margin:0; padding:0; box-sizing:border-box; font-family:"Noto Sans KR",sans-serif; }
  body { background: var(--bg); }
  header { height:80px; background:#333; display:flex; align-items:center; padding:0 40px; }
  .logo { font-size:28px; font-weight:900; color:white; text-decoration:none; }
  .logo span { color:var(--point); }
  .container { max-width:800px; margin:50px auto; background:white; border:1px solid #e6dfd3; padding:50px; border-radius:18px; }
  table { width:100%; border-collapse:collapse; margin-bottom:30px; }
  th { width:180px; text-align:left; padding:18px 14px; background:#fafafa; border-bottom:1px solid var(--line); }
  td { padding:16px 14px; border-bottom:1px solid var(--line); }
  input { height:46px; border:1px solid var(--line); border-radius:8px; padding:0 14px; width:100%; outline:none; }
  
  /* 💡 [주소창 버그 해결 핵심 CSS 구역] */
  .inline { display:flex; gap:10px; align-items:center; }
  .inline input { flex: 1; min-width: 0; } /* ◀ 입력창이 남은 가로 공간을 채우고 절대 버튼을 밀지 못하게 방어합니다 */
  
 
  .btn { 
    height:46px; 
    padding:0 16px; 
    background:var(--main); 
    color:#fff; 
    border:none; 
    border-radius:8px; 
    cursor:pointer; 
    white-space: nowrap; 
    font-size: 14px;
    font-weight: 500;
  }
  
  .submit-wrap { text-align:center; display:flex; justify-content:center; gap:15px; }
  .btn-submit { width:200px; height:50px; border:none; border-radius:10px; font-weight:700; cursor:pointer; }
  .btn-save { background: var(--main); color:white; }
  .btn-cancel { background: #ece7dd; }
</style>
</head>
<body>
<!-- 🛠️ 교정: 상단 헤더 클릭 시 일반 wls 폴더 내부 메인으로 정확히 유도 -->
<header><a href="<%= request.getContextPath() %>/wls/index.jsp" class="logo">JYP <span>HOTEL</span></a></header>
<div class="container">
  <h2>회원정보 수정</h2>
  <form action="<%= request.getContextPath() %>/memberModifyAction" method="post" onsubmit="return validateForm()">
    <table>
      <tr><th>아이디</th><td><input type="text" value="<%= sessionUserId %>" readonly style="background:#eee;"></td></tr>
      <tr><th>성명</th><td><input type="text" name="name" value="<%= nameKo %>"></td></tr>
      <tr><th>이메일</th><td><input type="text" name="email" value="<%= email %>"></td></tr>
      <tr><th>휴대전화</th><td><input type="text" name="phone" value="<%= phone %>"></td></tr>
      <tr><th>자택주소</th><td><div class="inline"><input type="text" id="address" name="address" value="<%= address %>" readonly><button type="button" class="btn" onclick="openAddressSearch()">주소찾기</button></div></td></tr>
      <tr><th>비밀번호 확인</th><td><input type="password" name="password" id="password" placeholder="현재 비밀번호를 입력하세요"></td></tr>
    </table>
    <div class="submit-wrap"><button type="submit" class="btn-submit btn-save">수정 완료</button><button type="button" class="btn-submit btn-cancel" onclick="history.back()">취소</button></div>
  </form>
</div>
<script>
function openAddressSearch() { new daum.Postcode({ oncomplete: function(data) { document.getElementById("address").value = data.address; } }).open(); }
function validateForm() {
  if(document.querySelector("input[name='name']").value.trim()==="") { alert("성명을 입력하세요."); return false; }
  if(document.getElementById("password").value.trim()==="") { alert("비밀번호를 입력하세요."); return false; }
  return true;
}
</script>
</body>
</html>
