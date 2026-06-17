package adminController;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.BootDao;
import dto.BootDto;

@WebServlet("/Admin/onsitePayment")
public class OnSitePaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 한글 깨짐 방지 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        
        // 2. 검색 필터 및 페이징 파라미터 수신
        String bootTime = request.getParameter("bootTime");
        if(bootTime == null) bootTime = "upcoming";
        
        String bootStatus = request.getParameter("bootStatus");
        if (bootStatus == null) bootStatus = "전체"; 
        
        int currentPage = 1; 
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1; 
            }
        }

        // 기본 설정 값
        HttpSession session = request.getSession();
        Integer companyNo = (Integer)session.getAttribute("companyNo");
//        companyNo = 1;
        BootDao bootDao = new BootDao();
        int pageSize = 5; 
        int payCheck = 1; // 🎯 현장 결제 건만 필터링하기 위한 고유 조건 값
        
        // DB에서 원본 데이터 추출 (최대 데이터로 가져와 인메모리 필터링)
        List<BootDto> allBootList = bootDao.selectAllBoot(companyNo, 99999, 0, bootTime, payCheck); 
        List<BootDto> filteredList = new ArrayList<>();

        // 3. 예약 상태 조건으로 복합 필터링
        if (allBootList != null) {
            for (BootDto boot : allBootList) {
                if (!"전체".equals(bootStatus)) {
                    int confirmVal = boot.getBootConfirm();
                    if ("예약대기".equals(bootStatus) &&confirmVal != 0) {
                    	continue;
                    }
                    if ("예약확정".equals(bootStatus) &&confirmVal != 1) {
                    	continue;
                    }
                }
                filteredList.add(boot);
            }
        }

        // 4. 필터링된 기준 데이터로 실제 페이지 수 재연산
        int totalCount = filteredList.size(); 
        int totalPage = (int) Math.ceil((double) totalCount / pageSize); 
        if (totalPage < 1) totalPage = 1; 

        if (currentPage > totalPage) { 
            currentPage = totalPage;
        }

        // 5. 최종 페이징 데이터 쪼개기 (화면에 보여줄 만큼만 추출)
        int offset = (currentPage - 1) * pageSize;
        List<BootDto> finalBootList = new ArrayList<>();
        
        for (int i = offset; i < offset + pageSize && i < filteredList.size(); i++) {
            finalBootList.add(filteredList.get(i));
        }
        
        // 6. JSP로 보낼 데이터 바인딩
        request.setAttribute("bootList", finalBootList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("bootStatus", bootStatus);
        request.setAttribute("bootTime", bootTime);

        // 7. 현장결제용 JSP 화면으로 포워딩
        request.getRequestDispatcher("/Admin/onsitePayment.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // 단순 조회나 필터 검색은 GET으로 처리하므로 흐름을 넘겨둡니다.
        doGet(request, response);
    }
}