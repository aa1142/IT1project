package review;

import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/review/reviewList")
public class ReviewListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        ReviewDao reviewDao = new ReviewDao();
        ArrayList<ReviewDto> reviewList = reviewDao.getReviewList();

        request.setAttribute("reviewList", reviewList);
        request.getRequestDispatcher("/review/reviewList.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        ReviewDao reviewDao = new ReviewDao();

        if ("delete".equals(action)) {
            int reviewNo = Integer.parseInt(request.getParameter("reviewNo"));
            reviewDao.deleteReview(reviewNo);
            response.sendRedirect(request.getContextPath() + "/review/reviewList");
            return;
        }

        if ("update".equals(action)) {
            ReviewDto reviewDto = new ReviewDto();
            reviewDto.setReviewNo(Integer.parseInt(request.getParameter("reviewNo")));
            reviewDto.setCompanyNo(Integer.parseInt(request.getParameter("branch")));
            reviewDto.setBranch(Integer.parseInt(request.getParameter("branch")));
            reviewDto.setRating(Integer.parseInt(request.getParameter("rating")));
            reviewDto.setContent(request.getParameter("content"));

            reviewDao.updateReview(reviewDto);
            response.sendRedirect(request.getContextPath() + "/review/reviewList");
            return;
        }

        doGet(request, response);
    }
}
