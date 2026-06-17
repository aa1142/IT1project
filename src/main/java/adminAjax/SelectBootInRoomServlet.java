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
import dto.BootDto;

@WebServlet("/Admin/getSelectBoot")
public class SelectBootInRoomServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. 인코딩 및 응답 타입 설정 (getWriter 호출 전에 확실하게 명시)
		request.setCharacterEncoding("UTF-8");
		response.setContentType("application/json; charset=UTF-8"); 
		
		HttpSession session = request.getSession();
		BootDao bootDao = new BootDao();
		
		// 2. 세션 및 파라미터 값 추출
		Integer companyNoObj = (Integer)session.getAttribute("companyNo");
		int companyNo = (companyNoObj != null) ? companyNoObj : 0;
		String roomNoStr = request.getParameter("roomNo");
		int roomNo = 0;
		
		if (roomNoStr != null && !roomNoStr.equals("")) {
			roomNo = Integer.parseInt(roomNoStr);
		}
		
		// [더미데이터] 테스트용 유지
//		companyNo = 1;
		
		// 3. DB에서 데이터 조회 (이전 단계에서 추천한 소문자 메서드명 반영)
		BootDto bootDto = bootDao.SelectOneBootInRoom(roomNo, companyNo);
		 
		
		PrintWriter out = response.getWriter();
		String jsonResponse = ""; // 💡 JSON 문자열을 담을 변수 선언
		
		// 4. 데이터 존재 여부에 따른 JSON 응답 조립
		if (bootDto != null) {
			// [Case 1] 현재 방에 투숙객이 존재할 때
			jsonResponse = "{"
				+ "\"roomNo\":" + bootDto.getRoomNo() + ","
				+ "\"companyNo\":" + bootDto.getCompanyNo() + ","
				+ "\"bootName\":\"" + (bootDto.getBootName() != null ? bootDto.getBootName() : "-") + "\","
				+ "\"bootPhone\":\"" + (bootDto.getBootPhone() != null ? bootDto.getBootPhone() : "-") + "\","
				+ "\"bootAdult\":" + bootDto.getBootAdult() + ","
				+ "\"bootChild\":" + bootDto.getBootChild() + ","
				+ "\"bootCheckin\":\"" + (bootDto.getBootCheckin() != null ? bootDto.getBootCheckin() : "") + "\","
				+ "\"bootCheckout\":\"" + (bootDto.getBootCheckout() != null ? bootDto.getBootCheckout() : "") + "\""
				+ "}";
		} else {
			// [Case 2] 🌟 중요: 현재 투숙객이 없는 빈 방일 때!
			// 아무것도 안 보내면 AJAX에서 'JSON 파싱 에러'가 나므로, 빈 껍데기와 다음 예약 정보라도 보내줍니다.
			jsonResponse = "{"
				+ "\"bootName\":null" // JSP의 if(res.bootName) 조건문이 정상적으로 false가 됨
				+ "}";
		}
		
		// 5. 최종 완성된 JSON 출력
		out.print(jsonResponse); 
		out.flush();
		out.close();
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}