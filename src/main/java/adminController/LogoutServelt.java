package adminController;

import java.io.IOException;
import java.io.PrintWriter; // 👈 알림창 출력을 위해 임포트 추가!
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/Admin/logout")
public class LogoutServelt extends HttpServlet { 
	private static final long serialVersionUID = 1L;
        
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. 현재 브라우저의 세션 가져오기
		HttpSession session = request.getSession();
		if (session != null) {
			session.removeAttribute("adminId");
			// 완전히 무효화하려면 주석을 푸셔도 됩니다.
			 session.invalidate(); 
		}
		
		// 위에서 알림창 처리가 안 되었을 때를 대비한 예비용 리다이렉트
		response.sendRedirect(request.getContextPath() + "/wls/index.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}