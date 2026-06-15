package com.hotel.reservation;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 외부 URL 호출 주소는 소문자로 대통합 규칙 유지 (/bootSearch)
@WebServlet("/bootSearch")
public class BootSearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. BootSearch.jsp 폼에서 전송한 파라미터 수집
            String reservationCode = request.getParameter("reservationCode"); 
            String bootKeyword = request.getParameter("bootKeyword");         

            // 2. [방어벽] 입력값 누락 시 대문자 /res/BootSearch.jsp 로 강제 복귀
            if (reservationCode == null || reservationCode.trim().isEmpty() ||
                bootKeyword == null || bootKeyword.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "예약코드와 검증용 키워드를 누락 없이 입력해 주세요.");
                request.getRequestDispatcher("/res/BootSearch.jsp").forward(request, response);
                return;
            }

            // 3. 새 일꾼 BootDAO를 깨워 Oracle DB로부터 조건에 맞는 BootDTO 바구니 인출
            BootDAO dao = new BootDAO();
            BootDTO bootDto = dao.findByReservationCodeAndPhoneOrEmail(reservationCode.trim(), bootKeyword.trim());

            // 4. [검증 실패] 일치하는 데이터가 없을 시 에러 메시지와 함께 다시 대문자 BootSearch.jsp 로 복귀
            if (bootDto == null) {
                request.setAttribute("errorMessage", "입력하신 정보와 일치하는 예약 내역을 찾을 수 없습니다.");
                request.getRequestDispatcher("/res/BootSearch.jsp").forward(request, response);
                return;
            }

            // 5. [검증 성공] 찾은 진짜 가방(BootDTO)을 request 저장소에 "boot"라는 이름으로 적재
            request.setAttribute("boot", bootDto);

            // 6. 🎯 [대소문자 싱크 완효] res 폴더 안의 대문자로 시작하는 BootDetail.jsp 로 시원하게 토스!
            request.getRequestDispatcher("/res/BootDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "백엔드 시스템 조회 오류: " + e.getMessage());
            request.getRequestDispatcher("/res/BootSearch.jsp").forward(request, response);
        }
    }

    // 7. 사용자가 주소창에 직접 치고 들어오는 등 GET 방식 요청 시 대문자 BootSearch.jsp 로 안전하게 이동
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/res/BootSearch.jsp");
    }
}