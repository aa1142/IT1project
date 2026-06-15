package adminAjax;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson; // 💡 Gson 라이브러리 임포트 (또는 Jackson 등 사용 가능)

import dao.RoomDao;

// 1. Ajax의 url인 '/admin/getBootSummary.do'와 주소를 일치시킵니다.
@WebServlet("/admin/getBootSummary.do")
public class CountingBootServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 2. 응답 형식을 JSON으로, 인코딩을 UTF-8로 지정합니다. (Ajax dataType: 'json' 대응)
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession();
        // 3. Ajax가 data로 보낸 파라미터(date) 받기
        String searchDate = request.getParameter("date");
        
        // 임시로 세팅할 회사 번호 (실제 구현 시 세션 등에서 가져오거나 파라미터로 받으세요)
        Integer companyNo = (Integer)session.getAttribute("companyNo"); 
        companyNo= 1;
        // 4. 기존에 만든 DAO 메서드 호출하여 예약된 방 개수 가져오기
        // (주의: 객체 생성이나 싱글톤 호출은 본인의 프로젝트 구조에 맞게 수정하세요)
         RoomDao roomdao = new RoomDao();
         Map<String, Integer> reservedMap = roomdao.countBootingRoom(searchDate, companyNo);
         Map<String, Integer> countAll = roomdao.countAllTypeRoom(companyNo);
        
        System.out.println("디럭스패밀리= "+countAll.get("deluxe_familyAll"));
        // 5. Ajax가 요구하는 key 명칭에 맞게 최종 응답용 Map 구성하기
        // Ajax 코드에서 'data.reservedStdSingle', 'data.totalStdSingle' 형태로 쓰고 있습니다.
        Map<String, String> resultData = new HashMap<>();
        resultData.put("standard1", reservedMap.get("standard_single")+"/"+countAll.get("standard_singleAll"));
        resultData.put("standard2", reservedMap.get("standard_twin")+"/"+countAll.get("standard_twinAll"));
        resultData.put("standard5", reservedMap.get("standard_family")+"/"+countAll.get("standard_familyAll"));
        resultData.put("deluxe1", reservedMap.get("deluxe_single")+"/"+countAll.get("deluxe_singleAll"));
        resultData.put("deluxe2", reservedMap.get("deluxe_twin")+"/"+countAll.get("deluxe_twinAll"));
        resultData.put("deluxe5", reservedMap.get("deluxe_family")+"/"+countAll.get("deluxe_familyAll"));
        resultData.put("suite2", reservedMap.get("suite_twin")+"/"+countAll.get("suite_twinAll"));
        resultData.put("suite5", reservedMap.get("suite_family")+"/"+countAll.get("suite_familyAll"));

        // 6. 자바 Map 객체를 JSON 문자열로 변환 (Gson 활용)
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(resultData);
        
        // 7. 클라이언트(Ajax)로 JSON 데이터 전송
        PrintWriter out = response.getWriter();
        out.print(jsonResponse);
        out.flush();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}