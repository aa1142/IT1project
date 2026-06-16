package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 💡 会員登録フォームが送信される仮想アドレスの設定 (.jspを排除)
@WebServlet("/signupAction")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // パスワード単方向ハッシュ暗号化 (SHA-256) メソッドの統合
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

    // 💡 会員登録成功後、wlsフォルダ内部の signupSuccess.jsp を安全に開くための GET パス
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 🛠️ 括弧のもつれを解決し、通常のwlsフォルダ内部の signup.jsp へ即時リダイレクト
        response.sendRedirect(request.getContextPath() + "/wls/signup.jsp");
    }

    // 💡 会員登録完了メッセージ(Alert)のバグを完全に解決した doPost メソッド
    // 💡 画面が真っ白になるバグを防ぎ、実際のOracleエラーを露出させる診断用 doPost メソッド
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // エンコーディングを最上段で強制指定
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 1. フロントエンドのパラメータデータの収集
            String userid = request.getParameter("userid");
            String userpw = request.getParameter("password");
            String nameKo = request.getParameter("name");
            
            String phone1 = request.getParameter("phone1");
            String phone2 = request.getParameter("phone2");
            String phone3 = request.getParameter("phone3");
            if(phone1 == null || phone1.trim().equals("")) phone1 = "010";
            if(phone2 == null || phone2.trim().equals("")) phone2 = "0000";
            if(phone3 == null || phone3.trim().equals("")) phone3 = "0000";
            String phone = phone1.trim() + "-" + phone2.trim() + "-" + phone3.trim();

            String addressMain = request.getParameter("address");
            String addressDetail = request.getParameter("address_detail");
            String address = (addressMain != null ? addressMain : "") + " " + (addressDetail != null ? addressDetail : "");
            String email = request.getParameter("email");

            // 2. プレーンテキストのパスワードを暗号化加工
            String encryptedPw = encryptSHA256(userpw);

            // 3. Oracleデータベースの接続情報の設定 (orcl または xe のチェック)
            String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
            String dbUser = "scott";                 
            String dbPass = "tiger";

            Connection conn = null;
            PreparedStatement pstmt = null;

            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // Oracleテーブルのカラム規格のマッチング挿入
            String sql = "INSERT INTO member (member_id, member_pw, member_name, member_phone, member_grade, member_email, member_address) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, userid);
            pstmt.setString(2, encryptedPw);
            pstmt.setString(3, nameKo != null ? nameKo : "未入力");
            pstmt.setString(4, phone);
            pstmt.setString(5, "一般"); 
            pstmt.setString(6, email != null ? email : "test@test.com");
            pstmt.setString(7, address);

            int result = pstmt.executeUpdate();

            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();

            if (result > 0) {
                // 会員登録成功時のページリダイレクト
                out.println("<script>");
                out.println("alert('" + nameKo + " 様、JYP HOTELへの会員登録ありがとうございます！');");
                out.println("location.href='" + request.getContextPath() + "/wls/signupSuccess.jsp?name=" + java.net.URLEncoder.encode(nameKo, "UTF-8") + "';");
                out.println("</script>");
                return;
            } else {
                out.println("<h3>会員登録失敗: 保存されたレコードがありません。</h3>");
                return;
            }

        } catch (Exception e) {
            // 💡 [デバッグ領域] 画面の真っ白化を防ぎ、実際のJava/Oracleエラーをブラウザにそのまま出力します。
            e.printStackTrace();
            out.println("<div style='padding:30px; background:#fff0f0; border:2px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
            out.println("<h2>⚠️ 会員登録サーブレット バックエンドエラー発生！</h2>");
            out.println("<hr style='border:1px solid #ffcccc;'>");
            out.println("<p style='font-size:16px; font-weight:bold;'>[実際の原因コード] :</p>");
            out.println("<pre style='background:#fff; padding:15px; border:1px solid #ddd; font-size:14px; overflow-x:auto;'>" + e.toString() + "</pre>");
            out.println("<p style='font-size:14px; color:#555;'>上記のボックス内の英文テキストメッセージをコピーしてお知らせいただければ、すぐにバグを修正いたします。</p>");
            out.println("</div>");
        }
    }

}