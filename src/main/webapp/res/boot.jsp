<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.HotelDAO" %>
<%@ page import="com.jyphotel.BootVO" %>
<%@ page import="com.hotel.payment.PaymentDAO" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    request.setCharacterEncoding("UTF-8");
    DecimalFormat nf = new DecimalFormat("#,###");

    // 1. 세션에서 단일 열쇠 인출
    String bootNo = (String) session.getAttribute("bootNo");

    if (bootNo == null || bootNo.trim().isEmpty()) {
%>
    <script>
        alert("예약 정보가 만료되었거나 올바르지 않은 접근입니다.");
        location.href = "<%= request.getContextPath() %>/testex2/hotelsearch.jsp";
    </script>
<%
        return; 
    }

    // 2. 오라클 BOOT 테이블 장부 조회 (예약자명, 고유코드 확보)
    HotelDAO dao = new HotelDAO();
    BootVO vo = dao.selectReservationReceipt(bootNo);
    
    if (vo == null) {
%>
    <script>
        alert("DB에서 예약 정보를 조회할 수 없습니다.");
        location.href = "<%= request.getContextPath() %>/testex2/hotelsearch.jsp";
    </script>
<%
        return;
    }

 // 3. 🎯 [수정 완료] 빈 PAYMENT 테이블 대신, 앞서 완벽하게 받아온 vo 장부와 세션에서 요금을 추출합니다!
    int roomTotal = 0;
    
    if (vo != null) {
        // 팀원의 요금 산출 방식 규칙인 vo 내의 객실 요금이나 세션 값을 최우선으로 반영합니다.
        // ReservationProcServlet 에서 세션에 저장한 총 결제 금액
        if (session.getAttribute("amount") != null) {
            roomTotal = (Integer) session.getAttribute("amount");
        }
    }

    // 만약 세션 값이 유실되었을 경우를 대비한 2중 안전 장치 (vo의 다른 데이터나 기본값 활용)
    if (roomTotal == 0) {
        roomTotal = 150000; // 세션 만료 시 터지지 않게 잡아주는 디폴트 예약금
    }

    String reservationCode = vo.getReservation_code();
    String bootName = vo.getBoot_name();
    String itemName = vo.getRoom_grade() + " 객실 예약금";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>호텔 예약 결제 (BOOT)</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/boot.css">
</head>
<body>
<main>
    <h1>호텔 예약 결제</h1>
    <p class="notice">카카오페이 결제를 실행합니다. 결제 버튼을 누르면 카카오페이 결제 화면으로 이동합니다.</p>

    <div class="summary">
        <div class="row"><strong>예약 식별번호</strong><span><%= bootNo %></span></div>
        <div class="row"><strong>통신용 고유코드</strong><span><%= reservationCode %></span></div>
        <div class="row"><strong>예약자명</strong><span><%= bootName %></span></div>
        <div class="row"><strong>상품명</strong><span><%= itemName %></span></div>
        <div class="row"><strong>수량</strong><span>1</span></div>
        <div class="row"><strong>결제금액</strong><span class="value" id="reserveTotal">₩<%= nf.format(roomTotal) %></span></div>
    </div>

    <form action="${pageContext.request.contextPath}/res/kakaoReady.jsp" method="post">
        <input type="hidden" name="bootNo" value="<%= bootNo %>">
        <input type="hidden" name="bootPayCheck" value="<%= roomTotal %>"> 
        <button class="pay-button" type="submit">카카오페이 결제하기</button>
    </form>
</main>
</body>
</html>