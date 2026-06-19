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

@WebServlet("/updateNotice.do")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class NoticeUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isNoticeAdmin(request)) {
            denyAccess(request, response);
            return;
        }

        int noticeNo = Integer.parseInt(request.getParameter("noticeNo"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");

        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "upload";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        Part part = request.getPart("noticeImage");
        String fileName = getFileName(part);

        NoticeDto dto = new NoticeDto();
        dto.setNoticeNo(noticeNo);
        dto.setTitle(title);
        dto.setContent(content);

        if (fileName != null && !fileName.isEmpty()) {
            fileName = System.currentTimeMillis() + "_" + fileName;
            part.write(uploadPath + File.separator + fileName);
            dto.setImageFile(fileName);
        } else {
            dto.setImageFile(request.getParameter("origImage"));
        }

        NoticeDao dao = new NoticeDao();
        int result = dao.updateNotice(dto);

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (result > 0) {
            out.println("<script>alert('お知らせを修正しました。'); location.href='notice/noticeList.jsp';</script>");
        } else {
            out.println("<script>alert('お知らせの修正に失敗しました。Tomcatコンソールを確認してください。'); history.back();</script>");
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
