package review;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/review/reviewUpdate")
public class ReviewUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int reviewNo = Integer.parseInt(request.getParameter("reviewNo"));
        int branch = Integer.parseInt(request.getParameter("branch"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        int scoreLocation = Integer.parseInt(request.getParameter("score_location"));
        int scoreCleanliness = Integer.parseInt(request.getParameter("score_cleanliness"));
        int scoreService = Integer.parseInt(request.getParameter("score_service"));
        int scorePrice = Integer.parseInt(request.getParameter("score_price"));
        int scoreFacilities = Integer.parseInt(request.getParameter("score_facilities"));
        String content = request.getParameter("content");

        ReviewDto reviewDto = new ReviewDto();
        reviewDto.setReviewNo(reviewNo);
        reviewDto.setCompanyNo(branch);
        reviewDto.setBranch(branch);
        reviewDto.setRating(rating);
        reviewDto.setScore_location(scoreLocation);
        reviewDto.setScore_cleanliness(scoreCleanliness);
        reviewDto.setScore_service(scoreService);
        reviewDto.setScore_price(scorePrice);
        reviewDto.setScore_facilities(scoreFacilities);
        reviewDto.setContent(content);

        ReviewDao reviewDao = new ReviewDao();
        reviewDao.updateReview(reviewDto);

        response.sendRedirect(request.getContextPath() + "/review/reviewList");
    }
}
