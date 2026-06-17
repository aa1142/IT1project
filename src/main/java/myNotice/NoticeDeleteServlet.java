package myNotice;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import myNotice.NoticeDao;

@WebServlet("/deleteNotice.do")
public class NoticeDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // noticeList.jsp의 삭제 링크(<a> 태그)를 통해 GET 방식으로 요청이 들어옵니다.
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        if (!isNoticeAdmin(request)) {
            denyAccess(request, response);
            return;
        }
        
        // jsp에서 보낸 파라미터 값(?noticeNo=번호) 가로채기
        int noticeNo = Integer.parseInt(request.getParameter("noticeNo"));
        
        // DAO 객체를 만들어 DB 삭제 기능 호출
        NoticeDao dao = new NoticeDao();
        int result = dao.deleteNotice(noticeNo);
        
        // 결과 피드백창 설정
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        if (result > 0) {
            out.println("<script>alert('공지사항이 삭제되었습니다.'); location.href='notice/noticeList.jsp';</script>");
        } else {
            out.println("<script>alert('삭제 실패!'); history.back();</script>");
        }
        out.close();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    private boolean isNoticeAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        String userGrade = (String) session.getAttribute("sessionUserGrade");
        return "管理者".equals(userGrade)
                || "관리자".equals(userGrade);
    }

    private void denyAccess(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('관리자만 공지사항을 삭제할 수 있습니다.'); location.href='" + request.getContextPath() + "/notice/noticeList.jsp';</script>");
    }
}
