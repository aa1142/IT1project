package adminController;

import java.io.IOException;
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

import dao.BootDao;
import dao.RoomDao;
import dto.RoomDto;

@WebServlet("/Admin/roomStatus")
public class BootStatusServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
	    RoomDao roomDao = new RoomDao();
	    BootDao bootDao = new BootDao();
	    Integer sessionCompanyNo = (Integer) session.getAttribute("companyNo");
	    if (sessionCompanyNo == null) { sessionCompanyNo = 1; } // 임시 디버깅용
	    int companyNo = sessionCompanyNo;
	    
	    // 1. 왼쪽 사이드바용 등급별 개수
	    Map<String, Integer> roomCounts = roomDao.selectCountRoomGrade(companyNo);
	    request.setAttribute("roomCounts", roomCounts);
	    
	    // 2. 오른쪽 메인 영역용 전체 객실 목록
	    List<RoomDto> roomList = roomDao.selectAllRooms(companyNo);
	    request.setAttribute("roomList", roomList);
	    // 3. 📊 상단 요약 카드 실시간 카운팅
	    int available = 0;  // 사용 가능
	    int occupied = 0;   // 사용 중 (예약중)
	    int cleaning = 0;   // 청소 중
	    int inspecting = 0; // 점검 중
	    
	    for (RoomDto room : roomList) {
	        String status = (String) room.getRoomNow();
	        if ("사용 가능".equals(status)) available++;
	        else if ("투숙 중".equals(status)) occupied++;
	        else if ("청소 중".equals(status)) cleaning++;
	        else if ("점검 중".equals(status)) inspecting++;
	    }
	    request.setAttribute("countAvailable", available);
	    request.setAttribute("countOccupied", occupied);
	    request.setAttribute("countCleaning", cleaning);
	    request.setAttribute("countInspecting", inspecting);
	    
	    // JSP로 포워드
	    request.getRequestDispatcher("/Admin/roomStatus.jsp").forward(request, response);
	}
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
	}

}
