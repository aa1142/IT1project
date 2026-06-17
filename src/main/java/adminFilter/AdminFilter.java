package adminFilter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import dao.AdminDao;
import dto.AdminDto;

// 🎯 /Admin/으로 시작하는 모든 요청(서블릿, JSP 등)이 실행되기 전에 이 필터를 거쳐갑니다.
@WebFilter("/Admin/*")
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 필터 초기화 시 필요한 코드가 있다면 작성 (보통 비워둠)
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        // 부모 request를 HttpServletRequest로 다운캐스팅
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession();
        
        // 🎯 [공통 로직] 모든 관리자 페이지에 데이터 주입
//        String adminId = "admin01"; // 임시 하드코딩 (추후 세션 로그인 정보로 대체 가능)
        String adminId = (String)session.getAttribute("adminId");
        AdminDao adminDao = new AdminDao(); 
        AdminDto resultAdmin = adminDao.selectAdmin(adminId); 
        
        // request에 담아두면, 이 필터 다음에 실행되는 서블릿이나 JSP까지 이 데이터가 유지됩니다.
        httpRequest.setAttribute("adminData", resultAdmin);
        
        // ⭐ 중요: 이 코드가 있어야 가로챘던 요청을 다음 서블릿(예: OnSitePaymentServlet)이나 JSP로 넘겨줍니다.
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 필터가 소멸될 때 실행 (보통 비워둠)
    }
}