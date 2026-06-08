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

import dao.AdminDao;
import dao.BootDao;
import dto.AdminDto;
import dto.BootDto;

@WebServlet("/Admin/bootmng")
public class Bootmng extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 요청 및 응답 인코딩을 최상단에서 완벽하게 정의
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // =========================================================================
        // 일반 페이지 로딩 (HTML / 테이블 리스트 출력) 로직 영역
        // =========================================================================

        
        String bootTime = request.getParameter("bootTime");
        if(bootTime == null) bootTime = "upcoming";
        
        BootDao bootDao = new BootDao();
        int companyNo = 1;
        int pageSize = 5; 
        
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

        // 🎯 [수정] 날짜 범위 파라미터 제어 영역(Flatpickr 연동 코드)을 완전히 제거했습니다.

        // 예약 상태 파라미터 수신
        String bootStatus = request.getParameter("bootStatus");
        if (bootStatus == null) {
            bootStatus = "전체"; 
        }
        
        int payCheck=0;
        
        // DB에서 원본 데이터 추출
        List<BootDto> allBootList = bootDao.selectAllBoot(companyNo, 99999, 0, bootTime, payCheck); 
        List<BootDto> filteredList = new ArrayList<>();

        // 🎯 [수정] 예약 상태로만 깔끔하게 복합 필터링 시스템 가동
        if (allBootList != null) {
            for (BootDto boot : allBootList) {
                
                // A. 예약 상태 필터링 (bootConfirm 매칭)
                if (!"전체".equals(bootStatus)) {
                    int confirmVal = boot.getBootConfirm();
                    if ("결제완료".equals(bootStatus) && confirmVal != 0) {
                        continue; 
                    }
                    if ("예약확정".equals(bootStatus) && confirmVal != 1) {
                        continue; 
                    }
                }
                
                // 상태 조건에 생존한 데이터만 리스트에 담기
                filteredList.add(boot);
            }
        }

        // 필터링 기준 진짜 페이지 수 재연산
        int totalCount = filteredList.size(); 
        int totalPage = (int) Math.ceil((double) totalCount / pageSize); 
        if (totalPage < 1) totalPage = 1; 

        if (currentPage > totalPage) { 
            currentPage = totalPage;
        }

        // 최종 페이징 쪼개기
        int offset = (currentPage - 1) * pageSize;
        List<BootDto> finalBootList = new ArrayList<>();
        
        for (int i = offset; i < offset + pageSize && i < filteredList.size(); i++) {
            finalBootList.add(filteredList.get(i));
        }
        
        // =========================================================================
        // ⭐ JSP로 데이터 바인딩 및 화면 포워딩 (dateRange 제거)
        // =========================================================================
        request.setAttribute("bootList", finalBootList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("bootStatus", bootStatus);
        request.setAttribute("bootTime", bootTime);

        // JSP 경로로 포워딩
        request.getRequestDispatcher("/Admin/bootmng.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}