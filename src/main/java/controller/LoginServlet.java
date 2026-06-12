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
import javax.servlet.http.HttpSession;

// 💡 로그인 데이터를 처리할 가상 주소 설정
@WebServlet("/loginAction")
public class LoginServlet extends HttpServlet {
	    private static final long serialVersionUID = 1L;

	    // 비밀번호 SHA-256 단방향 해시 암호화 알고리즘 탑재
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

    // 💡 주소창에 직접 /loginAction을 치거나 성공 후 가상 주소를 안전하게 메인 jsp로 토스하는 GET 관문
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 복잡한 포워딩을 제거하고, 일반 wls 폴더 안에 있는 index.jsp로 다이렉트 리다이렉트합니다!
        response.sendRedirect(request.getContextPath() + "/wls/index.jsp");
    }
    
    // 💡 사용자가 로그인창에서 [로그인] 버튼을 누르면 이곳(POST)으로 데이터가 넘어옵니다.
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userid = request.getParameter("userid");
        String userpw = request.getParameter("userpw");
        String encryptedPw = encryptSHA256(userpw);

        // 오라클 데이터베이스 연동 정보 설정 (본인의 SID가 orcl 인지 xe 인지 꼭 확인하세요!)
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 변경된 오라클 스키마 규격 매칭 (member_name, member_id, member_pw)
            String sql = "SELECT member_name FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid.trim());
            pstmt.setString(2, encryptedPw);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                String memberName = rs.getString("member_name");
                
                // 세션(Session) 메모리에 로그인 상태 기록 유지
                HttpSession session = request.getSession();
                session.setAttribute("sessionUserId", userid);
                session.setAttribute("sessionUserName", memberName);
                
                // 💡 [로그인 성공] 팝업창을 띄운 후, 일반 폴더 안에 있는 index.jsp 메인 화면으로 주소창을 이동시킵니다!
                out.print("<script>");
                out.print("alert('" + memberName + "님, 환영합니다! JYP HOTEL 로그인에 성공했습니다.');");
                out.print("location.href='" + request.getContextPath() + "/wls/index.jsp';"); 
                out.print("</script>");
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
    }
}
