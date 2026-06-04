package adminController;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import adminDao.AdminDao;
import adminDto.AdminDto;
import adminDao.BootDao;
import adminDto.BootDto;

// 🎯 주소 매핑 URL 확인 필수 (현재 톰캣 환경에 맞게 주석 해제하여 사용하세요)
//@WebServlet("/Admin/bootmng")
public class Bootmng extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 요청 및 응답 인코딩을 최상단에서 완벽하게 정의
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // =========================================================================
        // 일반 페이지 로딩 (HTML / 테이블 리스트 출력) 로직 영역
        // =========================================================================
        HttpSession session = request.getSession();
        String adminId = "admin01";
        
        AdminDao adminDao = new AdminDao(); 
        AdminDto adminDto = new AdminDto();
        adminDto.setAdminId(adminId);
        AdminDto resultAdmin = adminDao.selectAdmin(adminId); 
        request.setAttribute("adminData", resultAdmin);
        
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

        // 날짜 범위 파라미터 제어
        String dateRange = request.getParameter("dateRange");
        String startDateStr = "";
        String endDateStr = "";
        SimpleDateFormat paramSdf = new SimpleDateFormat("yyyy-MM-dd");

        if (dateRange == null || dateRange.trim().isEmpty()) {
            Date today = new Date();
            Date nextWeek = new Date(today.getTime() + (1000L * 60 * 60 * 24 * 7));
            startDateStr = paramSdf.format(today);
            endDateStr = paramSdf.format(nextWeek);
            dateRange = startDateStr + " ~ " + endDateStr;
        } else if (dateRange.contains(" ~ ")) {
            String[] dates = dateRange.split(" ~ ");
            if (dates.length == 2) {
                startDateStr = dates[0].trim();
                endDateStr = dates[1].trim();
            }
        }

        // 예약 상태 파라미터 수신
        String bootStatus = request.getParameter("bootStatus");
        if (bootStatus == null) {
            bootStatus = "전체"; 
        }

        // DB에서 원본 데이터 추출
        List<BootDto> allBootList = bootDao.selectAllBoot(companyNo, 99999, 0); 
        List<BootDto> filteredList = new ArrayList<>();

        // 날짜와 예약 상태 복합 필터링 시스템
        if (allBootList != null) {
            for (BootDto boot : allBootList) {
                // A. 날짜 필터링
                if (!startDateStr.isEmpty() && !endDateStr.isEmpty()) {
                    String checkInDate = boot.getBootCheckin(); 
                    if (checkInDate == null || checkInDate.trim().isEmpty()) continue; 
                    if (checkInDate.length() >= 10) checkInDate = checkInDate.substring(0, 10);
                    if (checkInDate.compareTo(startDateStr) < 0 || checkInDate.compareTo(endDateStr) > 0) continue; 
                }
                
                // B. 예약 상태 필터링 (bootConfirm 매칭)
                if (!"전체".equals(bootStatus)) {
                    int confirmVal = boot.getBootConfirm();
                    if ("결제완료".equals(bootStatus) && confirmVal != 0) {
                        continue; 
                    }
                    if ("예약확정".equals(bootStatus) && confirmVal != 1) {
                        continue; 
                    }
                }
                
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
        // ⭐ [핵심 복구 영역] JSP로 데이터 바인딩 및 화면 포워딩
        // =========================================================================
        request.setAttribute("bootList", finalBootList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("bootStatus", bootStatus);

        // JSP 경로가 맞는지 프로젝트 구조를 꼭 확인하세요 (/Admin/ 혹은 /admin/)
        request.getRequestDispatcher("/Admin/bootmng.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}