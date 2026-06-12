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

// 💡 수정 완료 요청을 처리할 가상 서블릿 주소 매핑
@WebServlet("/memberModifyAction")
public class MemberModifyServlet extends HttpServlet {
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

    // 정보수정 폼(memberModify.jsp)을 서버 내부 보안 터널로 열어주는 GET 통로
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        if (sessionUserId == null) {
            response.getWriter().print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
            return;
        }

        // 기존 가입 정보 조회 후 폼에 채워주기 위한 데이터 전송 처리
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";
        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            String sql = "SELECT member_name, member_email, member_phone, member_address FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionUserId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                request.setAttribute("name", rs.getString("member_name"));
                request.setAttribute("email", rs.getString("member_email"));
                request.setAttribute("phone", rs.getString("member_phone"));
                request.setAttribute("address", rs.getString("member_address"));
            }
            // 💡 wls 안의 수정 폼 jsp 화면 강제 렌더링 호출
            request.getRequestDispatcher("/wls/memberModify.jsp").forward(request, response);
        } catch(Exception e) { e.printStackTrace(); }
        finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    // 실제 데이터를 받아서 수정을 확정 짓는 데이터 가공 처리단 (POST 방식)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");

        String nameKo = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");

        String encryptedPw = encryptSHA256(password);

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 비밀번호 1차 대조 검증
            String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, sessionUserId);
            pstmt.setString(2, encryptedPw);
            rs = pstmt.executeQuery();
            
            int count = 0; if(rs.next()) { count = rs.getInt(1); }
            if (count == 0) {
                out.print("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
                return;
            }
            
            if (pstmt != null) pstmt.close();
            
            // 회원정보 UPDATE 실행
            String updateSql = "UPDATE member SET member_name = ?, member_email = ?, member_phone = ?, member_address = ? WHERE member_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, nameKo);
            pstmt.setString(2, email);
            pstmt.setString(3, phone);
            pstmt.setString(4, address);
            pstmt.setString(5, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                session.setAttribute("sessionUserName", nameKo); // 세션 동기화
                out.print("<script>alert('회원 정보가 성공적으로 변경되었습니다.'); location.href='" + request.getContextPath() + "/myPage';</script>");
            } else {
                out.print("<script>alert('정보 수정 실패'); history.back();</script>");
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