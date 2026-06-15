<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List, java.util.Map" %>
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

    // 💡 서블릿이 배달한 예약 내역 리스트 상자를 꺼냅니다.
    List<Map<String, String>> reserveList = (List<Map<String, String>>) request.getAttribute("reserveList");
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
  .sidebar { width: 250px; background: white; border: 1px solid var(--line); padding: 30px 20px; border-radius: 12px; height: fit-content; }
  .welcome-box { text-align: center; padding-bottom: 25px; border-bottom: 1px solid var(--line); margin-bottom: 25px; }
  .menu-list { list-style: none; }
  .menu-list li a { text-decoration: none; color: #555; font-size: 15px; font-weight: 700; display: block; padding: 10px 15px; border-radius: 6px; }
  .menu-list li a.active, .menu-list li a:hover { background: var(--main); color: var(--point); }
  .content-area { flex: 1; background: white; border: 1px solid var(--line); padding: 40px; border-radius: 12px; }
  .section-title { font-size: 22px; font-weight: 900; color: var(--main); margin-bottom: 25px; border-bottom: 2px solid var(--main); padding-bottom: 10px; }
  
  /* 기존 내 정보 테이블 스타일 */
  .info-table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }
  .info-table th { width: 150px; text-align: left; padding: 15px; background: #fafafa; border-bottom: 1px solid var(--line); }
  .info-table td { padding: 15px; border-bottom: 1px solid var(--line); }
  
  /* 💡 [새로 추가한 객실 예약 내역 테이블용 명품 디자인 선언] */
  .reserve-table { width: 100%; border-collapse: collapse; text-align: center; margin-top: 15px; font-size: 14px; }
  .reserve-table th { background: var(--main); color: white; padding: 12px; font-weight: 700; border: 1px solid #333; }
  .reserve-table td { padding: 14px 12px; border-bottom: 1px solid var(--line); color: #444; }
  .reserve-table tr:hover { background: #fafafa; }
  .no-data { padding: 40px !important; color: #999; font-style: italic; }
  
  /* 상태값 배지 양식 디자인 */
  .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
  .badge-success { background: #e6f4ea; color: #137333; } /* 예약 완료 */
  .badge-cancel { background: #fce8e6; color: #c5221f; }  /* 예약 취소 */
  
  footer { background: #333; color: #ccc; padding: 30px 20px; text-align: center; font-size: 13px; }
</style>
</head>
<body>
  <header>
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="logo">JYP <span>HOTEL</span></a>
    <nav>
      <ul>
        <li><a href="<%= request.getContextPath() %>/wls/index.jsp">메인으로</a></li>
        <li><a href="<%= request.getContextPath() %>/logoutAction">로그아웃</a></li>
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
        <li><a href="<%= request.getContextPath() %>/myPage" class="active">내 정보 관리</a></li>
        <li><a href="<%= request.getContextPath() %>/memberModifyAction">회원정보 수정</a></li>
        <li><a href="<%= request.getContextPath() %>/changePasswordAction">비밀번호 변경</a></li>
        <li><a href="#" onclick="deleteAccount()" style="color:#d93025;">회원 탈퇴</a></li>
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
      
    
      <h2 class="section-title" style="margin-top: 20px;">최근 객실 예약 내역</h2>
      <table class="reserve-table">
        <thead>
          <tr>
            <th>예약번호</th>
            <th>이용객실 이름</th>
            <th>체크인 일자</th>
            <th>체크아웃 일자</th>
            <th>예약상태</th>
          </tr>
        </thead>
        <tbody>
        <% if (reserveList == null || reserveList.isEmpty()) { %>
        
          <tr><td colspan="5" class="no-data">아직 호텔 예약 내역이 존재하지 않습니다.</td></tr>
        <% } else { 
             for (Map<String, String> reserve : reserveList) { 
               String status = reserve.get("status");
               if (status == null) status = "예약완료";
               
               // 상태가 취소면 빨간배지, 완료면 초록배지 부여
               String badgeClass = "취소".contains(status) ? "badge-cancel" : "badge-success";
        %>
          <tr>
            <td><%= reserve.get("no") %></td>
            <td style="font-weight:700; color:var(--main);"><%= reserve.get("room") %></td>
            <td><%= reserve.get("in") %></td>
            <td><%= reserve.get("out") %></td>
            <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
          </tr>
        <%   } 
           } %>
        </tbody>
      </table>
    </main>
  </div>
  <footer><p>&copy; 2026 JYP HOTEL. All rights reserved.</p></footer>

<script>
function deleteAccount() {
  if (confirm("정말로 JYP HOTEL을 탈퇴하시겠습니까?\n탈퇴 시 모든 예약 내역과 정보가 삭제되며 복구할 수 없습니다.")) {
      location.href = "<%= request.getContextPath() %>/deleteAccountAction";
  }
}
</script>
</body>
</html>
