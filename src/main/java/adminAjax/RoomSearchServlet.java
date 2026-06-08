package adminAjax;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import com.google.gson.Gson; // JSON 변환을 위해 GSON 라이브러리 사용 권장

import dao.RoomDao;
import dto.RoomDto;

@WebServlet("/admin/getAvailableRooms")
public class RoomSearchServlet extends HttpServlet {
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
	    System.out.println("=== 모달 서버 요청 진입 확인 ==="); // 최최상단에 배치
	    HttpSession session = request.getSession();
	    Integer companyNo = (Integer) session.getAttribute("companyNo");
	    try {
	        String grade = request.getParameter("grade");
	        String typeStr = request.getParameter("type");
	        String checkIn = request.getParameter("checkIn");
	        String checkOut = request.getParameter("checkOut");

	        System.out.println("넘어온 파라미터 -> grade: " + grade + ", type: " + typeStr + ", checkIn: " + checkIn + ", checkOut: " + checkOut);

	        // 안전하게 숫자 변환
	        int type = 1; 
	        if(typeStr != null && !typeStr.isEmpty()) {
	            type = Integer.parseInt(typeStr);
	        }
	        

	        // 1. 체크인 날짜 자르기
	        if (checkIn != null && checkIn.length() >= 10) {
	            checkIn = checkIn.substring(0, 10); // 인덱스 0부터 9까지(10글자) 잘라냄 -> "2026-06-05"
	        }

	        // 2. 체크아웃 날짜 자르기
	        if (checkOut != null && checkOut.length() >= 10) {
	            checkOut = checkOut.substring(0, 10); // -> "2026-06-06"
	        }
	        
	        
	        //회사 임시데이터
	        companyNo = 1;
	        RoomDao roomDao = new RoomDao();
	        List<RoomDto> list = roomDao.selectAvailableRooms(grade, type, checkIn, checkOut, companyNo);

	        System.out.println("룸 갯수 = " + (list != null ? list.size() : 0));

	        response.setContentType("application/json; charset=UTF-8");
	        Gson gson = new Gson();
	        String jsonResult = gson.toJson(list);

	        PrintWriter out = response.getWriter();
	        out.print(jsonResult);
	        out.flush();

	    } catch (Exception e) {
	        System.out.println("서블릿 내부에서 에러 발생!");
	        e.printStackTrace(); // 콘솔에 상세 에러 출력
	    }
	}
}