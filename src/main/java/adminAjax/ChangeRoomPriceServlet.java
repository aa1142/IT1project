package adminAjax;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.RoomDao;

@WebServlet("/admin/updateRoomPrice.do")
public class ChangeRoomPriceServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. 인코딩 설정 (한글 깨짐 방지 및 plain text 응답 설정)
				request.setCharacterEncoding("UTF-8");
				response.setContentType("text/plain;charset=UTF-8");
				
				HttpSession session = request.getSession();
				Integer companyNo = (Integer)session.getAttribute("companyNo");
				// 2. AJAX가 보낸 파라미터 수신
				String roomGrade = request.getParameter("roomGrade");
				String priceSingleStr = request.getParameter("priceSingle");
				String priceTwinStr = request.getParameter("priceTwin");
				String priceFamilyStr = request.getParameter("priceFamily");
				
				// [콘솔 확인용] 데이터가 서버에 잘 도착했는지 체크해보세요!
				System.out.println("[ChangeRoomPriceServlet] 요청 수신 -> 등급: " + roomGrade 
						+ " | シングル: " + priceSingleStr + " | ツイン: " + priceTwinStr + " | ファミリー: " + priceFamilyStr);
				
				// 3. 변수 초기화 및 숫자 데이터 파싱 (null 및 빈값 방어 코드)
				int priceSingle = (priceSingleStr != null && !priceSingleStr.isEmpty()) ? Integer.parseInt(priceSingleStr) : 0;
				int priceTwin = (priceTwinStr != null && !priceTwinStr.isEmpty()) ? Integer.parseInt(priceTwinStr) : 0;
				int priceFamily = (priceFamilyStr != null && !priceFamilyStr.isEmpty()) ? Integer.parseInt(priceFamilyStr) : 0;
				
				// AJAX로 돌려줄 최종 결과 변수 (기본값은 실패)
				String result = "fail"; 
				
				try {
					// 4. 🚀 [이곳에 DAO 호출 및 DB 반영 로직을 작성하세요]
					// 예시:
					RoomDao dao = new RoomDao();
					int updateResult = dao.changeRoomPrice(priceSingle, priceTwin, priceFamily, roomGrade, companyNo);
					
					
					if (updateResult > 0) {
						result = "success";
					}
				} catch (Exception e) {
					e.printStackTrace();
					result = "error"; // 에러 발생 시 프론트에 알림
				}
				
				// 5. AJAX success 함수로 결과값("success" 또는 "fail") 전송
				response.getWriter().print(result);
	}

}
