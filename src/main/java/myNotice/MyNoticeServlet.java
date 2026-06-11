package myNotice;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

// 💡 @WebServlet: 브라우저나 JSP에서 '/api/myNotices' 주소로 신호를 보내면 이 자바 파일이 켜집니다.
@WebServlet("/notice/noticeList") 
public class MyNoticeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // 데이터베이스(MySQL)에 접속하기 위한 3대 정보 설정
    private final String url = "jdbc:mysql://localhost:3306/IT1project?serverTimezone=UTC";
    private final String user = "root";
    private final String pass = "1243"; // 💡 팀원들과 맞춘 MySQL 비밀번호를 적는 곳!
    
    /*
     * private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String URL    = "jdbc:oracle:thin:@localhost:1521:ORCL";  // SID 방식
    // 서비스명 방식: "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
    private static final String USER   = "proid";   // DB 계정
    private static final String PASS   = "3431";   // DB 비밀번호
     */

    // doPost: JSP 화면에서 'POST' 방식으로 데이터를 쏴주면 자동으로 실행되는 영역입니다.
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // [1] 한글 깨짐 방지: 화면에서 넘어온 글자들이 깨지지 않게 UTF-8로 인코딩합니다.
        request.setCharacterEncoding("UTF-8");
        
        // [2] 응답 형식 지정: 작업이 끝나고 화면(JSP)에 "성공/실패" 결과를 JSON이라는 텍스트 형태로 답장하겠다고 선언합니다.
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        // [3] JSP 화면에서 파라미터로 넘겨준 값들을 자바 변수에 하나씩 담습니다.
        String action = request.getParameter("action");       // "delete"면 삭제 모드, 없으면 저장/수정 모드
        String idParam = (String)session.getAttribute("userId");           // 글 고유 번호 (수정이나 삭제할 때 사용)
        
        
    }
}