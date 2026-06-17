package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.MemoDao;

@WebServlet("/admin/insertMemo.do")
public class MemoInsertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;


    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 설정 (한글 깨짐 방지)
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Integer companyNo = (Integer) session.getAttribute("companyNo");
        String adminId = (String) session.getAttribute("adminId");
        
        // 테스트용 임시 데이터 설정
//        companyNo = 1;
//        adminId = "admin01";
        
        // 파라미터 수집
        String memoPhone = request.getParameter("memoPhone");
        String memoName = request.getParameter("memoName");
        String memoContent = request.getParameter("memoContent");
        
        // DAO 호출하여 DB 반영 (성공 시 반영된 행의 수 1 반환)
        MemoDao memoDao = new MemoDao();
        int result = memoDao.insertMemo(memoPhone, adminId, memoContent, memoName);
        
        // 🎯 [핵심 추가] AJAX 통신을 위한 JSON 응답 설정
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // jsp 스크립트에서 res.status === "success"를 검사하므로 텍스트 포맷을 맞춰줍니다.
        if (result > 0) {
            // {"status": "success"} 반환
            out.print("{\"status\": \"success\"}");
            System.out.println("🎯 [Memo Insert] 메모 등록 성공 (" + memoPhone + ")");
        } else {
            // {"status": "fail", "message": "DB 반영 실패"} 반환
            out.print("{\"status\": \"fail\", \"message\": \"데이터베이스 저장에 실패했습니다.\"}");
            System.out.println("❌ [Memo Insert] 메모 등록 실패");
        }
        
        out.flush();
        out.close();
    }
}