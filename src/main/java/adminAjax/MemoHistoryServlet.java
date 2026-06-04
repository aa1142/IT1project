package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import adminDao.MemoDao;
import adminDto.MemoDto;
import vo.HistoryMemoVo;

@WebServlet("/admin/getMemoList.do")
public class MemoHistoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
    	// 1. 파라미터 수집
        String memoPhone = request.getParameter("memoPhone");
        String adminId = (String)session.getAttribute("adminId");
        //더미데이터
        adminId = "admin01";
        // 2. DAO를 통해 해당 전화번호를 가진 고객의 메모 전체 조회 (ArrayList)
        MemoDao memoDao = new MemoDao();
        ArrayList<HistoryMemoVo> list = memoDao.selectAllMemo(memoPhone, adminId);
        
        // 3. 🎯 [핵심] 응답 형식을 JSON 및 UTF-8로 지정 (한글 깨짐 및 클라이언트 파싱 에러 방지)
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // 4. GSON 라이브러리를 이용하여 자바의 List를 JSON 스트링으로 변환
        // 💡 setDateFormat을 지정해두면 DTO 내부의 Date형 데이터가 날짜 포맷 문자열로 이쁘게 바뀝니다.
        Gson gson = new GsonBuilder()
                        .setDateFormat("yyyy-MM-dd")
                        .create();
        
        String jsonList = gson.toJson(list);
        
        // 5. 브라우저로 쏘아주기!
        out.print(jsonList);
        out.flush();
        out.close();
        
        System.out.println("🎯 [Memo List] " + memoPhone + " 의 메모 내역 전달 완료 (개수: " + list.size() + "개)");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 비동기 조회가 GET 방식이므로 본문 생략 가능
    }
}