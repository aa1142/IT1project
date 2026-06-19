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
        String content = request.getParameter("content");

        ReviewDto reviewDto = new ReviewDto();
        reviewDto.setReviewNo(reviewNo);
        reviewDto.setCompanyNo(branch);
        reviewDto.setBranch(branch);
        reviewDto.setRating(rating);
        reviewDto.setContent(content);

        ReviewDao reviewDao = new ReviewDao();
        reviewDao.updateReview(reviewDto);

        response.sendRedirect(request.getContextPath() + "/review/reviewList");
    }
}
