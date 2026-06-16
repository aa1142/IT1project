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

// 💡 アカウント検索フォームの送信および画面表示を処理する仮想アドレスの設定
@WebServlet("/findAccountAction")
public class FindAccountServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 💡 通常のwlsフォルダ内に配置されている findAccount.jsp 画面にリダイレクトします。
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.sendRedirect(request.getContextPath() + "/wls/findAccount.jsp");
    }

    // 💡 ユーザーが [IDを確認する] または [仮パスワードを発行する] をクリックすると、ここ(POST)へ遷移します。
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String findType = request.getParameter("findType");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String userid = request.getParameter("userid"); // パスワード検索時に収集

        // ⚠️ ご自身の実際のOracle情報（orcl または xe）に合わせてご確認ください。
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
                // 🆔 1. ID検索のクエリロジック（カラム名 member_name, member_email, member_id を反映）
                String sql = "SELECT member_id FROM member WHERE member_name = ? AND member_email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name.trim());
                pstmt.setString(2, email.trim());
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String foundId = rs.getString("member_id");
                    out.print("<script>");
                    out.print("alert('" + name + " 様のユーザーIDは [" + foundId + "] です。');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';"); // 通常のログインフォルダへ移動
                    out.print("</script>");
                } else {
                    out.print("<script>alert('一致する会員情報が存在しません。'); history.back();</script>");
                }

            } else if ("pw".equals(findType)) {
                // 🔒 2. パスワード検索（仮パスワードの強制注入および変更）ロジック
                String sql = "SELECT COUNT(*) FROM member WHERE member_id = ? AND member_name = ? AND member_email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userid.trim());
                pstmt.setString(2, name.trim());
                pstmt.setString(3, email.trim());
                rs = pstmt.executeQuery();

                int count = 0;
                if(rs.next()) {
                    count = rs.getInt(1);
                }

                if (count > 0) {
                    if (pstmt != null) pstmt.close();
                    
                    // プロジェクト提出用の仮想アカウント管理のため、仮パスワード 'jyp1234' に UPDATE 連動
                    String updateSql = "UPDATE member SET member_pw = 'jyp1234' WHERE member_id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, userid.trim());
                    pstmt.executeUpdate();

                    out.print("<script>");
                    out.print("alert('" + name + " 様のパスワードが仮パスワード [ jyp1234 ] に初期化されました。ログイン後に変更してください。');");
                    out.print("location.href='" + request.getContextPath() + "/wls/login.jsp';");
                    out.print("</script>");
                } else {
                    out.print("<script>alert('入力された会員情報がデータベースと一致しません。'); history.back();</script>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("<script>alert('サーバーエラー発生: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }
}