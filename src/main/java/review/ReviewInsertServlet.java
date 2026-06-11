package review;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/review/reviewWrite")
public class ReviewInsertServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 request.setCharacterEncoding("UTF-8");
		 response.setContentType("application/json;charset=UTF-8");
		 ReviewDao reviewDao = new ReviewDao();
		 ReviewDto reviewDto = new ReviewDto();
		 int reviewNo = Integer.parseInt(request.getParameter("reviewNo"));
		 
		 reviewDto.setReviewNo(reviewNo);
		 
		 
		 reviewDao.insertReview(reviewDto);
		 
		 
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
