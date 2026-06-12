<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.HotelDAO" %>
<%@ page import="com.jyphotel.BootVO" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" /> <%-- 1. 오라클 직통 DAO 일꾼 소환 --%>
<%
    request.setCharacterEncoding("UTF-8");

    // 2. reservationProc.jsp가 던져준 유일한 열쇠(bootNo)만 우선 확보
    String bootNo = (String) request.getAttribute("bootNo");
    if (bootNo == null) bootNo = request.getParameter("bootNo");

    // 비정상적인 Direct 접근(단독 실행 등) 시 대문 걸어잠그는 보안 방어벽
    if (bootNo == null || bootNo.trim().isEmpty()) {
%>
    <script>
        alert("예약(BOOT) 정보가 만료되었거나 올바르지 않은 접근입니다. 다시 진행해 주세요.");
        location.href = "${pageContext.request.contextPath}/testex2/hotelsearch.jsp";
    </script>
<%
        return;
    }

    // 🌟 [핵심 수정] 파라미터로 날아온 무방비한 값을 쓰지 않고, bootNo 열쇠로 진짜 오라클 장부를 열어 테이블 데이터를 낚아챕니다.
    BootVO vo = dao.selectReservationReceipt(bootNo);

    // 혹시 입력 도중 취소되었거나 유효하지 않은 번호일 경우 예외 처리
    if (vo == null) {
%>
    <script>
        alert("유효하지 않거나 존재하지 않는 예약 번호입니다.");
        location.href = "${pageContext.request.contextPath}/testex2/hotelsearch.jsp";
    </script>
<%
        return;
    }

    // 3. 윈도우 위변조가 불가능한 오라클 정품 데이터를 꺼내서 변수에 바인딩
    String reservationCode = vo.getReservation_code();
    String itemName = vo.getRoom_grade() + " 객실 예약금"; 
    int displayAmount = vo.getBoot_pay_check(); // ₩ DB에 정산되어 박혀있는 조작 불가능한 진짜 합계금액
    String bootName = vo.getBoot_name();
    String bootEmail = vo.getBoot_email();
    
    // 카카오 규격 맞춤형 기본 수량 및 비과세 고정값 세팅
    String quantity = "1";
    String taxFreeAmount = "0";

    String displayAmountText = String.format("%,d", displayAmount) + "원";
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
    <div class="row"><strong>수량</strong><span><%= quantity %></span></div>
    <div class="row"><strong>결제금액</strong><span style="color: #d9383a; font-weight: bold;"><%= displayAmountText %></span></div>
  </div>

  <form action="${pageContext.request.contextPath}/kakaoReady" method="post">
    <input type="hidden" name="bootNo" value="<%= bootNo %>">
    <input type="hidden" name="reservationCode" value="<%= reservationCode %>">
    <input type="hidden" name="itemName" value="<%= itemName %>">
    <input type="hidden" name="quantity" value="<%= quantity %>">
    <input type="hidden" name="bootPayCheck" value="<%= displayAmount %>"> <%-- 변조 위험 없는 진짜 DB 금액 토스 --%>
    <input type="hidden" name="taxFreeAmount" value="<%= taxFreeAmount %>">
    <input type="hidden" name="bootName" value="<%= bootName %>">
    <input type="hidden" name="bootEmail" value="<%= bootEmail %>">
    
    <button class="pay-button" type="submit">카카오페이 결제하기</button>
  </form>
</main>
</body>
</html>