<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    // 💡 보안 장치: 로그인이 안 된 사용자가 주소창에 직접 쳐서 들어오는 것을 막습니다.
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
        return; // 이하 JSP 코드 실행 중단
    }

    String ctx = request.getContextPath();

    // 데이터베이스 변수 선언
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott"; // ◀ 본인의 오라클 정보로 꼭 수정하세요!
    String dbPass = "tiger"; // ◀ 본인의 오라클 정보로 꼭 수정하세요!

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 회원의 상세 정보를 담을 변수들
    String email = "";
    String phone = "";
    String address = "";
    String birthdate = "";
    String gender = "";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 1. 세션 아이디에 해당하는 회원의 개인 정보 조회
        String userSql = "SELECT email, phone, address, birthdate, gender FROM member WHERE member_id = ?";
        pstmt = conn.prepareStatement(userSql);
        pstmt.setString(1, sessionUserId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            email = rs.getString("email");
            phone = rs.getString("phone");
            address = rs.getString("address");
            birthdate = rs.getString("birthdate");
            gender = rs.getString("gender");
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
<title>마이페이지 | JYP HOTEL</title>
<style>
  @import url("https://googleapis.com");

  :root {
    --main-blue: #111111;
    --point-blue: #c8a96b;
    --bg-gray: #f8f6f2;
    --text-dark: #222222;
    --line: #e6dfd3;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Noto Sans KR", sans-serif; }
  body { background-color: var(--bg-gray); color: var(--text-dark); }

  /* HEADER */
  header {
    display: flex; justify-content: space-between; align-items: center;
    padding: 15px 40px; background: #333; border-bottom:1px solid rgba(255,255,255,0.08);
    position: sticky; top: 0; z-index: 1000;
  }
  .logo { font-size: 1.5rem; font-weight: 900; color: white; text-decoration: none; letter-spacing: -1px; }
  .logo span { color: var(--point-blue); }
  nav ul { display: flex; list-style: none; gap: 20px; align-items: center; }
  nav ul li a { text-decoration: none; color:#f5f5f5; font-weight: 700; font-size: 14px; }
  nav ul li a:hover { color: var(--point-blue); }

  /* CONTAINER */
  .mypage-container {
    max-width: 1000px; margin: 50px auto 100px; display: flex; gap: 30px; padding: 0 20px;
  }

  /* SIDEBAR */
  .sidebar {
    width: 250px; background: white; border: 1px solid var(--line); padding: 30px 20px; border-radius: 12px; height: fit-content;
    box-shadow: 0 5px 15px rgba(0,0,0,0.04);
  }
  .welcome-box { text-align: center; padding-bottom: 25px; border-bottom: 1px solid var(--line); margin-bottom: 25px; }
  .welcome-box h3 { font-size: 18px; color: var(--main-blue); margin-bottom: 5px; }
  .welcome-box p { font-size: 13px; color: #777; }
  .menu-list { list-style: none; }
  .menu-list li { margin-bottom: 12px; }
  .menu-list li a { text-decoration: none; color: #555; font-size: 15px; font-weight: 700; display: block; padding: 10px 15px; border-radius: 6px; transition: 0.2s; }
  .menu-list li a.active, .menu-list li a:hover { background: var(--main-blue); color: var(--point-blue); }

  /* CONTENT AREA */
  .content-area { flex: 1; background: white; border: 1px solid var(--line); padding: 40px; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.04); }
  .section-title { font-size: 22px; font-weight: 900; color: var(--main-blue); margin-bottom: 25px; border-bottom: 2px solid var(--main-blue); padding-bottom: 10px; }

  /* INFO TABLE */
  .info-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; font-size: 14px; }
  .info-table th { width: 150px; text-align: left; padding: 15px; background: #fafafa; border-bottom: 1px solid var(--line); color: #555; }
  .info-table td { padding: 15px; border-bottom: 1px solid var(--line); color: #222; }

  /* RESERVATION LIST */
  .no-data { text-align: center; padding: 50px 0; color: #999; font-size: 15px; }
  
  /* FOOTER */
  footer { background: #333; color: #ccc; padding: 30px 20px; text-align: center; font-size: 13px; margin-top: auto; }
</style>
</head>
<body>

  <header>
    <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
    <nav>
      <ul>
        <li><a href="index.jsp">메인으로</a></li>
        <li><span style="color:var(--point-blue); font-weight:700;"><%= sessionUserName %>님 환영합니다</span></li>
        <li><a href="logout.jsp" style="color:#aaa; font-weight:400; margin-left:10px;">로그아웃</a></li>
      </ul>
    </nav>
  </header>

  <div class="mypage-container">
    <!-- 사이드바 메뉴 구역 -->
   <aside class="sidebar">
      <div class="welcome-box">
        <h3><%= sessionUserName %> 님</h3>
        <p>ID: <%= sessionUserId %></p>
      </div>
      <ul class="menu-list">
        <li><a href="myPage.jsp" class="active">내 정보 관리</a></li>
        <li><a href="memberModify.jsp">회원정보 수정</a></li>
      
        <li><a href="changePassword.jsp">비밀번호 변경</a></li>
        <li><a href="#">예약 내역 조회</a></li>
      </ul>
    </aside>

    <!-- 메인 콘텐트 구역 -->
    <main class="content-area">
      <!-- 1. 내 정보 관리 섹션 -->
      <h2 class="section-title">내 정보 관리</h2>
      <table class="info-table">
        <tr>
          <th>성명</th>
          <td><%= sessionUserName %> (<%= gender %>)</td>
        </tr>
        <tr>
          <th>생년월일</th>
          <td><%= birthdate %></td>
        </tr>
        <tr>
          <th>이메일 주소</th>
          <td><%= email %></td>
        </tr>
        <tr>
          <th>휴대전화</th>
          <td><%= phone %></td>
        </tr>
        <tr>
          <th>자택주소</th>
          <td><%= address %></td>
        </tr>
      </table>

      <!-- 2. 예약 내역 섹션 (맛보기용 틀 구현) -->
      <h2 class="section-title">최근 객실 예약 내역</h2>
      <div class="no-data">
        현재 이용 예정이거나 완료된 예약 내역이 존재하지 않습니다.
      </div>
    </main>
  </div>

  <footer>
    <p>&copy; 2026 JYP HOTEL. All rights reserved.</p>
  </footer>

</body>
</html>
