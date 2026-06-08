<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    // 한글 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    // 1. 로그인 폼 데이터 수집
    String userid = request.getParameter("userid");
    String userpw = request.getParameter("userpw");

    // 2. 오라클 데이터베이스 연결 정보 설정 (★본인 정보로 수정★)
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // SQL 쿼리문: 입력한 아이디와 비밀번호가 동시에 일치하는 회원의 이름을 조회
        String sql = "SELECT name_ko FROM member WHERE member_id = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userid.trim());
        pstmt.setString(2, userpw.trim());

        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 💡 [로그인 성공] 
            String nameKo = rs.getString("name_ko");
            
            // 세션(Session)에 유저 아이디와 이름을 저장하여 로그인 상태 유지
            session.setAttribute("sessionUserId", userid);
            session.setAttribute("sessionUserName", nameKo);
            
            // 로그인 성공 팝업 후 메인페이지로 이동
            out.print("<script>");
            out.print("alert('" + nameKo + "님, 환영합니다! JYP HOTEL 로그인에 성공했습니다.');");
            out.print("location.href='index.jsp';"); // 💡 본인의 메인페이지 파일명으로 수정하세요
            out.print("</script>");
        } else {
            // 💡 [로그인 실패] 아이디나 비밀번호가 틀림
            out.print("<script>");
            out.print("alert('아이디 또는 비밀번호가 일치하지 않습니다.');");
            out.print("history.back();");
            out.print("</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<script>");
        out.print("alert('서버 오류 발생: " + e.getMessage() + "');");
        out.print("history.back();");
        out.print("</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
