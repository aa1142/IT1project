package controller;

import java.io.IOException;
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

// 💡 마이페이지 진입 시 호출할 가상 주소 설정
@WebServlet("/myPage")
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 💡 마이페이지는 화면 조회가 목적이므로 doGet 메서드 안에서 처리합니다.
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 1. 로그인 세션 확인 검증
        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        
        if (sessionUserId == null) {
            response.getWriter().print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='" + request.getContextPath() + "/login.jsp';</script>");
            return;
        }

        // 오라클 데이터베이스 연결 설정
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 2. 오라클에서 로그인한 회원의 상세 정보 조회
            String sql = "SELECT member_email, member_phone, member_address, member_grade, member_count FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionUserId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 💡 핵심: 조회한 DB 데이터들을 request 상자에 담아서 JSP 화면단으로 배달 보냅니다.
                request.setAttribute("email", rs.getString("member_email"));
                request.setAttribute("phone", rs.getString("member_phone"));
                request.setAttribute("address", rs.getString("member_address"));
                request.setAttribute("grade", rs.getString("member_grade"));
                request.setAttribute("count", rs.getInt("member_count"));
            }
            
            // 3. 🔒 보안 구역인 WEB-INF/wls/myPage.jsp 파일로 수집한 데이터를 들고 부드럽게 토스(포워딩)합니다.
            request.getRequestDispatcher("/wls/myPage.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("<script>alert('서버 오류 발생: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}