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

// 💡 중복확인 페치(fetch) 요청을 받아줄 가상 서블릿 주소 매핑 (.jsp 제거)
@WebServlet("/checkIdAction")
public class CheckIdServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 비동기 fetch API는 주로 데이터를 조회할 때 GET 방식을 사용하므로 doGet에서 처리합니다.
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // 💡 중요: HTML 화면을 그리는 게 아니라 순수 텍스트 결과(usable, duplicated)만 응답하므로 plain 설정
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userid = request.getParameter("userid");

        if(userid == null || userid.trim().equals("")) {
            out.print("empty");
            return;
        }

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 새 오라클 테이블 컬럼 규격 매칭 (member_id)
            String sql = "SELECT COUNT(*) FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid.trim());

            rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                if (count == 0) {
                    out.print("usable");     // 중복 없음 -> 사용 가능
                } else {
                    out.print("duplicated"); // 중복 있음 -> 사용 불가
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error"); 
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