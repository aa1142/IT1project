<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.*" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    int room_type = HotelPriceUtil.toInt(request.getParameter("room_type"), 0);
    String room_grade = request.getParameter("room_grade");
    if (room_grade == null) room_grade = "";

    String boot_checkin = request.getParameter("boot_checkin");
    int nights = HotelPriceUtil.toInt(request.getParameter("nights"), 1);
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);
    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);
    String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

    RoomVO room = dao.getOneRoom(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    if (room == null) {
%>
<script type="text/javascript">
    alert("예약 가능한 객실이 없습니다.");
    history.go(-1);
</script>
<%
        return;
    }

    int room_no = dao.getEmptyRoomNo(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    if (room_no <= 0) {
%>
<script type="text/javascript">
    alert("배정 가능한 객실이 없습니다.");
    history.go(-1);
</script>
<%
        return;
    }

    String booker_last = request.getParameter("booker_last_name");
    String booker_first = request.getParameter("booker_first_name");
    if (booker_last == null) booker_last = "";
    if (booker_first == null) booker_first = "";

    String guest_last = request.getParameter("guest_last_name");
    String guest_first = request.getParameter("guest_first_name");
    if (guest_last == null) guest_last = "";
    if (guest_first == null) guest_first = "";

    String guest_phone = request.getParameter("guest_phone");
    if (guest_phone == null) guest_phone = "";

    String breakfast_yn = request.getParameter("breakfast_yn");
    if (breakfast_yn == null) breakfast_yn = "N";
    String fast_checkin_yn = request.getParameter("fast_checkin_yn");
    if (fast_checkin_yn == null) fast_checkin_yn = "N";

    boolean breakfast = "Y".equalsIgnoreCase(breakfast_yn);
    boolean fastCheckin = "Y".equalsIgnoreCase(fast_checkin_yn);

    int roomTotal = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, rooms, boot_adult, boot_child);
    int breakfastTotal = breakfast ? HotelPriceUtil.calcBreakfastTotal(boot_adult, boot_child, nights) : 0;
    int fastCheckinTotal = fastCheckin ? HotelPriceUtil.FAST_CHECKIN_UNIT : 0;
    int grandTotal = roomTotal + breakfastTotal + fastCheckinTotal;

    String boot_please = "숙박자:" + guest_last + guest_first
            + "|숙박자전화:" + guest_phone
            + "|조식:" + breakfast_yn
            + "|빠른체크인:" + fast_checkin_yn
            + "|객실요금:" + roomTotal
            + "|조식요금:" + breakfastTotal
            + "|빠른체크인요금:" + fastCheckinTotal
            + "|총요금:" + grandTotal;

    BootVO vo = new BootVO();
    vo.setCompany_no(company_no);
    vo.setRoom_no(room_no);
    vo.setRoom_grade(room_grade);
    vo.setRoom_type(room_type);
    vo.setBoot_phone(request.getParameter("boot_phone"));
    vo.setBoot_name(booker_last + booker_first);
    vo.setBoot_email(request.getParameter("boot_email"));
    vo.setBoot_checkin(boot_checkin);
    vo.setBoot_checkout(boot_checkout);
    vo.setBoot_adult(boot_adult);
    vo.setBoot_child(boot_child);
    vo.setBoot_pay_check(1);
    vo.setBoot_please(boot_please);
    vo.setBoot_confirm(1);

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    if (sessionUserId != null) {
        vo.setMember_id(sessionUserId);
    }

    boolean flag = dao.insertBoot(vo);
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>예약 처리</title></head>
<body>
<%
    if (flag) {
        response.sendRedirect("reservationcomplete.jsp?boot_no=" + vo.getBoot_no());
    } else {
%>
<script type="text/javascript">
    alert("예약 저장에 실패했습니다. DB 연결과 boot 테이블을 확인해 주세요.");
    history.go(-1);
</script>
<%  } %>
</body>
</html>
