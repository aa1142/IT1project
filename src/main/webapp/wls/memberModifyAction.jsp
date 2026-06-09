<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId == null) {
        out.print("<script>alert('인증이 만료되었습니다. 다시 로그인해 주세요.'); location.href='login.jsp';</script>");
        return;
    }

    // 1. 수정 폼 파라미터 수집
    String nameKo = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String password = request.getParameter("password"); // 비밀번호 검증용

    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott"; // ◀ 본인 계정으로 수정
    String dbPass = "tiger"; // ◀ 본인 계정으로 수정

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // 2. 우선 입력한 비밀번호가 계정과 진짜 맞는지 1차 로그인식 검증
        String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND password = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setString(1, sessionUserId);
        pstmt.setString(2, password.trim());
        rs = pstmt.executeQuery();
        
        int count = 0;
        if(rs.next()) {
            count = rs.getInt(1);
        }
        
        if (count == 0) {
            // 비밀번호 불일치 시 튕겨내기
            out.print("<script>alert('비밀번호가 일치하지 않습니다. 다시 입력해 주세요.'); history.back();</script>");
            return;
        }
        
        // 3. 비밀번호가 맞다면 정보 수정(UPDATE) 쿼리 실행
        if (pstmt != null) pstmt.close(); // 기존 자원 닫기
        
        String updateSql = "UPDATE member SET name_ko = ?, email = ?, phone = ?, address = ? WHERE member_id = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, nameKo);
        pstmt.setString(2, email);
        pstmt.setString(3, phone);
        pstmt.setString(4, address);
        pstmt.setString(5, sessionUserId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            // 수정 완료 시 이름 변경사항을 세션에도 즉시 동기화 반영
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
