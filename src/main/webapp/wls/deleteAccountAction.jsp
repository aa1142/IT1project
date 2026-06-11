<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    // 로그인 세션 확인
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
        return;
    }

    
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 💡 오라클 DB에서 현재 로그인한 유저의 행을 완전히 지워버리는 DELETE 쿼리
        String sql = "DELETE FROM member WHERE member_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, sessionUserId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            // 💡 중요: DB에서 지웠으므로 현재 로그인된 서버 메모리(세션)도 완전히 파괴합니다.
            session.invalidate();
            out.print("<script>alert('JYP HOTEL 회원 탈퇴가 정상적으로 처리되었습니다. 그동안 이용해 주셔서 감사합니다.'); location.href='index.jsp';</script>");
        } else {
            out.print("<script>alert('탈퇴 처리 중 오류가 발생했습니다. 다시 시도해 주세요.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<script>alert('서버 오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
