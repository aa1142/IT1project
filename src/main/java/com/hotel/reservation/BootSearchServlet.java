package com.hotel.reservation;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 외부 URL 호출 주소를 명칭 대통합 규칙에 맞게 /bootSearch 로 설정
@WebServlet("/bootSearch")
public class BootSearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * bootSearch.jsp 폼 화면에서 [예약 조회] 버튼을 누르면 POST 방식으로 요청이 들어옵니다.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. bootSearch.jsp 가 폼 데이터로 전송한 파라미터 수집
            String reservationCode = request.getParameter("reservationCode"); // ORD... 형태의 고유 코드
            String bootKeyword = request.getParameter("bootKeyword");         // 전화번호 또는 이메일

            // 2. 입력값 누락 예외 방어벽
            if (reservationCode == null || reservationCode.trim().isEmpty() ||
                bootKeyword == null || bootKeyword.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "예약코드와 검증용 키워드를 누락 없이 입력해 주세요.");
                request.getRequestDispatcher("/bootSearch.jsp").forward(request, response);
                return;
            }

            // 3. 새 일꾼 BootDAO를 깨워 Oracle DB로부터 조건에 맞는 BootDTO 바구니 인출
            BootDAO dao = new BootDAO();
            BootDTO bootDto = dao.findByReservationCodeAndPhoneOrEmail(reservationCode.trim(), bootKeyword.trim());

            // 4. [검증 실패] 일치하는 예약 내역이 DB에 존재하지 않는 경우
            if (bootDto == null) {
                request.setAttribute("errorMessage", "입력하신 정보와 일치하는 예약(BOOT) 내역을 찾을 수 없습니다.");
                // 원래 입력하던 화면으로 튕구고 에러 메시지 표출
                request.getRequestDispatcher("/bootSearch.jsp").forward(request, response);
                return;
            }

            // 5. [검증 성공] 찾은 진짜 가방(BootDTO)을 request 저장소에 "boot"라는 이름으로 적재
            request.setAttribute("boot", bootDto);

            // 6. 예약 정보를 시각적으로 보여주고 환불 버튼을 지원할 결과 페이지(bootDetail.jsp)로 Forward 토스
            request.getRequestDispatcher("/res/bootDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "백엔드 시스템 조회 오류: " + e.getMessage());
            request.getRequestDispatcher("/bootSearch.jsp").forward(request, response);
        }
    }

    /**
     * 혹시 모를 GET 방식 다이렉트 요청이 들어올 경우 조회 폼 화면으로 돌려보내는 안전장치
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/bootSearch.jsp");
    }
}