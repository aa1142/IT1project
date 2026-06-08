<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %><%@ page import="java.sql.*" %><%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userid = request.getParameter("userid");

    if(userid == null || userid.trim().equals("")) {
        out.print("empty");
        return;
    }

    // ⚠️ 본인의 실제 오라클 정보로 수정하세요
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "SELECT COUNT(*) FROM member WHERE member_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userid.trim());

        rs = pstmt.executeQuery();

        if (rs.next()) {
            int count = rs.getInt(1);
            if (count == 0) {
                out.print("usable");     
            } else {
                out.print("duplicated"); 
            }
        }
    } catch (Exception e) {
        // 💡 중요: 서버 오류 메시지 대신, 어떤 에러가 났는지 브라우저 화면으로 직접 출력합니다.
        e.printStackTrace(); // 이클립스 콘솔 출력
        out.print("실제 발생한 에러 원인: " + e.toString()); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
