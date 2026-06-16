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

// 💡 退会手続きを処理する仮想サーブレットアドレスの設定
@WebServlet("/deleteAccountAction")
public class DeleteAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        if (sessionUserId == null) {
            response.getWriter().print("<script>alert('ログインが必要なサービスです。'); location.href='login.jsp';</script>");
            return;
        }

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";
        Connection conn = null; PreparedStatement pstmt = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Oracle DBから会員を永久削除する DELETE クエリの実行
            String sql = "DELETE FROM member WHERE member_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                // 退会成功時、サーバーメモリのセッションを破棄してメイン画面へ移動
                session.invalidate();
                response.getWriter().print("<script>alert('退会手続きが完了しました。ご利用いただきありがとうございました。'); location.href='" + request.getContextPath() + "/main';</script>");
            } else {
                response.getWriter().print("<script>alert('退会処理に失敗しました。'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("<script>alert('エラー: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}