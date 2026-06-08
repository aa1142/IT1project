package adminController;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 🎯 지난번 JSP에서 설정한 링크 주소인 "/Admin/onsitePayment"와 매핑을 일치시켰습니다.
@WebServlet("/Admin/onsitePayment")
public class OnSitePaymentServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 1. 한글 깨짐 방지 인코딩 설정 (공통 필터가 있다면 생략 가능)
		request.setCharacterEncoding("UTF-8");

		// 2. JSP 검색 필터 및 페이징 파라미터 수신
		String pageParam = request.getParameter("page");
		String searchDate = request.getParameter("searchDate");
		String payStatus = request.getParameter("payStatus");
		String keyword = request.getParameter("keyword");

		// 3. 페이징 처리를 위한 현재 페이지 번호 계산 (기본값: 1페이지)
		int currentPage = 1;
		if (pageParam != null && !pageParam.trim().isEmpty()) {
			try {
				currentPage = Integer.parseInt(pageParam);
			} catch (NumberFormatException e) {
				currentPage = 1; // 이상한 문자열이 들어오면 1페이지로 방어 조치
			}
		}
		
		// 한 페이지에 보여줄 데이터 개수 (아까 화면 예시 기준 5개씩 끊기)
		int recordsPerPage = 5; 

		// 4. [비즈니스 로직 작성 구간] DAO 및 DB 연동용 주석 가이드
		/*
		// TODO: 작업 중이신 서비스나 DAO 호출 코드 적용 영역
		OnSitePaymentDao dao = new OnSitePaymentDao();
		
		// 필터 조건에 맞는 전체 데이터 개수 조회 (페이지네이션 계산용)
		int totalRecords = dao.getTotalCount(searchDate, payStatus, keyword);
		int totalPage = (int) Math.ceil((double) totalRecords / recordsPerPage);
		if (totalPage == 0) totalPage = 1; // 최소 1페이지는 유지
		
		// 현재 페이지 범위에 맞는 데이터 리스트 조회 (ROWNUM 혹은 BETWEEN 연산용)
		List<BootDto> bootList = dao.selectOnSitePaymentList(currentPage, recordsPerPage, searchDate, payStatus, keyword);
		request.setAttribute("bootList", bootList);
		*/
		
		// 임시 테스트용 데이터 (DB 연결 전 화면 확인용)
		int totalPage = 3; 

		// 5. JSP 화면으로 들고 갈 데이터 보관함(request)에 담기
		request.setAttribute("currentPage", currentPage);
		request.setAttribute("totalPage", totalPage);
		request.setAttribute("searchDate", searchDate);
		request.setAttribute("payStatus", payStatus);

		// 6. 현장결제 view 페이지(JSP)로 파일 흐름 넘기기 (포워딩)
		// 프로젝트 내 실제 onsitePayment.jsp 파일이 위치한 경로를 적어주셔야 합니다.
		request.getRequestDispatcher("/Admin/onsitePayment.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// 🎯 추후에 '신청 승인'이나 '결제 완료' 버튼을 눌러 상태를 변경(DB Update)할 때 주로 쓰입니다.
		request.setCharacterEncoding("UTF-8");
		
		// 지금은 단순 조회 처리가 대부분이므로 doGet으로 흐름을 넘겨둡니다.
		doGet(request, response);
	}
}