<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.jyphotel.*" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    request.setCharacterEncoding("UTF-8");

    String keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";

    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    String room_grade = request.getParameter("room_grade");
    if (room_grade == null) room_grade = "스탠다드";

    String boot_checkin = request.getParameter("boot_checkin");
    if (boot_checkin == null) boot_checkin = "";

    int nights = HotelPriceUtil.toInt(request.getParameter("nights"), 1);
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);
    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);

    String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

    // 🚨 [변경 1] getCompanyList -> selectActiveBranchList 개명 반영 (23행 오류 해결)
    Vector<CompanyVO> companyList = dao.selectActiveBranchList(keyword);

    request.setAttribute("companyList", companyList);
    request.setAttribute("keyword", keyword);
    request.setAttribute("company_no", company_no);
    request.setAttribute("room_grade", room_grade);
    request.setAttribute("boot_checkin", boot_checkin);
    request.setAttribute("boot_checkout", boot_checkout);
    request.setAttribute("nights", nights);
    request.setAttribute("rooms", rooms);
    request.setAttribute("boot_adult", boot_adult);
    request.setAttribute("boot_child", boot_child);

    if (company_no > 0 && !boot_checkin.equals("")) {
        // 🚨 [변경 2] getCompany -> selectBranchDetailByNo 개명 반영 (37행 오류 해결)
        CompanyVO company = dao.selectBranchDetailByNo(company_no);
        
        // 🚨 [변경 3] getRoomList -> selectAvailableRoomTypeList 개명 반영 (38행 오류 해결)
        Vector<RoomVO> roomList = dao.selectAvailableRoomTypeList(company_no, room_grade, boot_checkin, boot_checkout,
                boot_adult, boot_child, rooms);
                
        request.setAttribute("searchDone", "Y");
        request.setAttribute("company", company);
        request.setAttribute("roomList", roomList);
    } else {
        request.setAttribute("searchDone", "N");
    }

    // 결과를 담아서 메인 뷰 화면인 hotelsearch.jsp 로 다시 토스(Forward)
    request.getRequestDispatcher("hotelsearch.jsp").forward(request, response);
%>