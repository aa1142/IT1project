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

// 💡 로그인 데이터를 처리할 가상 주소 설정
@WebServlet("/loginAction")
public class LoginServlet extends HttpServlet {
	    private static final long serialVersionUID = 1L;

	    // 비밀번호 SHA-256 단방향 해시 암호화 알고리즘 탑재
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

    // 💡 주소창에 직접 /loginAction을 치거나 성공 후 가상 주소를 안전하게 메인 jsp로 토스하는 GET 관문
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 복잡한 포워딩을 제거하고, 일반 wls 폴더 안에 있는 index.jsp로 다이렉트 리다이렉트합니다!
        response.sendRedirect(request.getContextPath() + "/wls/index.jsp");
    }
    
    // 💡 하얀 화면을 원천 차단하고 진짜 원인을 화면에 뿌려주는 로그인 doPost 완전판
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userid = request.getParameter("userid");
        String userpw = request.getParameter("userpw");
        
        if (userid == null || userpw == null || userid.trim().equals("") || userpw.trim().equals("")) {
            out.print("<script>alert('아이디와 비밀번호를 모두 입력해 주세요.'); history.back();</script>");
            return;
        }

        String encryptedPw = encryptSHA256(userpw);

        // ⚠️ 본인의 실제 오라클 정보(orcl 또는 xe)를 정확히 확인하세요!
        String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
        String dbUser = "scott";                 
        String dbPass = "tiger";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 로그인 시 회원의 이름(member_name), 등급(member_grade), 예약횟수(member_count) 조회
            String sql = "SELECT member_name, member_grade, member_count FROM member WHERE member_id = ? AND member_pw = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid.trim());
            pstmt.setString(2, encryptedPw);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                String memberName = rs.getString("member_name");
                String memberGrade = rs.getString("member_grade");
                int memberCount = rs.getInt("member_count");
                
                // 💡 [안전 장치 추가] 10회 이상일 때 VIP 승격 쿼리가 에러나도 로그인은 통과되도록 독립 try-catch 처리
                if (memberCount >= 10 && !"관리자".equals(memberGrade) && !"VIP".equals(memberGrade)) {
                    PreparedStatement updateGradePstmt = null;
                    try {
                        String updateGradeSql = "UPDATE member SET member_grade = 'VIP' WHERE member_id = ?";
                        updateGradePstmt = conn.prepareStatement(updateGradeSql);
                        updateGradePstmt.setString(1, userid.trim());
                        updateGradePstmt.executeUpdate();
                        
                        memberGrade = "VIP"; // 실시간 변수 갱신
                    } catch (Exception ex) {
                        System.out.println("⚠️ VIP 자동 승격 중 예외 발생 (로그인은 계속 진행됨): " + ex.getMessage());
                    } finally {
                        if (updateGradePstmt != null) try { updateGradePstmt.close(); } catch(Exception e){}
                    }
                }
                
                // 세션(Session) 메모리에 로그인 상태 기록 유지
                HttpSession session = request.getSession();
                session.setAttribute("sessionUserId", userid);
                session.setAttribute("sessionUserName", memberName);
                session.setAttribute("sessionUserGrade", memberGrade);
                
                out.print("<script>");
                if ("관리자".equals(memberGrade)) {
                    out.print("alert('👑 [시스템 최고 관리자] 로그인에 성공했습니다. 관리자 전용 대시보드로 이동합니다.');");
                    out.print("location.href='" + request.getContextPath() + "/Admin/bootmng.jsp';"); 
                } else {
                    out.print("alert('" + memberName + "님, 환영합니다! JYP HOTEL 로그인에 성공했습니다.');");
                    out.print("location.href='" + request.getContextPath() + "/wls/index.jsp';"); 
                }
                out.print("</script>");
                return;
                
            } else {
                out.print("<script>alert('아이디 또는 비밀번호가 일치하지 않습니다.'); history.back();</script>");
                return;
            }

        } catch (Exception e) {
            // 💡 로그인 중에 예외가 터지면 하얀 화면 대신 핑크색 상자에 진짜 영어 원인을 즉시 렌더링합니다.
            e.printStackTrace();
            out.println("<div style='padding:30px; background:#fff0f0; border:2px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
            out.println("<h2>⚠️ 로그인 서블릿 백엔드 에러 발생!</h2>");
            out.println("<hr style='border:1px solid #ffcccc;'>");
            out.println("<pre style='background:#fff; padding:15px; border:1px solid #ddd; font-size:14px; overflow-x:auto;'>" + e.toString() + "</pre>");
            out.println("</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ex) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) {}
            if (conn != null) try { conn.close(); } catch (SQLException ex) {}
        }
    }

    }

