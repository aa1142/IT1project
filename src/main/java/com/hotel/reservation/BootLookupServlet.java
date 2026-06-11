package com.hotel.reservation;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// 외부 URL 호출 주소를 명칭 대통합 규칙에 맞게 /bootLookup 으로 개정
@WebServlet("/bootLookup")
public class BootLookupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * boot.jsp(결제 대기 화면)에서 [카카오페이 결제하기] 버튼을 누르면 이 서블릿이 징검다리로 먼저 가로챕니다.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // 1. boot.jsp가 hidden 필드로 던져준 신규 파라미터 규격 수집
            String bootNo = request.getParameter("bootNo"); // 새 문자열 PK (B2026...)
            String reservationCode = request.getParameter("reservationCode");
            String itemName = request.getParameter("itemName");
            String quantity = request.getParameter("quantity");
            String bootPayCheck = request.getParameter("bootPayCheck"); // 바뀐 금액 변수
            String taxFreeAmount = request.getParameter("taxFreeAmount");
            String bootName = request.getParameter("bootName");
            String bootEmail = request.getParameter("bootEmail");
            String bootPhone = request.getParameter("bootPhone");

            // 2. 데이터 유실 및 위변조 방어벽
            if (bootNo == null || bootNo.trim().isEmpty()) {
                request.setAttribute("errorMessage", "예약 식별 데이터(bootNo)가 유실되어 결제를 진행할 수 없습니다.");
                request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
                return;
            }

            // 3. [핵심 Lookup 기능] 진짜 Oracle DB에 이 예약 정보가 실존하는지 검증
            BootDAO dao = new BootDAO();
            // 예약 코드와 연락처를 기반으로 단건 검증 조회 실행
            BootDTO currentBoot = dao.findByReservationCodeAndPhone(reservationCode, bootPhone);

            // 4. 만약 그 사이 데이터가 증발했거나 검증이 실패한 경우 결제 강제 차단
            if (currentBoot == null) {
                request.setAttribute("errorMessage", "유효한 예약(BOOT) 내역을 찾을 수 없습니다. 다시 시도해 주세요.");
                request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
                return;
            }

            // 5. 검증 관문을 무사히 통과했다면, 카카오 결제 준비기(KakaoReadyServlet)로 보낼 데이터를 request에 바인딩
            request.setAttribute("bootNo", bootNo);
            request.setAttribute("reservationCode", reservationCode);
            request.setAttribute("itemName", itemName);
            request.setAttribute("quantity", quantity);
            request.setAttribute("bootPayCheck", bootPayCheck);
            request.setAttribute("taxFreeAmount", taxFreeAmount);
            request.setAttribute("bootName", bootName);
            request.setAttribute("bootEmail", bootEmail);

            // 6. 다음 백엔드 일꾼인 카카오 결제 요청 처리기(KakaoReadyServlet)로 forward 토스!
            request.getRequestDispatcher("/kakaoReady").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "결제 전 예약 검증(Lookup) 과정 중 백엔드 오류: " + e.getMessage());
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
        }
    }
}