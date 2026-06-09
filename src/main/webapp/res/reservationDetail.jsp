<%@ page import="com.hotel.reservation.ReservationDTO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    ReservationDTO reservation = (ReservationDTO) request.getAttribute("reservation");

    // [경로 점검] 잘못된 루트 리다이렉트를 request.getContextPath() 연동으로 완벽 방어
    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/res/reservationSearch.jsp");
        return;
    }

    String reservationCode = reservation.getReservationCode();

    if (reservationCode == null || reservationCode.trim().isEmpty()) {
        reservationCode = "JYP-" + String.format("%06d", reservation.getReservationId());
    }

    String displayAmount = "¥" + String.format("%,d", reservation.getTotalAmount());

    String reservationStatus = reservation.getReservationStatus();
    String displayStatus = "";

    // [요구사항 점검] 이전 턴에 확장하기로 약속했던 다중 상태값 세분화 매핑 선반영
    if ("PAYMENT_READY".equals(reservationStatus)) {
        displayStatus = "결제 대기";
    } else if ("PAID".equals(reservationStatus)) {
        displayStatus = "예약 완료";
    } else if ("CANCELLED".equals(reservationStatus) || "CANCEL".equals(reservationStatus)) {
        displayStatus = "취소 완료";
    } else if ("REFUNDED".equals(reservationStatus)) {
        displayStatus = "환불 완료";
    } else if ("FAILED".equals(reservationStatus)) {
        displayStatus = "결제 실패";
    } else {
        displayStatus = reservationStatus;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>예약 내역</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/reservationDetail.css">

</head>
<body>

<header class="header">
    <div class="logo">JYP HOTEL</div>
    <div class="header-actions">
        <a href="#" class="header-button">마이페이지</a>
        <a href="#" class="header-button">로그아웃</a>
    </div>
</header>

<div class="layout">
    <aside class="sidebar">
        <h2>예약 메뉴</h2>
        <nav class="side-menu">
            <a href="#" class="active">예약 내역</a>
            <a href="#">예약 상세</a>
        </nav>
    </aside>

    <main class="content">
        <h1 class="page-title">예약 내역</h1>

        <section class="reservation-card">
            <div class="room-image">
                객실 이미지
            </div>

            <div>
                <h2 class="hotel-name">JYP HOTEL TOKYO</h2>
                <p class="info-line">예약번호 : <%= reservationCode %></p>
                <p class="info-line">예약자명 : <%= reservation.getBookerName() %></p>
                <p class="info-line">체크인 : <%= reservation.getCheckInDate() %></p>
                <p class="info-line">체크아웃 : <%= reservation.getCheckOutDate() %></p>
                <span class="status-badge"><%= displayStatus %></span>
            </div>

            <div class="card-actions">
                <button type="button" class="detail-link" onclick="openDetail()">[예약상세보기]</button>

                <% if ("PAID".equals(reservation.getReservationStatus())) { %>
                <form action="${pageContext.request.contextPath}/kakaoRefund" method="post"
                      class="refund-form"
                      onsubmit="return confirm('정말 예약을 취소하고 환불하시겠습니까?');">
                    <input type="hidden" name="reservationId" value="<%= reservation.getReservationId() %>">
                    <button type="submit" class="refund-button">[예약취소/환불하기]</button>
                </form>
                <% } %>
            </div>
        </section>

        <a href="${pageContext.request.contextPath}/res/reservationSearch.jsp" class="back-link">다시 조회하기</a>
    </main>
</div>

<div class="modal-bg" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2 class="modal-title">예약 상세</h2>
            <button type="button" class="close-button" onclick="closeDetail()">×</button>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약번호</div>
            <div class="detail-value"><%= reservationCode %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자명</div>
            <div class="detail-value"><%= reservation.getBookerName() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자 전화번호</div>
            <div class="detail-value"><%= reservation.getBookerPhone() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자 이메일</div>
            <div class="detail-value"><%= reservation.getBookerEmail() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">숙박자명</div>
            <div class="detail-value"><%= reservation.getGuestName() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">숙박자 전화번호</div>
            <div class="detail-value"><%= reservation.getGuestPhone() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">체크인</div>
            <div class="detail-value"><%= reservation.getCheckInDate() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">체크아웃</div>
            <div class="detail-value"><%= reservation.getCheckOutDate() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">인원 수</div>
            <div class="detail-value"><%= reservation.getPeopleCount() %>명</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">결제금액</div>
            <div class="detail-value"><%= displayAmount %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약상태</div>
            <div class="detail-value"><%= displayStatus %></div>
        </div>
    </div>
</div>

<script>
function openDetail() {
    document.getElementById('detailModal').style.display = 'block';
}

function closeDetail() {
    document.getElementById('detailModal').style.display = 'none';
}

document.getElementById('detailModal').addEventListener('click', function(event) {
    if (event.target === this) {
        closeDetail();
    }
});
</script>

</body>
</html>