<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.HotelDAO" %>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<%
    request.setCharacterEncoding("UTF-8");

    try {
        // 1. 첫 번째 화면(hotelreservation.jsp)이 post로 던진 파라미터 전부 인출
        int companyNo = Integer.parseInt(request.getParameter("company_no"));
        int roomType = Integer.parseInt(request.getParameter("room_type"));
        String roomGrade = request.getParameter("room_grade");
        String bootCheckin = request.getParameter("boot_checkin");
        int nights = Integer.parseInt(request.getParameter("nights"));
        int rooms = Integer.parseInt(request.getParameter("rooms"));
        int bootAdult = Integer.parseInt(request.getParameter("boot_adult"));
        int bootChild = Integer.parseInt(request.getParameter("boot_child"));
        
        // 성 + 이름 결합 처리 규칙 적용
        String bookerLastName = request.getParameter("booker_last_name");
        String bookerFirstName = request.getParameter("booker_first_name");
        String bootName = (bookerLastName != null ? bookerLastName.trim() : "") 
                        + (bookerFirstName != null ? bookerFirstName.trim() : "");
        if (bootName.isEmpty()) bootName = "무명고객";

        String bootPhone = request.getParameter("boot_phone");
        String bootEmail = request.getParameter("boot_email");
        String bootPlease = request.getParameter("boot_please");
        
        String sessionUserId = (String) session.getAttribute("sessionUserId");

        // 2. 오라클 직통 방식 개명 버전 HotelDAO 결속
        HotelDAO dao = new HotelDAO();

        // 3. 비즈니스 계산 처리 (Assign 빈 방 번호 낚아채기)
        String bootCheckout = HotelPriceUtil.calcCheckout(bootCheckin, nights);
        int assignedRoomNo = dao.assignEmptyRoomNumber(companyNo, roomGrade, roomType, bootCheckin, bootCheckout);

        // 4. 단건 요금 정보 다시 뽑아와서 최종 결제금액 연산
        com.jyphotel.RoomVO priceVo = dao.selectSingleRoomTypePriceInfo(companyNo, roomGrade, roomType, bootCheckin, bootCheckout);
        int singlePrice = (priceVo != null) ? priceVo.getRoom_price() : 50000;
        int finalTotalAmount = HotelPriceUtil.calcRoomTotal(singlePrice, nights, rooms, bootAdult, bootChild);

        // 옵션 선택에 따른 가산금 연산 동적 세팅 (조식/레이트체크인 체크박스 바인딩)
        if ("Y".equals(request.getParameter("breakfast_yn"))) {
            finalTotalAmount += HotelPriceUtil.calcBreakfastTotal(bootAdult, bootChild, nights);
        }
        if ("Y".equals(request.getParameter("fast_checkin_yn"))) {
            finalTotalAmount += HotelPriceUtil.FAST_CHECKIN_UNIT;
        }

        // 5. DB 적재를 위해 BootVO 바구니 빌드
        BootVO vo = new BootVO();
        vo.setRoom_grade(roomGrade);
        vo.setRoom_type(roomType);
        vo.setRoom_no(assignedRoomNo);
        vo.setCompany_no(companyNo);
        vo.setMember_id(sessionUserId);
        vo.setBoot_phone(bootPhone);
        vo.setBoot_name(bootName);
        vo.setBoot_email(bootEmail);
        vo.setBoot_checkin(bootCheckin);
        vo.setBoot_checkout(bootCheckout);
        vo.setBoot_adult(bootAdult);
        vo.setBoot_child(bootChild);
        vo.setBoot_pay_check(finalTotalAmount); // 가산금 포함된 최종합계
        vo.setBoot_please(bootPlease);
        vo.setBoot_confirm(0); // 0: 결제대기 상태

        // 6. DB에 강제 직통 밀어넣기 처리
        boolean isSuccess = dao.executeInsertReservation(vo);

        if (isSuccess) {
            // [연동 핵심] 오라클 시퀀스나 UUID가 구동되면서 vo 내부에 채워진 boot_no와 reservation_code를 낚아챕니다.
            request.setAttribute("bootNo", vo.getBoot_no());
            request.setAttribute("reservationCode", vo.getReservation_code());
            request.setAttribute("itemName", roomGrade + " 객실 예약금 (" + rooms + "개)");
            request.setAttribute("bootPayCheck", String.valueOf(vo.getBoot_pay_check()));
            request.setAttribute("bootName", vo.getBoot_name());
            request.setAttribute("bootEmail", vo.getBoot_email());
            request.setAttribute("quantity", "1");
            request.setAttribute("taxFreeAmount", "0");

            // 최종 목적인 결제 대기창(boot.jsp)으로 데이터를 보존하여 토스(Forward)
            request.getRequestDispatcher("../res/boot.jsp").forward(request, response);
        } else {
            out.println("<script>alert('죄상합니다. 잔여 객실 소진 또는 DB 적재 오류로 예약을 진행할 수 없습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('시스템 연동 처리 오류: " + e.getMessage() + "'); history.back();</script>");
    }
%>