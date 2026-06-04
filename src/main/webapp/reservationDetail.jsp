<%@ page import="com.hotel.reservation.ReservationDTO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    ReservationDTO reservation = (ReservationDTO) request.getAttribute("reservation");

    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/reservationSearch.jsp");
        return;
    }

    String reservationCode = reservation.getReservationCode();

    if (reservationCode == null || reservationCode.trim().isEmpty()) {
        reservationCode = "JYP-" + String.format("%06d", reservation.getReservationId());
    }

    String displayAmount = "¥" + String.format("%,d", reservation.getTotalAmount());

    String reservationStatus = reservation.getReservationStatus();
    String displayStatus = "";

    if ("PAYMENT_READY".equals(reservationStatus)) {
        displayStatus = "결제 대기";
    } else if ("PAID".equals(reservationStatus)) {
        displayStatus = "예약 완료";
    } else if ("CANCEL".equals(reservationStatus)) {
        displayStatus = "환불 완료";
    } else {
        displayStatus = reservationStatus;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>예약 내역</title>
<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: Arial, 'Noto Sans KR', sans-serif;
    background: #050505;
    color: #f8fafc;
}

.header {
    height: 92px;
    padding: 0 46px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(212, 175, 55, 0.35);
    background: #0d0d0d;
}

.logo {
    font-size: 28px;
    font-weight: 900;
    letter-spacing: 1px;
    color: #f6d36b;
}

.header-actions {
    display: flex;
    align-items: center;
    gap: 14px;
}

.header-button {
    padding: 12px 22px;
    border: 1px solid rgba(212, 175, 55, 0.45);
    border-radius: 4px;
    background: #1a1a1a;
    color: #f8fafc;
    font-weight: 800;
    text-decoration: none;
}

.layout {
    display: grid;
    grid-template-columns: 275px 1fr;
    min-height: calc(100vh - 92px);
}

.sidebar {
    padding: 48px 0 0 64px;
    border-right: 1px solid rgba(212, 175, 55, 0.2);
    background: #080808;
}

.sidebar h2 {
    margin: 0 0 38px;
    font-size: 22px;
    color: #f8fafc;
}

.side-menu {
    display: flex;
    flex-direction: column;
    gap: 26px;
}

.side-menu a {
    color: #f8fafc;
    font-weight: 800;
    text-decoration: none;
}

.side-menu a.active {
    color: #ff4545;
}

.content {
    padding: 50px 70px;
}

.page-title {
    margin: 0 0 70px;
    font-size: 34px;
    font-weight: 900;
    color: #f8fafc;
}

.reservation-card {
    display: grid;
    grid-template-columns: 225px 1fr 190px;
    gap: 42px;
    align-items: center;
    max-width: 1120px;
    padding: 38px 36px;
    border: 1px solid rgba(212, 175, 55, 0.65);
    border-radius: 8px;
    background: #111;
}

.room-image {
    height: 148px;
    border: 1px solid rgba(212, 175, 55, 0.65);
    border-radius: 8px;
    background: #191919;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #f6d36b;
    font-weight: 900;
}

.hotel-name {
    margin: 0 0 22px;
    font-size: 24px;
    font-weight: 900;
    color: #f6d36b;
}

.info-line {
    margin: 10px 0;
    font-size: 17px;
    font-weight: 700;
}

.status-badge {
    display: inline-block;
    margin-top: 14px;
    padding: 8px 16px;
    border-radius: 999px;
    background: rgba(212, 175, 55, 0.2);
    color: #f6d36b;
    font-size: 20px;
    font-weight: 900;
}

.card-actions {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 14px;
}

.detail-link {
    border: 0;
    background: none;
    color: #f6d36b;
    font-size: 16px;
    font-weight: 900;
    cursor: pointer;
}

.refund-form {
    margin: 0;
}

.refund-button {
    border: 0;
    background: none;
    color: #ff6b6b;
    font-size: 16px;
    font-weight: 900;
    cursor: pointer;
}

.detail-link:hover,
.refund-button:hover {
    text-decoration: underline;
}

.modal-bg {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.72);
    z-index: 10;
}

.modal {
    width: 620px;
    max-width: calc(100% - 40px);
    max-height: calc(100vh - 80px);
    overflow-y: auto;
    margin: 70px auto;
    padding: 34px;
    border: 1px solid rgba(212, 175, 55, 0.7);
    border-radius: 10px;
    background: #111;
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.6);
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.modal-title {
    margin: 0;
    color: #f6d36b;
    font-size: 26px;
    font-weight: 900;
}

.close-button {
    border: 0;
    background: none;
    color: #f8fafc;
    font-size: 28px;
    cursor: pointer;
}

.detail-row {
    display: grid;
    grid-template-columns: 180px 1fr;
    gap: 18px;
    padding: 14px 0;
    border-bottom: 1px solid rgba(212, 175, 55, 0.18);
}

.detail-label {
    color: #a8b0bd;
    font-weight: 800;
}

.detail-value {
    color: #f8fafc;
    font-weight: 800;
}

.back-link {
    display: inline-block;
    margin-top: 36px;
    color: #f6d36b;
    font-weight: 900;
    text-decoration: none;
}

@media (max-width: 900px) {
    .layout {
        grid-template-columns: 1fr;
    }

    .sidebar {
        padding: 24px;
        border-right: 0;
        border-bottom: 1px solid rgba(212, 175, 55, 0.2);
    }

    .content {
        padding: 34px 22px;
    }

    .reservation-card {
        grid-template-columns: 1fr;
    }
}
</style>
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

        <a href="${pageContext.request.contextPath}/reservationSearch.jsp" class="back-link">다시 조회하기</a>
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