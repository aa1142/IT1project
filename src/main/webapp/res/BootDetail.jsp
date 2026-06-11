<%@ page import="com.hotel.reservation.BootDTO" %> <%-- 1. 가방 클래스 임포트 정상화 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // BootSearchServlet이 request에 "boot"라는 이름으로 실어 보낸 새 가방 인출
    BootDTO reservation = (BootDTO) request.getAttribute("boot");

    // [방어벽] 데이터 유실 시 안전하게 bootSearch.jsp로 튕구기
    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/bootSearch.jsp");
        return;
    }

    // 2. 새 규격인 통신용 고유코드 수집 (없으면 복합 문자열 PK인 bootNo로 대체 방어)
    String reservationCode = reservation.getReservationCode();
    if (reservationCode == null || reservationCode.trim().isEmpty()) {
        reservationCode = reservation.getBootNo();
    }

    // 3. 엔화(¥) 오타 교정 및 바뀐 금액 필드(bootPayCheck) 반영
    String displayAmount = String.format("%,d", reservation.getBootPayCheck()) + "원";

    // 4. 숫자로 통합 관리되는 상태값(bootConfirm) 분기 조건 전면 리팩토링
    // (0: 결제대기, 1: 결제완료, 2: 취소/환불완료)
    int bootConfirm = reservation.getBootConfirm();
    String displayStatus = "";

    if (bootConfirm == 0) {
        displayStatus = "결제 대기";
    } else if (bootConfirm == 1) {
        displayStatus = "예약 완료";
    } else if (bootConfirm == 2) {
        displayStatus = "취소/환불 완료";
    } else {
        displayStatus = "기타 상태 (" + bootConfirm + ")";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>예약 내역 (BOOT)</title>

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
                <%= reservation.getRoomGrade() %> <%-- 등급 노출로 역동성 부여 --%>
            </div>

            <div>
                <h2 class="hotel-name">JYP HOTEL SEOUL</h2>
                <p class="info-line">예약번호 : <%= reservation.getBootNo() %></p>
                <p class="info-line">통신코드 : <%= reservationCode %></p>
                <p class="info-line">예약자명 : <%= reservation.getBootName() %></p>
                <p class="info-line">체크인 : <%= reservation.getBootCheckin() %></p>
                <p class="info-line">체크아웃 : <%= reservation.getBootCheckout() %></p>
                <span class="status-badge"><%= displayStatus %></span>
            </div>

            <div class="card-actions">
                <button type="button" class="detail-link" onclick="openDetail()">[예약상세보기]</button>

                <%-- 5. 오직 결제완료(1) 상태일 때만 환불 처리 요청 버튼을 지원합니다 --%>
                <% if (bootConfirm == 1) { %>
                <form action="${pageContext.request.contextPath}/kakaoRefund" method="post"
                      class="refund-form"
                      onsubmit="return confirm('정말 예약을 취소하고 환불하시겠습니까?');">
                    <input type="hidden" name="bootNo" value="<%= reservation.getBootNo() %>">
                    <button type="submit" class="refund-button">[예약취소/환불하기]</button>
                </form>
                <% } %>
            </div>
        </section>

        <a href="${pageContext.request.contextPath}/bootSearch.jsp" class="back-link">다시 조회하기</a>
    </main>
</div>

<div class="modal-bg" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2 class="modal-title">예약 상세</h2>
            <button type="button" class="close-button" onclick="closeDetail()">×</button>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약식별번호</div>
            <div class="detail-value" style="color:#2980b9; font-weight:bold;"><%= reservation.getBootNo() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">통신용 고유코드</div>
            <div class="detail-value"><%= reservationCode %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자명</div>
            <div class="detail-value"><%= reservation.getBootName() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자 전화번호</div>
            <div class="detail-value"><%= reservation.getBootPhone() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약자 이메일</div>
            <div class="detail-value"><%= reservation.getBootEmail() != null ? reservation.getBootEmail() : "미등록" %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">객실 등급 / 타입</div>
            <div class="detail-value"><%= reservation.getRoomGrade() %> / <%= reservation.getRoomType() %>인실</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">체크인</div>
            <div class="detail-value"><%= reservation.getBootCheckin() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">체크아웃</div>
            <div class="detail-value"><%= reservation.getBootCheckout() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">투숙 인원수</div>
            <div class="detail-value">성인 <%= reservation.getBootAdult() %>명 / 소아 <%= reservation.getBootChild() %>명</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">결제금액</div>
            <div class="detail-value" style="color:#d9383a; font-weight:bold;"><%= displayAmount %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">예약상태</div>
            <div class="detail-value"><%= displayStatus %></div>
        </div>
        
        <% if (reservation.getBootPlease() != null && !reservation.getBootPlease().trim().isEmpty()) { %>
        <div class="detail-row">
            <div class="detail-label">요청사항</div>
            <div class="detail-value"><%= reservation.getBootPlease() %></div>
        </div>
        <% } %>
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