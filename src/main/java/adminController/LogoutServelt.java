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
		
		// 🎯 2. 안전한 Null 체크 후 로그아웃 성공 알림창 띄우기
		// session이 null이거나, adminId 속성이 정상적으로 지워졌는지 확인합니다.
		if (session == null || session.getAttribute("adminId") == null) {
			
			// 브라우저에게 한글 깨짐 방지 및 HTML/자바스크립트 형식임을 선언
			response.setContentType("text/html; charset=UTF-8");
			PrintWriter out = response.getWriter();
			
			// 자바스크립트로 알림창을 띄우고 로그인 페이지로 이동시킵니다.
			out.println("<script type='text/javascript'>");
			out.println("    alert('성공적으로 로그아웃되었습니다.');");
			out.println("    location.href = '" + request.getContextPath() + "/wls/index.jsp';");
			out.println("</script>");
			
			out.flush();
			out.close();
			return; // 🎯 중요: 알림창을 보냈으므로 아래쪽의 기존 sendRedirect 코드가 실행되지 않도록 메서드를 종료합니다.
		}
		
		// 위에서 알림창 처리가 안 되었을 때를 대비한 예비용 리다이렉트
		response.sendRedirect(request.getContextPath() + "/wls/index.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}