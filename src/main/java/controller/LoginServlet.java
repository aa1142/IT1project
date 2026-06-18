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

@WebServlet("/loginAction")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 会員用 SHA-256 ハッシュ暗号化メソッド
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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/wls/index.jsp");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userid = request.getParameter("userid");
        String userpw = request.getParameter("userpw");

        if (userid == null || userpw == null || userid.trim().equals("") || userpw.trim().equals("")) {
            out.print("<script>alert('ユーザーIDとパスワードを両方入力してください。'); history.back();</script>");
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

            // 👤 [第1段階]: まず一般会員テーブル(member)でIDと暗号化されたパスワードを照合
            String memberEncryptedPw = encryptSHA256(userpw);
            String memberSql = "SELECT member_name, member_grade, member_count FROM member WHERE member_id = ? AND member_pw = ?";
            
            pstmt = conn.prepareStatement(memberSql);
            pstmt.setString(1, userid.trim());
            pstmt.setString(2, memberEncryptedPw);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 一般会員またはVIPのログイン成功時のシナリオ
                String memberName = rs.getString("member_name");
                String memberGrade = rs.getString("member_grade");
                int memberCount = rs.getInt("member_count");
                
                // 10回以上利用の場合、VIPへ自動昇格するトランザクション防衛線
                if (memberCount >= 10 && !"VIP".equals(memberGrade)) {
                    PreparedStatement updateGradePstmt = null;
                    try {
                        String updateGradeSql = "UPDATE member SET member_grade = 'VIP' WHERE member_id = ?";
                        updateGradePstmt = conn.prepareStatement(updateGradeSql);
                        updateGradePstmt.setString(1, userid.trim());
                        updateGradePstmt.executeUpdate();
                        memberGrade = "VIP"; 
                    } catch (Exception ex) {
                        System.out.println("⚠️ VIP昇格例外無視: " + ex.getMessage());
                    } finally {
                        if (updateGradePstmt != null) try { updateGradePstmt.close(); } catch(Exception e){}
                    }
                }
                
                HttpSession session = request.getSession();
                session.setAttribute("sessionUserId", userid);
                session.setAttribute("sessionUserName", memberName);
                session.setAttribute("sessionUserGrade", memberGrade);
                
                out.print("<script>");
                out.print("alert('" + memberName + " 様、ようこそ！JYP HOTELのログインに成功しました。');");
                out.print("location.href='" + request.getContextPath() + "/wls/index.jsp';"); 
                out.print("</script>");
                return;
            }
            
            // 一般会員テーブルになければ、使用したオブジェクトを解放して第2段階の準備
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            // 👑 [第2段階]: 管理者テーブル(admin)でプレーンテキストのIDとパスワードを直接照合
            // （提供されたダミーデータ確認の結果、管理者はハッシュ暗号化されていないプレーンテキスト 'tiger123' の形式であるため、暗号化なしで比較します！）
            String adminSql = "SELECT * FROM admin WHERE admin_id = ? AND admin_pw = ?";
            pstmt = conn.prepareStatement(adminSql);
            pstmt.setString(1, userid.trim());
            pstmt.setString(2, userpw.trim()); // ◀ プレーンテキストのマッチング
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 管理者ログイン大成功時のシナリオ
                String adminName = rs.getString("admin_name");
                
                HttpSession session = request.getSession();
                session.setAttribute("adminId", rs.getString("admin_id"));
                session.setAttribute("companyNo", rs.getString("company_no")); // ◀ セッション権限を手動で管理者に指定
                
                out.print("<script>");
                out.print("alert('👑 [JYP HOTELシステム最高管理者] " + adminName + " 様、ログイン成功。管理者専用メニューに移行します。');");
                out.print("location.href='" + request.getContextPath() + "/Admin/bootmng.jsp';"); // ◀ 管理者メインパスへ転送
                out.print("</script>");
                return;
            }

            // どちらにも該当しない場合は例外へ誘導
            out.print("<script>alert('ユーザーIDまたはパスワードが一致しません。'); history.back();</script>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('サーバーエラー発生: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }
}