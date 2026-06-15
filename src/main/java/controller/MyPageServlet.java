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
        
        // 💡 하얀 화면 방지용 출력 스트림 미리 확보
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserId = (String) session.getAttribute("sessionUserId");
        
        if (sessionUserId == null) {
            out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='" + request.getContextPath() + "/wls/login.jsp';</script>");
            return;
        }

        // ⚠️ 본인의 실제 오라클 접속 주소와 계정 비밀번호를 꼭 대조해 보세요!
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

            // 1. 회원 기본 정보 조회 (이 구역은 무조건 정상 작동합니다)
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

            // 💡 [핵심 방어막 구역]: 예약 내역 조회를 별도의 독립 try-catch로 격리합니다.
            List<Map<String, String>> reserveList = new ArrayList<>();
            try {
                // ⚠️ 현재 에러가 나는 구역입니다. 팀원의 실제 테이블명(예: booking)을 알게 되면 이 단어를 고치시면 됩니다!
                String reserveSql = "SELECT reserve_no, room_name, check_in, check_out, reserve_status FROM reservation WHERE member_id = ? ORDER BY reserve_no DESC";
                pstmt2 = conn.prepareStatement(reserveSql);
                pstmt2.setString(1, sessionUserId);
                rs2 = pstmt2.executeQuery();

                while (rs2.next()) {
                    Map<String, String> map = new HashMap<>();
                    map.put("no", rs2.getString("reserve_no"));
                    map.put("room", rs2.getString("room_name"));
                    map.put("in", rs2.getString("check_in"));
                    map.put("out", rs2.getString("check_out"));
                    map.put("status", rs2.getString("reserve_status"));
                    reserveList.add(map);
                }
            } catch (Exception e) {
                // 테이블이 없어서 에러가 나더라도 콘솔에 로그만 찍고, 프로그램이 멈추지 않고 통과하게 만듭니다.
                System.out.println("⚠️ [안내] 아직 DB에 예약 테이블이 없거나 이름이 다릅니다: " + e.getMessage());
            }
            
            // 에러가 나더라도 빈 상자 혹은 수집된 상자를 싣고 안전하게 출발합니다.
            request.setAttribute("reserveList", reserveList);
            
            // 🔒 화면 호출 통로 정상 가동
            request.getRequestDispatcher("/wls/myPage.jsp").forward(request, response);


        } catch (Exception e) {
            // 💡 [핵심 디버깅 관문] 하얀 화면을 강제로 찢어버리고 오라클 에러 원인을 브라우저 전면에 출력합니다.
            e.printStackTrace();
            out.println("<div style='padding:30px; background:#fff0f0; border:2px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
            out.println("<h2>⚠️ 마이페이지 서블릿 백엔드 에러 발생!</h2>");
            out.println("<hr style='border:1px solid #ffcccc;'>");
            out.println("<p style='font-size:16px; font-weight:bold;'>[오라클 DB가 뱉은 진짜 에러 메시지] :</p>");
            out.println("<pre style='background:#fff; padding:15px; border:1px solid #ddd; font-size:14px; overflow-x:auto;'>" + e.toString() + "</pre>");
            out.println("<p style='font-size:14px; color:#555;'>위 상자 안의 <b>ORA-XXXXX</b> 또는 영어 문장을 복사해서 알려주시면 쿼리문을 즉시 싱크 조율해 드릴게요.</p>");
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
