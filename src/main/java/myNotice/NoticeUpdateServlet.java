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
import myNotice.NoticeDao;
import myNotice.NoticeDto;

// 🌟 수정을 할 때도 이미지 파일이 새로 넘어올 수 있으므로 멀티파트 설정이 필수로 들어가야 합니다!
@WebServlet("/updateNotice.do")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 찬 건당 최대 10MB
    maxRequestSize = 1024 * 1024 * 50    // 전체 요청 최대 50MB
)
public class NoticeUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        if (!isNoticeAdmin(request)) {
            denyAccess(request, response);
            return;
        }
        
        // 1. 파라미터 값 꺼내기
        int noticeNo = Integer.parseInt(request.getParameter("noticeNo"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        
        // 2. 새로운 이미지 파일 업로드 처리 구역
        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "upload";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // noticeEdit.jsp의 <input type="file" name="noticeImage">에서 파일 가로채기
        Part part = request.getPart("noticeImage");
        String fileName = getFileName(part);
        
        // 3. 바구니(Dto) 생성 및 세팅
        NoticeDto dto = new NoticeDto();
        dto.setNoticeNo(noticeNo);
        dto.setTitle(title);
        dto.setContent(content);
        
        if (fileName != null && !fileName.isEmpty()) {
            // 사용자가 수정 창에서 "새로운 사진"을 첨부했을 때
            fileName = System.currentTimeMillis() + "_" + fileName;
            part.write(uploadPath + File.separator + fileName);
            dto.setImageFile(fileName); // 새 파일 이름 저장
        } else {
            // 사용자가 사진을 새로 등록하지 않고 기존 글자만 고쳤을 때
            // 기존 이미지명을 유지하기 위해 jsp 등에서 hidden으로 보낸 원래 파일명을 받거나 
            // 여기서는 기존 파일명을 유지하도록 처리합니다.
            String origImage = request.getParameter("origImage");
            dto.setImageFile(origImage); 
        }
        
        // 4. 데이터베이스 수정 실행 (이 부분 오류 해결!)
        NoticeDao dao = new NoticeDao();
        int result = dao.updateNotice(dto);
        
        // 5. 알림창 및 이동 처리
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        if (result > 0) {
            out.println("<script>alert('공지사항이 수정되었습니다.'); location.href='notice/noticeList.jsp';</script>");
        } else {
            out.println("<script>alert('수정 실패! 콘솔창 에러를 확인하세요.'); history.back();</script>");
        }
        out.close();
    }

    // 파일 이름 추출 보조 메서드
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
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
        response.getWriter().println("<script>location.href='" + request.getContextPath() + "/notice/noticeList.jsp';</script>");
    }
}
