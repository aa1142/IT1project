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

// 💡 비밀번호 변경 화면 및 요청을 처리할 가상 주소 설정
@WebServlet("/changePasswordAction")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // SHA-256 해시 암호화 메서드
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

    // 보안 구역(wls) 내부에 있는 changePassword.jsp 화면을 안전하게 열어주는 GET 통로
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession();
        if (session.getAttribute("sessionUserId") == null) {
            response.getWriter().print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
            return;
        }
        
        // 🔒 WEB-INF/wls/changePassword.jsp 화면 포워딩
        response.sendRedirect(request.getContextPath() + "/wls/changePassword.jsp");
    }

    // 실제 새 암호로 UPDATE를 확정 짓는 처리단 (POST 방식)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");

        String currentPw = request.getParameter("currentPw");
        String newPw = request.getParameter("newPw");

        // 현재 비밀번호와 새 비밀번호를 해시 난수로 변환
        String encryptedCurrentPw = encryptSHA256(currentPw);
        String encryptedNewPw = encryptSHA256(newPw);

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 기존 비밀번호 검증
            String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, sessionUserId);
            pstmt.setString(2, encryptedCurrentPw);
            rs = pstmt.executeQuery();
            
            int count = 0; if(rs.next()) { count = rs.getInt(1); }
            if (count == 0) {
                out.print("<script>alert('현재 비밀번호가 일치하지 않습니다.'); history.back();</script>");
                return;
            }
            
            if (pstmt != null) pstmt.close();
            
            // 새 비밀번호로 UPDATE
            String updateSql = "UPDATE member SET member_pw = ? WHERE member_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, encryptedNewPw);
            pstmt.setString(2, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                out.print("<script>alert('비밀번호가 안전하게 변경되었습니다.'); location.href='" + request.getContextPath() + "/myPage';</script>");
            } else {
                out.print("<script>alert('비밀번호 변경 실패'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("<script>alert('에러: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }
}