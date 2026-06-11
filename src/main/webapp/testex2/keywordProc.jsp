<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.jyphotel.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    String keyword = request.getParameter("keyword");
    if (keyword == null) keyword = "";

    String dest = request.getParameter("dest");
    if (keyword.equals("") && dest != null) {
        if ("tokyo".equals(dest)) keyword = "東京";
        else if ("shinjuku".equals(dest)) keyword = "新宿";
        else if ("yokohama".equals(dest)) keyword = "横浜";
    }

    String boot_checkin = request.getParameter("boot_checkin");
    if (boot_checkin == null || boot_checkin.equals("")) {
        boot_checkin = request.getParameter("checkin");
        if (boot_checkin == null) boot_checkin = "";
    }

    String boot_checkout = request.getParameter("checkout");
    if (boot_checkout == null) boot_checkout = "";

    int nights = HotelPriceUtil.toInt(request.getParameter("nights"), 0);
    if (nights <= 0 && !boot_checkin.equals("") && !boot_checkout.equals("")) {
        nights = HotelPriceUtil.calcNights(boot_checkin, boot_checkout);
    }
    if (nights <= 0) nights = 1;

    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 0);
    if (boot_adult <= 0) {
        boot_adult = HotelPriceUtil.toInt(request.getParameter("adult"), 1);
    }
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), -1);
    if (boot_child < 0) {
        boot_child = HotelPriceUtil.toInt(request.getParameter("child"), 0);
    }
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);

    // 사이드바: 지점 3곳 전부 표시
    Vector<CompanyVO> companyList = dao.getCompanyList("");

    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    // index에서 선택한 지점만 초기 선택 (목록은 전체 유지)
    if (company_no <= 0 && dest != null && !boot_checkin.equals("")) {
        if ("tokyo".equals(dest)) company_no = 1;
        else if ("shinjuku".equals(dest)) company_no = 2;
        else if ("yokohama".equals(dest)) company_no = 3;
    }

    String room_grade = request.getParameter("room_grade");
    if (room_grade == null || room_grade.equals("")) room_grade = "스탠다드";

    request.setAttribute("companyList", companyList);
    request.setAttribute("keyword", keyword);
    request.setAttribute("company_no", company_no);
    request.setAttribute("room_grade", room_grade);
    request.setAttribute("boot_checkin", boot_checkin);
    request.setAttribute("boot_checkout", HotelPriceUtil.calcCheckout(boot_checkin, nights));
    request.setAttribute("nights", nights);
    request.setAttribute("rooms", rooms);
    request.setAttribute("boot_adult", boot_adult);
    request.setAttribute("boot_child", boot_child);

    if (company_no > 0 && !boot_checkin.equals("")) {
        CompanyVO company = dao.getCompany(company_no);
        if (company == null && companyList.size() > 0) {
            company = companyList.elementAt(0);
            company_no = company.getCompany_no();
        }
        String checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);
        Vector<RoomVO> roomList = dao.getRoomList(company_no, room_grade, boot_checkin, checkout,
                boot_adult, boot_child, rooms);
        request.setAttribute("searchDone", "Y");
        request.setAttribute("company", company);
        request.setAttribute("roomList", roomList);
        request.setAttribute("company_no", company_no);
    }

    request.getRequestDispatcher("hotelsearch.jsp").forward(request, response);
%>
