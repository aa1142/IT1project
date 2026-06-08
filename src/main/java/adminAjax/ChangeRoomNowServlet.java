package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.RoomDao;

@WebServlet("/Admin/updateRoomStatus")
public class ChangeRoomNowServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    // 인코딩 및 응답 형식 설정
	    request.setCharacterEncoding("UTF-8");
	    response.setContentType("text/plain; charset=UTF-8");
	    
	    HttpSession session = request.getSession();
	    RoomDao roomDao = new RoomDao();
	    
	    // 파라미터 수신
	    String roomNoStr = request.getParameter("roomNo");
	    int roomNo = 0;
	    if (roomNoStr != null && !roomNoStr.equals("")) {
	        roomNo = Integer.parseInt(roomNoStr);
	    }
	    String roomNow = request.getParameter("roomNow");
	    
	    // 세션 및 더미데이터
	    Integer companyObj = (Integer) session.getAttribute("companyNo");
	    int company = (companyObj != null) ? companyObj : 0;
	    company = 1; // 테스트용 더미
	    
	    // DB 업데이트
	    int result = roomDao.updateRoomNow(roomNow, roomNo, company);
	    
	    // AJAX 응답
	    PrintWriter out = response.getWriter();
	    if (result > 0) {
	        out.print("SUCCESS");
	    } else {
	        out.print("FAIL");
	    }
	    out.flush();
	    out.close();
	}

	// 2. 혹시나 나중에 GET 요청이 들어오더라도 안전하게 POST 쪽으로 넘겨버립니다.
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    doPost(request, response); 
	}

}
