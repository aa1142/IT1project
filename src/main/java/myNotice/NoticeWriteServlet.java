package myNotice;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/insertNotice.do")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class NoticeWriteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isNoticeAdmin(request)) {
            denyAccess(request, response);
            return;
        }

        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String important = request.getParameter("important");

        if ("Y".equals(important) && title != null && !title.startsWith("[중요공지]")) {
            title = "[중요공지] " + title;
        }

        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "upload";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        Part part = request.getPart("noticeImage");
        String fileName = getFileName(part);

        if (fileName != null && !fileName.isEmpty()) {
            fileName = System.currentTimeMillis() + "_" + fileName;
            part.write(uploadPath + File.separator + fileName);
        } else {
            fileName = null;
        }

        NoticeDto dto = new NoticeDto();
        dto.setTitle(title);
        dto.setContent(content);
        dto.setImageFile(fileName);

        NoticeDao dao = new NoticeDao();
        int result = dao.insertNotice(dto);

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (result > 0) {
            int newNoticeNo = dao.getLatestNoticeNo();
            out.println("<script>alert('공지사항이 등록되었습니다.'); location.href='notice/noticeDetail.jsp?no=" + newNoticeNo + "';</script>");
        } else {
            out.println("<script>alert('등록 실패! 콘솔창 오류를 확인하세요.'); history.back();</script>");
        }
        out.close();
    }

    private String getFileName(Part part) {
        if (part == null) {
            return null;
        }

        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return null;
        }

        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return null;
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
        response.getWriter().println("<script>alert('관리자만 공지사항을 작성할 수 있습니다.'); location.href='" + request.getContextPath() + "/notice/noticeList.jsp';</script>");
    }
}
