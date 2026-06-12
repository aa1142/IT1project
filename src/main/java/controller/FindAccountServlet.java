package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 💡 계정 찾기 폼 전송 및 화면 열기를 처리할 가상 주소 설정
@WebServlet("/findAccountAction")
public class FindAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 💡 일반 wls 폴더 안에 숨어있는 findAccount.jsp 화면으로 다이렉트 주소창을 점프시킵니다.
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.sendRedirect(request.getContextPath() + "/wls/findAccount.jsp");
    }

    // 💡 사용자가 [아이디 찾기] 또는 [임시 비밀번호 발급]을 누르면 이곳(POST)으로 넘어옵니다.
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String findType = request.getParameter("findType");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String userid = request.getParameter("userid"); // 비밀번호 찾기 시 수집

        // ⚠️ 본인의 실제 오라클 정보로 꼭 확인하세요! (orcl 또는 xe)
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
                // 🆔 1. 아이디 찾기 쿼리 로직 (새 컬럼명 member_name, member_email, member_id 반영)
                String sql = "SELECT member_id FROM member WHERE member_name = ? AND member_email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name.trim());
                pstmt.setString(2, email.trim());
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String foundId = rs.getString("member_id");
                    out.print("<script>");
                    out.print("alert('" + name + " 회원님의 아이디는 [" + foundId + "] 입니다.');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';"); // 일반 폴더 주소로 이동
                    out.print("</script>");
                } else {
                    out.print("<script>alert('일치하는 회원 정보가 존재하지 않습니다.'); history.back();</script>");
                }

            } else if ("pw".equals(findType)) {
                // 🔒 2. 비밀번호 찾기 (임시 패스워드 강제 주입 및 변경) 로직
                String sql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_name = ? AND member_email = ?";
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
                    if (pstmt != null) pstmt.close();
                    
                    // 프로젝트 제출용 가상 계정 관리를 위해 임시 비번 'jyp1234'로 UPDATE 연동
                    String updateSql = "UPDATE member SET member_pw = 'jyp1234' WHERE member_id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, userid.trim());
                    pstmt.executeUpdate();

                    out.print("<script>");
                    out.print("alert('" + name + " 회원님의 비밀번호가 임시 비밀번호 [ jyp1234 ] 로 초기화되었습니다. 로그인 후 변경해 주세요.');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';");
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
    }
}
