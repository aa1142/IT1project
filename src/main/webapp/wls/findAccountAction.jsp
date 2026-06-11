<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 어떤 찾기 요청인지 구분값 받기 (id 또는 pw)
    String findType = request.getParameter("findType");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String userid = request.getParameter("userid"); // pw 찾기 시 필수값

    // ⚠️ 중요: 본인의 오라클 계정 정보에 맞게 수정하세요!
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
    String dbUser = "scott";                 
    String dbPass = "tiger";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        if ("id".equals(findType)) {
            // 🆔 1. 아이디 찾기 쿼리 로직
            String sql = "SELECT member_id FROM member WHERE name_ko = ? AND email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name.trim());
            pstmt.setString(2, email.trim());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String foundId = rs.getString("member_id");
                out.print("<script>");
                out.print("alert('" + name + " 회원님의 아이디는 [" + foundId + "] 입니다.');");
                out.print("location.href='login.jsp';");
                out.print("</script>");
            } else {
                out.print("<script>alert('일치하는 회원 정보가 존재하지 않습니다.'); history.back();</script>");
            }

        } else if ("pw".equals(findType)) {
            // 🔒 2. 비밀번호 찾기 (간이 초기화 및 노출) 로직
            String sql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND name_ko = ? AND email = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid.trim());
            pstmt.setString(2, name.trim());
            pstmt.setString(3, email.trim());
            rs = pstmt.executeQuery();

            int count = 0;
            if(rs.next()) {
                count = rs.getInt(1);
            }

            if (count > 0) {
                // 실무 환경에서는 원래 임시 비밀번호를 이메일로 발송하거나 암호화 조치하지만, 
                // 교육용 프로젝트 환경이므로 직관적인 확인을 위해 임시 비밀번호 'jyp1234'로 변경 처리합니다.
                if (pstmt != null) pstmt.close();
                
                String updateSql = "UPDATE member SET password = 'jyp1234' WHERE member_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, userid.trim());
                pstmt.executeUpdate();

                out.print("<script>");
                out.print("alert('" + name + " 회원님의 비밀번호가 임시 비밀번호 [ jyp1234 ] 로 초기화되었습니다. 로그인 후 반드시 변경해 주세요.');");
                out.print("location.href='login.jsp';");
                out.print("</script>");
            } else {
                out.print("<script>alert('입력하신 회원 정보가 데이터베이스와 일치하지 않습니다.'); history.back();</script>");
            }
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
