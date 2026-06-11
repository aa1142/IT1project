<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%!
    // 💡 평문 비밀번호를 SHA-256 해시값으로 변환해주는 메서드 (회원가입시 알고리즘과 완벽히 잃치해야함)
    public String encryptSHA256(String base) {
    try {
        java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(base.getBytes("UTF-8"));
        StringBuilder hexString = new StringBuilder();

        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0'); // ◀ 에러 해결 포인트!
            }
            hexString.append(hex);
        }
        return hexString.toString(); 
    } catch (Exception ex) {
        throw new RuntimeException(ex);
    }
}

%>
<%
    request.setCharacterEncoding("UTF-8");

    String userid = request.getParameter("userid");
    String userpw = request.getParameter("userpw");

    // 💡 로그인 검증을 위해 입력 창 비밀번호를 똑같이 해시 암호화
    String encryptedPw = encryptSHA256(userpw);

    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 💡 변경된 오라클 컬럼 이름 매칭 반영 (member_name, member_id, member_pw)
        String sql = "SELECT member_name FROM member WHERE member_id = ? AND member_pw = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userid.trim());
        pstmt.setString(2, encryptedPw); // ◀ 암호화된 비밀번호와 대조!

        rs = pstmt.executeQuery();

        if (rs.next()) {
            String memberName = rs.getString("member_name");
            
            // 세션 기록 유지
            session.setAttribute("sessionUserId", userid);
            session.setAttribute("sessionUserName", memberName);
            
            out.print("<script>");
            out.print("alert('" + memberName + "님, 환영합니다! JYP HOTEL 로그인에 성공했습니다.');");
            out.print("location.href='index.jsp';"); 
            out.print("<" + "/script>"); // 문자열 깨짐 방지 파싱
        } else {
            out.print("<script>alert('아이디 또는 비밀번호가 일치하지 않습니다.'); history.back();</script>");
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
