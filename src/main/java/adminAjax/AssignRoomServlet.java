package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.hotel.mail.MailService;

import dao.BootDao;
import dto.BootDto;

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
	    String sessionCompanyNo = (String) session.getAttribute("companyNo");
	    int companyNo = 0;
	    if (sessionCompanyNo != null) { companyNo = Integer.parseInt(sessionCompanyNo); } 
        
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
        
        // 1. 방 배정 전, 현재 예약 정보(이메일, 이름, 결제타입 등)를 미리 확보합니다.
        BootDto bootDto = bootDao.selectOneBoot(bootNo);
        // DB 실행 (성공 시 1, 실패 시 0 반환)
        int result = bootDao.assignRoom(bootNo, roomNo, companyNo);
        
        // AJAX 통신을 위한 JSON 응답 코드
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        
        System.out.println("PayCheck="+bootDto.getBootPayCheck());
        
        if (result > 0) {
            // 🎯 [핵심 추가] 방 배정 성공 시, '현장결제' 건인지 판별하여 메일 발송
            // bootPayCheck -> 0: 온라인결제(패스), 1: 현장결제(메일 발송)
            if (bootDto != null && bootDto.getBootPayCheck() == 1) {
                
                // 효과적으로 쓰기 위해 변수 준비 (Lambda 내부에서 쓰기 위함)
                final BootDto currentBoot = bootDto;
                final String assignedRoomNo = roomNoStr;
                
              
                // 톰캣 스레드가 메일 보내느라 멈추지 않도록 별도 스레드로 비동기 처리
                new Thread(() -> {
                    try {
                        MailService mailService = new MailService();
                        String reservationCode = "Hotel-" + System.currentTimeMillis(); // 고유코드 조합 예시
                          int resultUp = bootDao.updateBootCode(reservationCode, currentBoot.getBootNo());
                          if(resultUp>0 && currentBoot.getMemberId()!=null) {
                        	  resultUp = bootDao.updateMemberCountUp(currentBoot.getMemberId());
                			}
                        if(resultUp>0) {
                        	
                      
                        int roomTypeNo = currentBoot.getRoomType();
                        
                        String roomName ="";
                        switch (roomTypeNo) {
        				case 1:
        					roomName = "シングル";
        					break;
        					
        				case 2:
        					roomName = "ツイン";
        					break;
        					
        				case 5:
        					roomName = "ファミリー";
        					break;

        				}
                        
                        
                        // 이전 답변에서 만들어 둔 현장결제 전용 메일 템플릿 호출
                        mailService.sendOnsiteConfirmMail(
                            currentBoot.getBootEmail(),   // 수신자 이메일
                            currentBoot.getBootName(),    // 고객명
                            reservationCode,              // 고유코드
                            currentBoot.getRoomGrade(),   // 객실 등급
                            roomName          // 방 타입
                        );
                        }
                        System.out.println("📬 [자동 발송 성공] 현장결제 고객(" + currentBoot.getBootEmail() + ")에게 확정 메일을 보냈습니다.");
                    } catch (Exception e) {
                        System.err.println("❌ [자동 발송 실패] 메일 컴포넌트 에러: " + e.getMessage());
                        e.printStackTrace();
                    }
                }).start();
            }

            // 기존 자바스크립트 성공 응답 유지
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