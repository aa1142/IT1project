<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<%@ page import="com.jyphotel.RoomTypeUtil" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    String dest = request.getParameter("dest");
    if (dest == null) dest = "";

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
        boot_adult = HotelPriceUtil.toInt(request.getParameter("adult"), 2);
    }
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), -1);
    if (boot_child < 0) {
        boot_child = HotelPriceUtil.toInt(request.getParameter("child"), 0);
    }
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);

    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    if (company_no <= 0 && !dest.equals("")) {
        company_no = dao.resolveCompanyNoByDest(dest);
    }

    String room_grade = RoomTypeUtil.normalizeUiGrade(request.getParameter("room_grade"));
    String checkout = boot_checkout;
    if (checkout.equals("") && !boot_checkin.equals("")) {
        checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);
    }

    String ctx = request.getContextPath();
    StringBuilder url = new StringBuilder(ctx);
    url.append("/testex2/hotelsearch.jsp?");
    url.append("company_no=").append(company_no);
    url.append("&boot_checkin=").append(java.net.URLEncoder.encode(boot_checkin, "UTF-8"));
    url.append("&boot_checkout=").append(java.net.URLEncoder.encode(checkout, "UTF-8"));
    url.append("&nights=").append(nights);
    url.append("&rooms=").append(rooms);
    url.append("&boot_adult=").append(boot_adult);
    url.append("&boot_child=").append(boot_child);
    url.append("&room_grade=").append(java.net.URLEncoder.encode(room_grade, "UTF-8"));
    if (company_no > 0 && !boot_checkin.equals("")) {
        url.append("&autoSearch=Y");
    }

    response.sendRedirect(url.toString());
%>
