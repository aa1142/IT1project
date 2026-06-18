package review;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/review/reviewInsert")
public class ReviewInsertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static class ReservationReviewInfo {
        private int branch;
        private String roomGrade;
        private int roomType;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession httpSession = request.getSession();
        String memberId = (String) httpSession.getAttribute("sessionUserId");
        if (memberId == null) {
            memberId = (String) httpSession.getAttribute("userId");
        }
        if (memberId == null) {
            memberId = "testUser";
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String bootNo = request.getParameter("bootNo");
        int branch = Integer.parseInt(request.getParameter("branch"));
        String roomGrade = request.getParameter("roomgrade");
        int roomType = Integer.parseInt(request.getParameter("roomtype"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        int scoreLocation = Integer.parseInt(request.getParameter("score_location"));
        int scoreCleanliness = Integer.parseInt(request.getParameter("score_cleanliness"));
        int scoreService = Integer.parseInt(request.getParameter("score_service"));
        int scorePrice = Integer.parseInt(request.getParameter("score_price"));
        int scoreFacilities = Integer.parseInt(request.getParameter("score_facilities"));

        if (bootNo != null && !bootNo.trim().isEmpty()) {
            ReservationReviewInfo reservationInfo = findReservationReviewInfo(bootNo.trim(), memberId);
            if (reservationInfo == null) {
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().println("<script>alert('선택한 예약 내역을 확인할 수 없습니다.'); location.href='" + request.getContextPath() + "/review/reviewReservation.jsp';</script>");
                return;
            }

            branch = reservationInfo.branch;
            roomGrade = reservationInfo.roomGrade;
            roomType = reservationInfo.roomType;
        }

        ReviewDto reviewDto = new ReviewDto();
        reviewDto.setBootNo(bootNo == null || bootNo.trim().isEmpty() ? null : bootNo.trim());
        reviewDto.setMemberid(memberId);
        reviewDto.setCompanyNo(branch);
        reviewDto.setTitle(title);
        reviewDto.setContent(content);
        reviewDto.setBranch(branch);
        reviewDto.setRoomType(roomType);
        reviewDto.setRoomgrade(roomGrade);
        reviewDto.setRating(rating);
        reviewDto.setScore_location(scoreLocation);
        reviewDto.setScore_cleanliness(scoreCleanliness);
        reviewDto.setScore_service(scoreService);
        reviewDto.setScore_price(scorePrice);
        reviewDto.setScore_facilities(scoreFacilities);

        ReviewDao reviewDao = new ReviewDao();
        int result = reviewDao.insertReview(reviewDto);

        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/review/reviewList");
        } else {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('리뷰 등록에 실패했습니다. Tomcat 콘솔 오류를 확인하세요.'); history.back();</script>");
        }
    }

    private ReservationReviewInfo findReservationReviewInfo(String bootNo, String memberId) {
        String sql = "SELECT COMPANY_NO, ROOM_GRADE, ROOM_TYPE FROM BOOT WHERE BOOT_NO = ? AND MEMBER_ID = ? AND BOOT_CONFIRM <> 2";

        try {
            try {
                Class.forName("oracle.jdbc.OracleDriver");
            } catch (ClassNotFoundException e) {
                Class.forName("oracle.jdbc.driver.OracleDriver");
            }

            try (Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "scott", "tiger");
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, bootNo);
                pstmt.setString(2, memberId);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        ReservationReviewInfo info = new ReservationReviewInfo();
                        info.branch = rs.getInt("COMPANY_NO");
                        info.roomGrade = rs.getString("ROOM_GRADE");
                        info.roomType = rs.getInt("ROOM_TYPE");
                        return info;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[ReviewInsertServlet] findReservationReviewInfo failed: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }
}
