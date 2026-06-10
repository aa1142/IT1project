<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%!
    // 비밀번호 SHA-256 해시 암호화 메서드 (오타 정돈 완료)
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

    try {
        // 1. 프론트엔드 폼 데이터 수집
        String userid = request.getParameter("userid");
        String userpw = request.getParameter("password");
        String nameKo = request.getParameter("name");
        String gender = request.getParameter("gender");
        String birthdate = request.getParameter("birthdate");
        String email = request.getParameter("email");
        
        // 휴대전화 번호 조각 결합
        String phone1 = request.getParameter("phone1");
        String phone2 = request.getParameter("phone2");
        String phone3 = request.getParameter("phone3");
        if(phone1 == null) phone1 = "010";
        if(phone2 == null) phone2 = "0000";
        if(phone3 == null) phone3 = "0000";
        String phone = phone1.trim() + "-" + phone2.trim() + "-" + phone3.trim();

        String addressMain = request.getParameter("address");
        String addressDetail = request.getParameter("address_detail");
        String address = (addressMain != null ? addressMain : "") + " " + (addressDetail != null ? addressDetail : "");

        // 2. 비밀번호 암호화
        String encryptedPw = encryptSHA256(userpw);

        // 3. 오라클 데이터베이스 연결 정보 설정 (★본인 환경에 맞게 꼭 수정★)
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;

        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 새로 변경된 테이블 컬럼 목록 매칭
        String sql = "INSERT INTO member (member_id, member_pw, member_name, member_phone, member_grade, member_email, member_address) VALUES (?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, userid);
        pstmt.setString(2, encryptedPw);
        pstmt.setString(3, nameKo != null ? nameKo : "미입력");
        pstmt.setString(4, phone); // ◀ 오라클 제약조건 검증 타깃
        pstmt.setString(5, "일반");
        pstmt.setString(6, email != null ? email : "test@test.com");
        pstmt.setString(7, address);

        int result = pstmt.executeUpdate();

        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();

        if (result > 0) {
            response.sendRedirect("signupSuccess.jsp?name=" + java.net.URLEncoder.encode(nameKo, "UTF-8"));
        } else {
            out.print("<script>alert('회원가입에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        // 💡 하얀 화면을 강제로 깨부수고 진짜 자바/오라클 에러 내용을 출력합니다.
        e.printStackTrace();
        out.print("<div style='padding:20px; background:#fff0f0; border:1px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
        out.print("<h3>⚠️ 회원가입 처리 중 백엔드 에러 발생!</h3>");
        out.print("<pre>" + e.toString() + "</pre>");
        out.print("<p>이 영어 메시지를 알려주시면 문제를 단번에 해결해 드립니다.</p>");
        out.print("</div>");
    }
%>
