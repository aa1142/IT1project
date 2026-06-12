package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// 💡 회원 탈퇴를 처리할 가상 서블릿 주소 설정
@WebServlet("/deleteAccountAction")
public class DeleteAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        if (sessionUserId == null) {
            response.getWriter().print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='login.jsp';</script>");
            return;
        }

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";
        Connection conn = null; PreparedStatement pstmt = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 오라클 DB에서 회원을 영구 삭제하는 DELETE 쿼리 실행
            String sql = "DELETE FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                // 탈퇴 성공 시 서버 메모리 세션 파괴 및 메인 튕겨내기
                session.invalidate();
                response.getWriter().print("<script>alert('회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다.'); location.href='" + request.getContextPath() + "/main';</script>");
            } else {
                response.getWriter().print("<script>alert('탈퇴 처리 실패'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("<script>alert('에러: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}