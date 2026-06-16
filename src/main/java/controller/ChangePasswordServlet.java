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

// 💡 パスワード変更画面およびリクエストを処理する仮想アドレスの設定
@WebServlet("/changePasswordAction")
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // SHA-256 ハッシュ暗号化メソッド
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

    // セキュリティ領域(wls)内部にある changePassword.jsp 画面を安全に開くための GET パス
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession();
        if (session.getAttribute("sessionUserId") == null) {
            response.getWriter().print("<script>alert('ログインが必要なサービスです。'); location.href='login.jsp';</script>");
            return;
        }
        
        // 🔒 wls/changePassword.jsp 画面へリダイレクト
        response.sendRedirect(request.getContextPath() + "/wls/changePassword.jsp");
    }

    // 実際に新しいパスワードへの UPDATE を確定する処理（POST 方式）
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");

        String currentPw = request.getParameter("currentPw");
        String newPw = request.getParameter("newPw");

        // 現在のパスワードと新しいパスワードをハッシュ値に変換
        String encryptedCurrentPw = encryptSHA256(currentPw);
        String encryptedNewPw = encryptSHA256(newPw);

        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null; PreparedStatement pstmt = null; ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 現在のパスワードの検証
            String checkSql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, sessionUserId);
            pstmt.setString(2, encryptedCurrentPw);
            rs = pstmt.executeQuery();
            
            int count = 0; if(rs.next()) { count = rs.getInt(1); }
            if (count == 0) {
                out.print("<script>alert('現在のパスワードが一致しません。'); history.back();</script>");
                return;
            }
            
            if (pstmt != null) pstmt.close();
            
            // 新しいパスワードに UPDATE
            String updateSql = "UPDATE member SET member_pw = ? WHERE member_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, encryptedNewPw);
            pstmt.setString(2, sessionUserId);
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                out.print("<script>alert('パスワードが正常に変更されました。'); location.href='" + request.getContextPath() + "/myPage';</script>");
            } else {
                out.print("<script>alert('パスワードの変更に失敗しました。'); history.back();</script>");
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