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

// 💡 変更完了リクエストを処理する仮想サーブレットアドレスのマッピング
@WebServlet("/memberModifyAction")
public class MemberModifyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // パスワード SHA-256 単方向ハッシュ暗号化アルゴリズムの搭載
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

    // 情報変更フォーム(memberModify.jsp)をサーバー内部のセキュリティトンネル経由で開く GET パス
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        if (sessionUserId == null) {
            response.getWriter().print("<script>alert('ログインが必要なサービスです。'); location.href='login.jsp';</script>");
            return;
        }

        // 既存の登録情報を照会し、フォームに埋め込むためのデータ転送処理
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
            // 💡 wls 内の変更フォーム jsp 画面を強制レンダリング呼び出し
            request.getRequestDispatcher("/wls/memberModify.jsp").forward(request, response);
        } catch(Exception e) { e.printStackTrace(); }
        finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    // 実際のデータを受け取って変更を確定するデータ加工処理（POST 方式）
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

            // パスワードの 1 次照合検証
            String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, sessionUserId);
            pstmt.setString(2, encryptedPw);
            rs = pstmt.executeQuery();
            
            int count = 0; if(rs.next()) { count = rs.getInt(1); }
            if (count == 0) {
                out.print("<script>alert('パスワードが一致しません。'); history.back();</script>");
                return;
            }
            
            if (pstmt != null) pstmt.close();
            
            // 会員情報の UPDATE 実行
            String updateSql = "UPDATE member SET member_name = ?, member_email = ?, member_phone = ?, member_address = ? WHERE member_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, nameKo);
            pstmt.setString(2, email);
            pstmt.setString(3, phone);
            pstmt.setString(4, address);
            pstmt.setString(5, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                session.setAttribute("sessionUserName", nameKo); // セッションの同期化
                out.print("<script>alert('会員情報が正常に変更されました。'); location.href='" + request.getContextPath() + "/myPage';</script>");
            } else {
                out.print("<script>alert('情報の変更に失敗しました。'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("<script>alert('エラー: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }
}