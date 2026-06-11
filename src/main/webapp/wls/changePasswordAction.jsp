<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%!
    // 💡 평문 비밀번호를 SHA-256 해시값으로 변환해주는 검증 완료된 자바 메서드
    public String encryptSHA256(String base) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(base.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
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

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('인증이 만료되었습니다. 다시 로그인해 주세요.'); location.href='login.jsp';</script>");
        return;
    }

    // 1. 파라미터 수집 (현재 비밀번호, 새 비밀번호)
    String currentPw = request.getParameter("currentPw");
    String newPw = request.getParameter("newPw");

    // 2. 검증 및 변경을 위해 현재 비밀번호와 새 비밀번호를 모두 암호화 처리
    String encryptedCurrentPw = encryptSHA256(currentPw);
    String encryptedNewPw = encryptSHA256(newPw);

    
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 3. 새 테이블 컬럼 규칙(member_id, member_pw)에 맞춰 기존 비밀번호가 맞는지 검증
        String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, sessionUserId);
        pstmt.setString(2, encryptedCurrentPw); // ◀ 암호화된 현재 비밀번호 대조
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
        
        // 4. 검증 통과 시 새 비밀번호로 수정(UPDATE) 실행
        if (pstmt != null) pstmt.close(); // 기존 자원 해제
        
        String updateSql = "UPDATE member SET member_pw = ? WHERE member_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, encryptedNewPw); // ◀ 암호화된 새 비밀번호 꽂아넣기
        pstmt.setString(2, sessionUserId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            out.print("<script>alert('비밀번호가 안전하게 변경되었습니다. 새로운 비밀번호로 다시 로그인해 주세요.'); location.href='myPage.jsp';</script>");
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
