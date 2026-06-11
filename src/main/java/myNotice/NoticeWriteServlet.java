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
import javax.servlet.http.Part;

// 🌟 파일 업로드를 처리하기 위한 필수 설정 (최대 파일 크기 등 지정)
@WebServlet("/insertNotice.do")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 찬 건당 최대 10MB
    maxRequestSize = 1024 * 1024 * 50    // 전체 요청 최대 50MB
)
public class NoticeWriteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        
        // 1. 일반 텍스트 데이터 꺼내기
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        
        // 2. 파일 업로드 처리 구역
        // 톰캣 서버 내부의 실제 사진 저장 물리 경로 확보 (webapp 폴더 안에 upload 폴더가 기본 생성되어 있어야 함)
        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "upload";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir(); // upload 폴더가 없으면 자동으로 새로 만듦
        }
        
        // jsp의 <input type="file" name="noticeImage"> 태그에서 파일 정보 가로채기
        Part part = request.getPart("noticeImage");
        String fileName = getFileName(part); // 업로드된 파일의 원래 이름 꺼내기
        
        if (fileName != null && !fileName.isEmpty()) {
            // 똑같은 이름의 파일 충돌을 방지하기 위해 파일명 앞에 시스템 밀리초 시간을 붙여서 유일하게 만듦
            fileName = System.currentTimeMillis() + "_" + fileName;
            part.write(uploadPath + File.separator + fileName); // 서버 컴퓨터 폴더에 이미지 파일 실물 저장 완료!
        } else {
            fileName = null; // 사용자가 사진을 첨부하지 않았을 때는 DB에 null로 저장
        }
        
        // 3. 데이터 뭉치기 및 DAO 호출
        NoticeDto dto = new NoticeDto();
        dto.setTitle(title);
        dto.setContent(content);
        dto.setImageFile(fileName); // 📸 가공된 파일 이름 바구니에 세팅
        
        NoticeDao dao = new NoticeDao();
        int result = dao.insertNotice(dto);
        
        // 4. 결과 응답 처리
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        if (result > 0) {
            out.println("<script>alert('사진을 포함한 공지사항이 등록되었습니다.'); location.href='notice/noticeList.jsp';</script>");
        } else {
            out.println("<script>alert('등록 실패! 콘솔창 에러를 확인하세요.'); history.back();</script>");
        }
        out.close();
    }

    // Part 객체에서 순수 파일 이름을 추출해내는 보조 메서드
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
}