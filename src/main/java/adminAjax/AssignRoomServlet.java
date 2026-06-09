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

@WebServlet("/admin/assignRoom.do")
public class AssignRoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 사용하지 않으므로 비워둠
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Integer companyNo = (Integer) session.getAttribute("companyNo");
        
        // 임시 데이터
        companyNo = 1;
        
        BootDao bootDao = new BootDao();
        String bootNoStr = request.getParameter("bootNo");
        String roomNoStr = request.getParameter("roomNo");
        
        
        
        
        int bootNo = 0;
        int roomNo = 0;
        try {
            if (bootNoStr != null) bootNo = Integer.parseInt(bootNoStr);
            if (roomNoStr != null) roomNo = Integer.parseInt(roomNoStr);
        } catch (NumberFormatException e) {
            System.out.println("숫자 변환 중 오류 발생! 넘어온 값 체크 필요.");
            e.printStackTrace();
        }
        
        // DB 실행 (성공 시 1, 실패 시 0 반환)
        int result = bootDao.assignRoom(bootNo, roomNo, companyNo);
        
        // 🎯 [해결의 핵심] AJAX 통신을 위한 JSON 응답 코드 추가
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        if (result > 0) {
            // 자바스크립트가 성공으로 인식할 수 있도록 JSON 반환
            out.print("{\"status\": \"success\"}");
            System.out.println("🎯 [Assign Room] 방 배정 성공! (BootNo: " + bootNo + ", RoomNo: " + roomNo + ")");
        } else {
            // 실패 시 메시지와 함께 fail 반환
            out.print("{\"status\": \"fail\", \"message\": \"방 배정 처리 중 오류가 발생했습니다.\"}");
            System.out.println("❌ [Assign Room] 방 배정 실패 (변경원인 없음)");
        }
        
        out.flush();
        out.close();
    }
}