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

// 💡 ユーザーIDとパスワードの検索を処理する仮想サーブレットアドレスマッピング
@WebServlet("/findAccountAction")
public class FindAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 💡 [오류 해결 핵심]: 클래스 내부에 SHA-256 암호화 메서드를 정확하게 선언해 줍니다!
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

    // 💡 findAccount.jsp 画面へ遷移するGETメソッド
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.sendRedirect(request.getContextPath() + "/wls/findAccount.jsp");
    }

    // 💡 ユーザー情報を照合してID取得またはパスワード初期化を処理するPOSTメソッド
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String findType = request.getParameter("findType");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String userid = request.getParameter("userid");

        // ⚠️ 本人のオラ클DB環境(orcl または xe)に合わせて設定してください。
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
                // 🆔 1. ユーザーID検索
                String sql = "SELECT member_id FROM member WHERE member_name = ? AND member_email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name.trim());
                pstmt.setString(2, email.trim());
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String foundId = rs.getString("member_id");
                    out.print("<script>");
                    out.print("alert('" + name + " 様のユーザーIDは [" + foundId + "] です。');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';");
                    out.print("</script>");
                } else {
                    out.print("<script>alert('一致する会員情報が見つかりません。'); history.back();</script>");
                }

            } else if ("pw".equals(findType)) {
                // 🔒 2. パスワード検索（仮パスワード発行）
                String sql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_name = ? AND member_email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userid.trim());
                pstmt.setString(2, name.trim());
                pstmt.setString(3, email.trim());
                rs = pstmt.executeQuery();

                int count = 0; if(rs.next()) { count = rs.getInt(1); }

                if (count > 0) {
                    if (pstmt != null) pstmt.close();
                    
                    // 💡 上記で宣言した暗号化メソッドを呼び出し、'jyp1234'を64文字のハッシュ乱数に変換します。
                    String encryptedTempPw = encryptSHA256("jyp1234");
                    
                    // 暗号化された乱数値をDBに安全にアップデートします。
                    String updateSql = "UPDATE member SET member_pw = ? WHERE member_id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, encryptedTempPw); 
                    pstmt.setString(2, userid.trim());
                    pstmt.executeUpdate();

                    out.print("<script>");
                    out.print("alert('" + name + " 様のパスワードが仮パスワード [ jyp1234 ] に初期化されました。ログイン後に変更してください。');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';");
                    out.print("</script>");
                    return;
                } else {
                    out.print("<script>alert('入力された会員情報がデータベースと一致しません。'); history.back();</script>");
                    return;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("<script>alert('サーバーエラーが発生しました: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }
}
