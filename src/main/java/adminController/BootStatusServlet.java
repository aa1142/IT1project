package adminController;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.RoomDao;
import dto.RoomDto;

@WebServlet("/Admin/bootStatus")
public class BootStatusServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
	    String sessionCompanyNo = (String) session.getAttribute("companyNo");
	    int companyNo = 0;
	    if (sessionCompanyNo != null) { companyNo = Integer.parseInt(sessionCompanyNo); } 
		//회사 더미데이터
//		companyNo = 1;
		RoomDao roomDao = new RoomDao();
		List<RoomDto> priceList = roomDao.selectRoomPrice(companyNo);
		
		
		request.setAttribute("priceList", priceList);
		request.getRequestDispatcher("/Admin/bootStatus.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
