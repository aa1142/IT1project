<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // ⚠️ 오류 추적용 변수 선언
    try {
        String gender = request.getParameter("gender");
        String nameKo = request.getParameter("name");
        String birthdate = request.getParameter("birthdate");
        String email = request.getParameter("email");
        
        // 💡 안전장치: HTML에 name이 없어도 에러가 나지 않도록 기본값 처리
        String phone1 = request.getParameter("phone1");
        String phone2 = request.getParameter("phone2");
        String phone3 = request.getParameter("phone3");
        
        if(phone1 == null) phone1 = "010";
        if(phone2 == null || phone2.trim().equals("")) phone2 = "0000";
        if(phone3 == null || phone3.trim().equals("")) phone3 = "0000";
        String phone = phone1 + "-" + phone2 + "-" + phone3;

        String addressMain = request.getParameter("address");
        String addressDetail = request.getParameter("address_detail");
        String address = (addressMain != null ? addressMain : "") + " " + (addressDetail != null ? addressDetail : "");

        String userid = request.getParameter("userid");
        String userpw = request.getParameter("password");

        // ⚠️ 본인의 실제 오라클 정보로 꼭 수정하세요!
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;

        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String sql = "INSERT INTO member (member_id, password, name_ko, gender, birthdate, email, phone, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        
        pstmt.setString(1, userid);
        pstmt.setString(2, userpw);
        pstmt.setString(3, nameKo != null ? nameKo : "미입력");
        pstmt.setString(4, gender != null ? gender : "남");
        pstmt.setString(5, birthdate != null && !birthdate.equals("") ? birthdate : "2000-01-01");
        pstmt.setString(6, email != null ? email : "test@test.com");
        pstmt.setString(7, phone);
        pstmt.setString(8, address);

        int result = pstmt.executeUpdate();

        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();

     // 🛠️ signupAction.jsp 내부 코드 교체 부분

        if (result > 0) {
            // 💡 저장 성공 시 사용자의 국문 이름(nameKo)을 주소창에 달아서 성공 페이지로 보냅니다.
            response.sendRedirect("signupSuccess.jsp?name=" + java.net.URLEncoder.encode(nameKo, "UTF-8"));
        } else {
            out.print("<script>alert('회원가입에 실패했습니다. 다시 시도해주세요.'); history.back();</script>");
        }


    } catch (Exception e) {
        // 💡 하얀 화면 대신 진짜 자바 에러 로그를 브라우저에 그대로 출력합니다.
        e.printStackTrace();
        out.print("<div style='padding:20px; background:#fff0f0; border:1px solid #ffcccc; color:#d93025; margin:50px;'>");
        out.print("<h3>⚠️ 백엔드 자바 에러 발생!</h3>");
        out.print("<pre>" + e.toString() + "</pre>");
        out.print("<p>이 문장을 복사해서 알려주시면 바로 해결해 드립니다.</p>");
        out.print("</div>");
    }
%>
