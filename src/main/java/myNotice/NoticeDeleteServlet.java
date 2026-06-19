package myNotice;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/deleteNotice.do")
public class NoticeDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isNoticeAdmin(request)) {
            denyAccess(request, response);
            return;
        }

        int noticeNo = Integer.parseInt(request.getParameter("noticeNo"));

        NoticeDao dao = new NoticeDao();
        int result = dao.deleteNotice(noticeNo);

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (result > 0) {
            out.println("<script>alert('お知らせを削除しました。'); location.href='notice/noticeList.jsp';</script>");
        } else {
            out.println("<script>alert('お知らせの削除に失敗しました。'); history.back();</script>");
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
        String userId = (String) session.getAttribute("sessionUserId");
        String adminId = (String) session.getAttribute("adminId");
        return adminId != null
                || "管理者".equals(userGrade)
                || "\uad00\ub9ac\uc790".equals(userGrade)
                || (userId != null && userId.toLowerCase().startsWith("admin"));
    }

    private void denyAccess(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>location.href='" + request.getContextPath() + "/notice/noticeList.jsp';</script>");
    }
}
