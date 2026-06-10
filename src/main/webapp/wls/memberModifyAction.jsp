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

    // 1. 수정 폼에서 입력한 파라미터 수집
    String nameKo = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String password = request.getParameter("password"); // 검증용 비밀번호 평문

    // 2. 입력받은 비밀번호를 가입 때와 동일한 해시값으로 변환
    String encryptedPw = encryptSHA256(password);

    // 3. 오라클 데이터베이스 연결 정보 설정 (★본인 환경에 맞게 꼭 수정★)
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 4. 입력한 현재 비밀번호가 기존 DB 내용과 진짜 일치하는지 조회
        String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, sessionUserId);
        pstmt.setString(2, encryptedPw); // ◀ 암호화된 비밀번호 대조
        rs = pstmt.executeQuery();
        
        int count = 0;
        if(rs.next()) {
            count = rs.getInt(1);
        }
        
        if (count == 0) {
            // 비밀번호를 잘못 입력했을 경우
            out.print("<script>alert('비밀번호가 일치하지 않습니다. 다시 입력해 주세요.'); history.back();</script>");
            return;
        }
        
        // 5. 검증 통과 시 회원 정보 수정(UPDATE) 쿼리 실행
        if (pstmt != null) pstmt.close(); // 기존 자원 해제
        
        String updateSql = "UPDATE member SET member_name = ?, member_email = ?, member_phone = ?, member_address = ? WHERE member_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, nameKo);
        pstmt.setString(2, email);
        pstmt.setString(3, phone);
        pstmt.setString(4, address);
        pstmt.setString(5, sessionUserId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            // 수정에 성공하면 상단 헤더의 이름 출력을 위해 세션UserName 변수도 즉시 업데이트
            session.setAttribute("sessionUserName", nameKo);
            out.print("<script>alert('회원 정보가 성공적으로 변경되었습니다.'); location.href='myPage.jsp';</script>");
        } else {
            out.print("<script>alert('정보 수정에 실패했습니다. 다시 시도해 주세요.'); history.back();</script>");
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
