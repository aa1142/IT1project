package review;

import java.io.IOException;
import java.sql.Connection;
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
            response.sendRedirect(request.getContextPath() + "/wls/login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String bootNo = request.getParameter("bootNo");
        if (bootNo == null || bootNo.trim().isEmpty()) {
            showAlert(response, request.getContextPath() + "/review/reviewReservation.jsp", "예약 정보를 먼저 선택해주세요.");
            return;
        }

        ReservationReviewInfo reservationInfo = findReservationReviewInfo(bootNo.trim(), memberId);
        if (reservationInfo == null) {
            showAlert(response, request.getContextPath() + "/review/reviewReservation.jsp", "선택한 예약 내역을 확인할 수 없습니다.");
            return;
        }

        ReviewDto reviewDto = new ReviewDto();
        reviewDto.setBootNo(bootNo.trim());
        reviewDto.setMemberid(memberId);
        reviewDto.setCompanyNo(reservationInfo.branch);
        reviewDto.setBranch(reservationInfo.branch);
        reviewDto.setRating(parseInt(request.getParameter("rating"), 0));
        reviewDto.setScore_location(parseInt(request.getParameter("score_location"), 5));
        reviewDto.setScore_cleanliness(parseInt(request.getParameter("score_cleanliness"), 5));
        reviewDto.setScore_service(parseInt(request.getParameter("score_service"), 5));
        reviewDto.setScore_price(parseInt(request.getParameter("score_price"), 5));
        reviewDto.setScore_facilities(parseInt(request.getParameter("score_facilities"), 5));
        reviewDto.setContent(content);

        ReviewDao reviewDao = new ReviewDao();
        int result = reviewDao.insertReview(reviewDto);

        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/review/reviewList");
        } else {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('리뷰 등록에 실패했습니다. Tomcat 콘솔 오류를 확인해주세요.'); history.back();</script>");
        }
    }

    private ReservationReviewInfo findReservationReviewInfo(String bootNo, String memberId) {
        String sql = "SELECT COMPANY_NO FROM BOOT WHERE TO_CHAR(BOOT_NO) = ? AND MEMBER_ID = ? AND BOOT_CONFIRM <> 2";

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bootNo);
            pstmt.setString(2, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ReservationReviewInfo info = new ReservationReviewInfo();
                    info.branch = rs.getInt("COMPANY_NO");
                    return info;
                }
            }
        } catch (Exception e) {
            System.err.println("[ReviewInsertServlet] findReservationReviewInfo failed: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private void showAlert(HttpServletResponse response, String location, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('" + message + "'); location.href='" + location + "';</script>");
    }
}
