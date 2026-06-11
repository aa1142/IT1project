<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%!
    // 💡 500 컴파일 에러 및 문자열 깨짐을 완벽하게 해결한 SHA-256 메서드
    public String encryptSHA256(String base) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(base.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();

            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0'); // ◀ StringBuilder에 정확하게 '0' 추가
                }
                hexString.append(hex);
            }
            return hexString.toString(); // 64글자 난수 리턴
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    try {
        String userid = request.getParameter("userid");
        String userpw = request.getParameter("password"); // 폼에서 입력한 비번
        String nameKo = request.getParameter("name");
        
        // 🛠️ 오라클 제약조건(010-XXXX-XXXX) 통과를 위한 완벽 공백 제거 및 결합 코드
        String phone1 = request.getParameter("phone1");
        String phone2 = request.getParameter("phone2");
        String phone3 = request.getParameter("phone3");
        
        // 값이 비어있을 경우를 대비한 방어 코드
        if(phone1 == null || phone1.trim().equals("")) phone1 = "010";
        if(phone2 == null || phone2.trim().equals("")) phone2 = "0000";
        if(phone3 == null || phone3.trim().equals("")) phone3 = "0000";
        
        // 💡 핵심: trim()을 통해 양쪽 공백을 완전히 지우고 바짝 붙여 13자리를 만듭니다.
        String phone = phone1.trim() + "-" + phone2.trim() + "-" + phone3.trim();


        String addressMain = request.getParameter("address");
        String addressDetail = request.getParameter("address_detail");
        String address = (addressMain != null ? addressMain : "") + " " + (addressDetail != null ? addressDetail : "");
        String email = request.getParameter("email");

        // 💡 중요: 입력받은 평문 비밀번호를 64글자 해시 난수로 변환
        String encryptedPw = encryptSHA256(userpw);

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott"; // ◀ 보내주신 에러창 스키마 기준 매핑                 
        String dbPass = "tiger"; // ◀ 본인의 오라클 비밀번호로 수정

        Connection conn = null;
        PreparedStatement pstmt = null;

        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 오라클 신규 테이블 구조 스키마 바인딩
        String sql = "INSERT INTO member (member_id, member_pw, member_name, member_phone, member_grade, member_email, member_address) VALUES (?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, userid);
        pstmt.setString(2, encryptedPw); // ◀ 64글자 암호화 문자열 바인딩
        pstmt.setString(3, nameKo != null ? nameKo : "미입력");
        pstmt.setString(4, phone);
        pstmt.setString(5, "일반"); // 기본 등급 일반 세팅
        pstmt.setString(6, email != null ? email : "test@test.com");
        pstmt.setString(7, address);

        int result = pstmt.executeUpdate();

        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();

        if (result > 0) {
            response.sendRedirect("signupSuccess.jsp?name=" + java.net.URLEncoder.encode(nameKo, "UTF-8"));
        } else {
            out.print("<script>alert('회원가입 실패'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<div style='padding:20px; background:#fff0f0; border:1px solid #ffcccc; color:#d93025; margin:50px;'>");
        out.print("<h3>⚠️ 회원가입 처리 중 백엔드 에러 발생!</h3>");
        out.print("<pre>" + e.toString() + "</pre>");
        out.print("</div>");
    }
%>
