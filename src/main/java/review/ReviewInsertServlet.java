package review;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/review/reviewInsert")
public class ReviewInsertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
        int branch = Integer.parseInt(request.getParameter("branch"));
        String roomGrade = request.getParameter("roomgrade");
        int roomType = Integer.parseInt(request.getParameter("roomtype"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        int scoreLocation = Integer.parseInt(request.getParameter("score_location"));
        int scoreCleanliness = Integer.parseInt(request.getParameter("score_cleanliness"));
        int scoreService = Integer.parseInt(request.getParameter("score_service"));
        int scorePrice = Integer.parseInt(request.getParameter("score_price"));
        int scoreFacilities = Integer.parseInt(request.getParameter("score_facilities"));

        ReviewDto reviewDto = new ReviewDto();
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
}
