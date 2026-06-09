<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('인증이 만료되었습니다. 다시 로그인해 주세요.'); location.href='login.jsp';</script>");
        return;
    }

    // 1. 파라미터 수집
    String currentPw = request.getParameter("currentPw");
    String newPw = request.getParameter("newPw");

    
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 2. 현재 비밀번호가 기존 DB 내용과 진짜 일치하는지 카운트 조회
        String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND password = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, sessionUserId);
        pstmt.setString(2, currentPw.trim());
        rs = pstmt.executeQuery();
        
        int count = 0;
        if(rs.next()) {
            count = rs.getInt(1);
        }
        
        if (count == 0) {
            // 현재 비밀번호를 틀리게 적었을 경우 차단
            out.print("<script>alert('현재 비밀번호가 일치하지 않습니다.'); history.back();</script>");
            return;
        }
        
        // 3. 일치 검증 통과 시 비밀번호 변경(UPDATE) 실행
        if (pstmt != null) pstmt.close();
        
        String updateSql = "UPDATE member SET password = ? WHERE member_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, newPw.trim());
        pstmt.setString(2, sessionUserId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            out.print("<script>alert('비밀번호가 안전하게 변경되었습니다. 새로운 비밀번호로 로그인해 주세요.'); location.href='myPage.jsp';</script>");
        } else {
            out.print("<script>alert('비밀번호 변경에 실패했습니다. 다시 시도해 주세요.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<script>alert('서버 오류 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
