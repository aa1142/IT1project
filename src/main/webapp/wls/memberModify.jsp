<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
        return;
    }

    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott"; // ◀ 본인 정보 수정
    String dbPass = "tiger"; // ◀ 본인 정보 수정

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String nameKo = "";
    String email = "";
    String phone = "";
    String address = "";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 💡 쿼리문 컬럼명 수정 완료
        String sql = "SELECT member_name, member_email, member_phone, member_address FROM member WHERE member_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sessionUserId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            nameKo = rs.getString("member_name");
            email = rs.getString("member_email");
            phone = rs.getString("member_phone");
            address = rs.getString("member_address");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
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
  .inline { display:flex; gap:10px; }
  .btn { height:46px; padding:0 18px; background:var(--main); color:#fff; border:none; border-radius:8px; cursor:pointer; }
  .submit-wrap { text-align:center; display:flex; justify-content:center; gap:15px; }
  .btn-submit { width:200px; height:50px; border:none; border-radius:10px; font-weight:700; cursor:pointer; }
  .btn-save { background: var(--main); color:white; }
  .btn-cancel { background: #ece7dd; }
</style>
</head>
<body>
<header><a href="index.jsp" class="logo">JYP <span>HOTEL</span></a></header>
<div class="container">
  <h2>회원정보 수정</h2>
  <form action="memberModifyAction.jsp" method="post" onsubmit="return validateForm()">
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
