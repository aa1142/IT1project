<%@ page import="com.hotel.reservation.BootDTO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
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

    String displayAmount = String.format("%,d", reservation.getBootPayCheck()) + "円";

    // 🎯 [장부 바인딩 구역] 
    String paymentStatus = reservation.getPaymentStatus();
    if (paymentStatus == null) {
        paymentStatus = "PENDING"; // 기본 안전장치 방어벽 (null일 때 결제대기로 흐르게 처리)
    }
    
    String displayStatus = "";
    boolean isPaid = false; // 밑에서 환불 버튼을 제어할 스위치 변수

    // 💡 팩트 반영: READY 대신 PENDING, PAID, REFUNDED 구조로 명확하게 매핑 분기합니다.
    if ("PAID".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "予約完了";              // 결제완료 (PAID 일 때)
        isPaid = true;
    } else if ("PENDING".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "決済待ち";              // 결제대기 (PENDING 일 때)
    } else if ("REFUNDED".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "キャンセル/返金完了"; // 환불완료 (REFUNDED 일 때)
    } else {
        displayStatus = "その他状態 (" + paymentStatus + ")";
    }

    String pleaseSummary = HotelPriceUtil.formatPleaseSummary(reservation.getBootPlease());
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>予約履歴 (BOOT)</title>

<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/reservationDetail.css">

</head>
<body>

<header class="header">
    <div class="logo">JYP HOTEL</div>
    <div class="header-actions">
        <a href="#" class="header-button">マイページ</a>
        <a href="#" class="header-button">ログアウト</a>
    </div>
</header>

<div class="layout">
    <aside class="sidebar">
        <h2>予約メニュー</h2>
        <nav class="side-menu">
            <a href="#" class="active">予約履歴</a>
            <a href="#">予約詳細</a>
        </nav>
    </aside>

    <main class="content">
        <h1 class="page-title">予約履歴</h1>

        <section class="reservation-card">
            <div class="room-image">
                <%= reservation.getRoomGrade() %>
            </div>

            <div>
                <h2 class="hotel-name">JYP HOTEL SEOUL</h2>
                <p class="info-line">予約番号 : <%= reservation.getBootNo() %></p>
                <p class="info-line">通信コード : <%= reservationCode %></p>
                <p class="info-line">予約者名 : <%= reservation.getBootName() %></p>
                <p class="info-line">チェックイン : <%= reservation.getBootCheckin() %></p>
                <p class="info-line">チェックアウト : <%= reservation.getBootCheckout() %></p>
                <span class="status-badge"><%= displayStatus %></span>
            </div>

            <div class="card-actions">
                <button type="button" class="detail-link" onclick="openDetail()">[予約詳細を見る]</button>

                <%-- 🎯 변동 포인트: 오직 PAYMENT 테이블 상태가 PAID(완료)일 때만 환불 버튼 가동 --%>
                <% if (isPaid) { %>
                <form action="${pageContext.request.contextPath}/kakaoRefund" method="post"
                      class="refund-form"
                      onsubmit="return confirm('本当に予約をキャンセルして返金しますか？');">
                    <input type="hidden" name="bootNo" value="<%= reservation.getBootNo() %>">
                    <button type="submit" class="refund-button">[予約キャンセル/返金]</button>
                </form>
                <% } %>
            </div>
        </section>

        <a href="${pageContext.request.contextPath}/BootSearch.jsp" class="back-link">再照会する</a>
    </main>
</div>

<div class="modal-bg" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2 class="modal-title">予約詳細</h2>
            <button type="button" class="close-button" onclick="closeDetail()">×</button>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約識別番号</div>
            <div class="detail-value" style="color:#2980b9; font-weight:bold;"><%= reservation.getBootNo() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">通信固有コード</div>
            <div class="detail-value"><%= reservationCode %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約者名</div>
            <div class="detail-value"><%= reservation.getBootName() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約者電話番号</div>
            <div class="detail-value"><%= reservation.getBootPhone() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約者メール</div>
            <div class="detail-value"><%= reservation.getBootEmail() != null ? reservation.getBootEmail() : "未登録" %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">客室グレード / タイプ</div>
            <div class="detail-value"><%= reservation.getRoomGrade() %> / <%= reservation.getRoomType() %>名室</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">チェックイン</div>
            <div class="detail-value"><%= reservation.getBootCheckin() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">チェックアウト</div>
            <div class="detail-value"><%= reservation.getBootCheckout() %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">宿泊人数</div>
            <div class="detail-value">大人 <%= reservation.getBootAdult() %>名 / 子供 <%= reservation.getBootChild() %>名</div>
        </div>

        <div class="detail-row">
            <div class="detail-label">決済金額</div>
            <div class="detail-value" style="color:#d9383a; font-weight:bold;"><%= displayAmount %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約状態</div>
            <div class="detail-value"><%= displayStatus %></div>
        </div>
        
        <% if (reservation.getBootPlease() != null && !reservation.getBootPlease().trim().isEmpty()) { %>
        <div class="detail-row">
            <div class="detail-label">オプション・合計</div>
            <div class="detail-value"><%= pleaseSummary %></div>
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