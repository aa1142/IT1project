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

// 💡 회원가입 폼 양식이 전송될 가상 주소 설정 (.jsp를 제거)
@WebServlet("/signupAction")
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 비밀번호 단방향 해시 암호화 (SHA-256) 메서드 통합
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

    // 💡 회원가입 성공 후 wls 폴더 내부의 signupSuccess.jsp를 안전하게 열어주는 GET 통로
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 🛠️ 괄호 꼬임 해결 및 일반 wls 폴더 내부의 signup.jsp로 즉시 리다이렉트
        response.sendRedirect(request.getContextPath() + "/wls/signup.jsp");
    }

    // 💡 회원가입 완료 메시지(Alert) 버그를 완벽히 해결한 doPost 메서드
    // 💡 하얀 화면 버그를 깨부수고 진짜 오라클 에러를 노출시키는 진단용 doPost 메서드
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 최상단 강제 지정
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 1. 프론트엔드 파라미터 데이터 수집
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

            // 2. 평문 비밀번호 암호화 가공
            String encryptedPw = encryptSHA256(userpw);

            // 3. 오라클 데이터베이스 연동 정보 설정 (orcl 또는 xe 체크)
            String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl"; 
            String dbUser = "scott";                 
            String dbPass = "tiger";

            Connection conn = null;
            PreparedStatement pstmt = null;

            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 오라클 테이블 컬럼 규격 매칭 삽입
            String sql = "INSERT INTO member (member_id, member_pw, member_name, member_phone, member_grade, member_email, member_address) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, userid);
            pstmt.setString(2, encryptedPw);
            pstmt.setString(3, nameKo != null ? nameKo : "미입력");
            pstmt.setString(4, phone);
            pstmt.setString(5, "일반"); 
            pstmt.setString(6, email != null ? email : "test@test.com");
            pstmt.setString(7, address);

            int result = pstmt.executeUpdate();

            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();

            if (result > 0) {
                // 회원가입 성공 시 페이지 리다이렉트
                out.println("<script>");
                out.println("alert('" + nameKo + " 회원님, JYP HOTEL 회원가입을 축하합니다!');");
                out.println("location.href='" + request.getContextPath() + "/wls/signupSuccess.jsp?name=" + java.net.URLEncoder.encode(nameKo, "UTF-8") + "';");
                out.println("</script>");
                return;
            } else {
                out.println("<h3>회원가입 실패: 저장된 행이 없습니다.</h3>");
                return;
            }

        } catch (Exception e) {
            // 💡 [핵심 디버깅 바인딩] 하얀 화면 대신 진짜 자바/오라클 에러를 브라우저에 그대로 출력합니다.
            e.printStackTrace();
            out.println("<div style='padding:30px; background:#fff0f0; border:2px solid #ffcccc; color:#d93025; margin:50px; font-family:sans-serif;'>");
            out.println("<h2>⚠️ 회원가입 서블릿 백엔드 에러 발생!</h2>");
            out.println("<hr style='border:1px solid #ffcccc;'>");
            out.println("<p style='font-size:16px; font-weight:bold;'>[진짜 원인 코드] :</p>");
            out.println("<pre style='background:#fff; padding:15px; border:1px solid #ddd; font-size:14px; overflow-x:auto;'>" + e.toString() + "</pre>");
            out.println("<p style='font-size:14px; color:#555;'>위 상자 안의 영어 텍스트 메시지를 복사해서 알려주시면 버그를 즉시 종료해 드립니다.</p>");
            out.println("</div>");
        }
    }

}
