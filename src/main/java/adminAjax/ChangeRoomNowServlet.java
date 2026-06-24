package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.BootDao;
import dao.RoomDao;
import dto.BootDto;

@WebServlet("/Admin/updateRoomStatus")
public class ChangeRoomNowServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    // 인코딩 및 응답 형식 설정
	    request.setCharacterEncoding("UTF-8");
	    response.setContentType("text/plain; charset=UTF-8");
	    
	    HttpSession session = request.getSession();
	    RoomDao roomDao = new RoomDao();
	    BootDao bootDao = new BootDao();
	    
	    
	    
	    // 파라미터 수신
	 // 1. 공통 필수 데이터 받기
	    int roomNo = Integer.parseInt(request.getParameter("roomNo"));
	    String roomNow = request.getParameter("roomNow");

	    // 2. 워크인(현장결제) 모드인지 확인하기 ("Y" 혹은 null이 들어옴)
	    String isWalkIn = request.getParameter("isWalkIn");
	    
	    // 세션 및 더미데이터
	    String sessionCompanyNo = (String) session.getAttribute("companyNo");
	    int companyNo = 0;
	    if (sessionCompanyNo != null) { companyNo = Integer.parseInt(sessionCompanyNo); } 
	    
	    int result = 0;//성공 여부
	    
	    
	    // 3. 조건문으로 현장 결제 데이터 처리 분기하기
	    if ("Y".equals(isWalkIn)) {
	        // 워크인 모드일 때만 전송되는 데이터 수집
	        String bootName = request.getParameter("bootName");
	        String bootPhone = request.getParameter("bootPhone");
	        int bootAdult = Integer.parseInt(request.getParameter("bootAdult"));
	        int bootChild = Integer.parseInt(request.getParameter("bootChild"));
	        String bootCheckin = request.getParameter("bootCheckin");
	        String bootCheckout = request.getParameter("bootCheckout");
	        String roomGrade = request.getParameter("roomGrade");
	        int roomType = Integer.parseInt(request.getParameter("roomType"));
	        System.out.println("roomNo="+roomNo);
	        // 4. 수집한 데이터 DTO에 세팅하기
	        BootDto bootDto = new BootDto();
	        bootDto.setRoomNo(roomNo);
	        bootDto.setBootNo("Hotel-"+System.currentTimeMillis());
	        bootDto.setBootName(bootName);
	        bootDto.setCompanyNo(companyNo);
	        bootDto.setBootPhone(bootPhone);
	        bootDto.setBootAdult(bootAdult);
	        bootDto.setBootChild(bootChild);
	        bootDto.setBootCheckin(bootCheckin);
	        bootDto.setBootCheckout(bootCheckout);
	        bootDto.setRoomGrade(roomGrade);
	        bootDto.setRoomType(roomType);
	        result = bootDao.assignRoom(bootDto);
	        if(result>0) {
	        	result = roomDao.updateRoomNow(roomNow, roomNo, companyNo);
	        }
	    }
	    else {
	    	result = roomDao.updateRoomNow(roomNow, roomNo, companyNo);
		}

	    System.out.println("방 업데이트"+result);
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
