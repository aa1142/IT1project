<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    // 로그인 보안 검증
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
        return;
    }

    // 오라클 데이터베이스 연결 정보 설정
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott"; // ◀ 본인 계정으로 수정
    String dbPass = "tiger"; // ◀ 본인 계정으로 수정

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 기존 데이터 로딩용 변수
    String nameKo = "";
    String email = "";
    String phone = "";
    String address = "";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 기존 회원 정보 가져오기
        String sql = "SELECT name_ko, email, phone, address FROM member WHERE member_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sessionUserId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            nameKo = rs.getString("name_ko");
            email = rs.getString("email");
            phone = rs.getString("phone");
            address = rs.getString("address");
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
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>회원정보 수정 | JYP HOTEL</title>
<!-- 카카오 주소 API 외부 스크립트 -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
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
  
  header { height:80px; background:#333; display:flex; align-items:center; justify-content:space-between; padding:0 40px; border-bottom:1px solid #eee; }
  .logo { font-size:28px; font-weight:900; color:white; text-decoration:none; }
  .logo span { color:var(--point); }

  .container { max-width:800px; margin:50px auto 80px; background:white; border:1px solid #e6dfd3; padding:50px; border-radius:18px; box-shadow:0 10px 30px rgba(0,0,0,0.08); }
  h2 { font-size:30px; margin-bottom:30px; color:var(--main); font-weight:900; }
  
  table { width:100%; border-collapse:collapse; font-size:14px; margin-bottom:30px; }
  th { width:180px; text-align:left; padding:18px 14px; background:#fafafa; border-bottom:1px solid var(--line); }
  td { padding:16px 14px; border-bottom:1px solid var(--line); }
  
  input { height:46px; border:1px solid var(--line); border-radius:8px; padding:0 14px; font-size:14px; outline:none; width:100%; }
  input:focus { border-color:var(--point); box-shadow:0 0 0 4px rgba(200,169,107,0.15); }
  input[readonly] { background-color: #f5f5f5; cursor: not-fit; }

  .inline { display:flex; gap:10px; align-items:center; }
  .btn { height:46px; padding:0 18px; border:none; border-radius:8px; background:var(--main); color:#fff; font-size:13px; font-weight:700; cursor:pointer; transition:0.2s; white-space:nowrap; }
  .btn:hover { background:var(--point); color:var(--main); }
  
  .submit-wrap { text-align:center; display:flex; justify-content:center; gap:15px; }
  .btn-submit { width:200px; height:50px; border:none; border-radius:10px; font-size:15px; font-weight:700; cursor:pointer; transition:0.2s; }
  .btn-save { background: var(--main); color:white; }
  .btn-save:hover { background: var(--point); color:var(--main); }
  .btn-cancel { background: #ece7dd; color:#111; }
  .btn-cancel:hover { background: #ddd; }
</style>
</head>
<body>

<header>
  <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
</header>

<div class="container">
  <h2>회원정보 수정</h2>
  
  <!-- 수정한 정보가 전송될 폼 태그 설정 -->
  <form action="memberModifyAction.jsp" method="post" onsubmit="return validateForm()">
    <table>
      <tr>
        <th>아이디</th>
        <td><input type="text" value="<%= sessionUserId %>" readonly style="color:#888;"></td>
      </tr>
      <tr>
        <th>성명 (국문)</th>
        <td><input type="text" name="name" value="<%= nameKo %>" placeholder="이름을 입력해주세요"></td>
      </tr>
      <tr>
        <th>이메일</th>
        <td><input type="text" name="email" value="<%= email %>" placeholder="이메일을 입력해주세요"></td>
      </tr>
      <tr>
        <th>휴대전화</th>
        <td><input type="text" name="phone" value="<%= phone %>" placeholder="전화번호를 입력해주세요"></td>
      </tr>
      <tr>
        <th>자택주소</th>
        <td>
          <div class="inline">
            <input type="text" id="address" name="address" value="<%= address %>" readonly placeholder="주소찾기를 이용해주세요">
            <button type="button" class="btn" onclick="openAddressSearch()">주소찾기</button>
          </div>
        </td>
      </tr>
      <tr>
        <th>비밀번호 확인</th>
        <td>
          <input type="password" name="password" id="password" placeholder="정보 수정을 위해 비밀번호를 입력해주세요">
          <span style="font-size:12px; color:#888; margin-top:5px; display:block;">* 안전한 정보 변경을 위해 현재 비밀번호 입력이 필요합니다.</span>
        </td>
      </tr>
    </table>
    
    <div class="submit-wrap">
      <button type="submit" class="btn-submit btn-save">수정 완료</button>
      <button type="button" class="btn-submit btn-cancel" onclick="history.back()">취소</button>
    </div>
  </form>
</div>

<script>
function openAddressSearch() {
  new daum.Postcode({
    oncomplete: function(data) {
      document.getElementById("address").value = data.address;
    }
  }).open();
}

function validateForm() {
  const name = document.querySelector("input[name='name']").value;
  const email = document.querySelector("input[name='email']").value;
  const phone = document.querySelector("input[name='phone']").value;
  const password = document.getElementById("password").value;

  if(name.trim() === "") { alert("성명을 입력해주세요."); return false; }
  if(email.trim() === "") { alert("이메일을 입력해주세요."); return false; }
  if(phone.trim() === "") { alert("전화번호를 입력해주세요."); return false; }
  if(password.trim() === "") { alert("비밀번호를 입력해주세요."); return false; }
  
  return true;
}
</script>
</body>
</html>
