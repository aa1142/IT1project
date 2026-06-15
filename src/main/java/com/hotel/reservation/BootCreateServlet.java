package com.hotel.reservation;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// URL 매핑 주소도 예약 생성 정체성에 맞게 /bootCreate 로 변경
@WebServlet("/bootCreate")
public class BootCreateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // 1. 새 데이터 가방 인출 및 세팅
            BootDTO boot = new BootDTO();

            // 성 + 이름 결합 처리 로직 유지
            String combinedName = valueOrDefault(request.getParameter("bookerLastName"), "")
                    + valueOrDefault(request.getParameter("bookerFirstName"), "");
            
            if (combinedName.trim().isEmpty()) {
                combinedName = valueOrDefault(request.getParameter("bootName"), "고객");
            }

            // 브라우저 폼 파라미터 -> BootDTO 1:1 매핑
            boot.setRoomGrade(valueOrDefault(request.getParameter("roomGrade"), "STANDARD"));
            boot.setRoomType(parseInt(request.getParameter("roomType"), 2)); 
            boot.setRoomNo(parseInt(request.getParameter("roomNo"), 0));     
            boot.setCompanyNo(parseInt(request.getParameter("companyNo"), 1)); 
            boot.setMemberId(request.getParameter("memberId"));              
            
            boot.setBootPhone(valueOrDefault(request.getParameter("bootPhone"), request.getParameter("bookerPhone")));
            boot.setBootName(combinedName);
            boot.setBootEmail(request.getParameter("bootEmail"));
            
            boot.setBootCheckin(valueOrDefault(request.getParameter("bootCheckin"), "2026-06-15"));
            boot.setBootCheckout(valueOrDefault(request.getParameter("bootCheckout"), "2026-06-17"));
            boot.setBootAdult(parseInt(request.getParameter("bootAdult"), 2));
            boot.setBootChild(parseInt(request.getParameter("bootChild"), 0));
            
            // 금액 변수 규격 일치화 (bootPayCheck)
            boot.setBootPayCheck(parseInt(request.getParameter("bootPayCheck"), 50000));
            boot.setBootPlease(request.getParameter("bootPlease"));

            // 2. 새 일꾼 BootDAO 호출 및 오라클 적재 (상태값 0:대기 자동 배정)
            BootDAO dao = new BootDAO();
            String bootNo = dao.insertReservation(boot); // 문자열 고유 PK 반환

            // 3. 카카오페이 서블릿들과 가교 역할을 할 세션 저장소 적재
            HttpSession session = request.getSession();
            session.setAttribute("bootNo", bootNo);
            session.setAttribute("reservationCode", boot.getReservationCode()); 
            session.setAttribute("bootEmail", boot.getBootEmail());
            session.setAttribute("bootName", boot.getBootName());
            session.setAttribute("amount", boot.getBootPayCheck());

            // 4. 다음 정거장인 boot.jsp (결제 유도 화면) 포워딩 데이터 바인딩
            request.setAttribute("itemName", valueOrDefault(request.getParameter("itemName"), boot.getRoomGrade() + " 예약금"));
            request.setAttribute("quantity", valueOrDefault(request.getParameter("quantity"), "1"));
            request.setAttribute("bootPayCheck", String.valueOf(boot.getBootPayCheck()));
            request.setAttribute("taxFreeAmount", valueOrDefault(request.getParameter("taxFreeAmount"), "0"));
            request.setAttribute("bootNo", bootNo);
            request.setAttribute("reservationCode", boot.getReservationCode());

            // [명칭 대통합] 최종 목적지를 원래 reservation.jsp에서 boot.jsp로 전면 교체
            request.getRequestDispatcher("/res/boot.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "예약(BOOT) 데이터베이스 생성 오류: " + e.getMessage());
            request.getRequestDispatcher("/kakaoFail.jsp").forward(request, response);
        }
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            if (value == null || value.trim().isEmpty()) return defaultValue;
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static String valueOrDefault(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value;
    }
}