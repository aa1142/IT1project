package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 💡 브라우저 주소창에 /main 이라고 치면 실행되는 가상 주소 설정
@WebServlet("/main")
public class MainServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 유저가 주소창을 통해 메인 화면을 요청(GET 방식)할 때 발동합니다.
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 🔒 중요: 브라우저가 직접 접근할 수 없는 WEB-INF/wls/index.jsp 파일을 
        // 서버 내부 터널을 통해 안전하게 낚아채서 유저 화면에 강제로 띄워줍니다.
        request.getRequestDispatcher("/wls/index.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
