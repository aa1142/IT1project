package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/myPage")
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 💡 画面が真っ白になるのを防ぐため、出力ストリームを事前に確保
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        
        if (sessionUserId == null) {
            out.print("<script>alert('ログインが必要なサービスです。'); location.href='" + request.getContextPath() + "/wls/login.jsp';</script>");
            return;
        }

        // ⚠️ 実際のOracle接続アドレスとアカウントのパスワードをご確認ください。
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        ResultSet rs1 = null;
        ResultSet rs2 = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 1. 会員の基本情報の照会（この領域は正常に動作します）
            String memberSql = "SELECT member_email, member_phone, member_address, member_grade, member_count FROM member WHERE member_id = ?";
            pstmt1 = conn.prepareStatement(memberSql);
            pstmt1.setString(1, sessionUserId);
            rs1 = pstmt1.executeQuery();

            if (rs1.next()) {
                request.setAttribute("email", rs1.getString("member_email"));
                request.setAttribute("phone", rs1.getString("member_phone"));
                request.setAttribute("address", rs1.getString("member_address"));
                request.setAttribute("grade", rs1.getString("member_grade"));
                request.setAttribute("count", rs1.getInt("member_count"));
            }

            // 💡 [核心防御領域]: 予約履歴の照会を別の独立した try-catch で分離します。
            List<Map<String, String>> reserveList = new ArrayList<>();
            try {
                // ⚠️ 現在エラーが発生している領域です。実際のテーブル名（例: boot）が判明したら、この単語を修正してください。
                String reserveSql = "SELECT boot_no, room_type, check_in, check_out, boot_confirm FROM boot WHERE member_id = ? ORDER BY reserve_no DESC";
                pstmt2 = conn.prepareStatement(reserveSql);
                pstmt2.setString(1, sessionUserId);
                rs2 = pstmt2.executeQuery();

                while (rs2.next()) {
                    Map<String, String> map = new HashMap<>();
                    map.put("no", rs2.getString("boot_no"));
                    map.put("room", rs2.getString("room_type"));
                    map.put("in", rs2.getString("check_in"));
                    map.put("out", rs2.getString("check_out"));
                    map.put("status", rs2.getString("boot_confirm"));
                    reserveList.add(map);
                }
            } catch (Exception e) {
                // テーブルが存在せずエラーが発生した場合でも、コンソールにログのみを出力し、プログラムを停止させずに通過させます。
                System.out.println("⚠️ [案内] まだDBに予約テーブルがないか、テーブル名が異なります: " + e.getMessage());
            }
            
            // エラーが発生した場合でも、空のオブジェクトまたは収集されたデータを格納して安全に出発します。
            request.setAttribute("reserveList", reserveList);
            
            // 🔒 画面呼び出しパスを正常に稼働
            request.getRequestDispatcher("/wls/myPage.jsp").forward(request, response);

        } catch (Exception e) {
            // 💡 [デバッグ領域] 画面の真っ白化を防ぎ、Oracleのエラー原因をブラウザの前面に出力します。
            e.printStackTrace();
            out.println("<div style='padding:30px; background:#fff0f0; border:2px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
            out.println("<h2>⚠️ マイページサーブレット バックエンドエラー発生！</h2>");
            out.println("<hr style='border:1px solid #ffcccc;'>");
            out.println("<p style='font-size:16px; font-weight:bold;'>[Oracle DBが出力した実際のエラーメッセージ] :</p>");
            out.println("<pre style='background:#fff; padding:15px; border:1px solid #ddd; font-size:14px; overflow-x:auto;'>" + e.toString() + "</pre>");
            out.println("<p style='font-size:14px; color:#555;'>上記のボックス内の <b>ORA-XXXXX</b> または英文をコピーしてお知らせいただければ、すぐにクエリ文の同期調整を行います。</p>");
            out.println("</div>");
        } finally {
            if (rs2 != null) try { rs2.close(); } catch (SQLException ex) {}
            if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException ex) {}
            if (rs1 != null) try { rs1.close(); } catch (SQLException ex) {}
            if (pstmt1 != null) try { pstmt1.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}