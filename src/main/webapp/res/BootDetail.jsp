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

    // [로그인 세션 체크 방어선]
    Object loginSession = session.getAttribute("user"); 
    boolean isLogin = (loginSession != null); 

    // 새 규격인 통신용 고유코드 수집 (없으면 복합 문자열 PK인 bootNo로 대체 방어)
    String reservationCode = reservation.getReservationCode();
    if (reservationCode == null || reservationCode.trim().isEmpty()) {
        reservationCode = reservation.getBootNo();
    }

    // PAYMENT.AMOUNT 우선, 없으면 boot_please 총요금
    int finalPrice = reservation.getPaymentAmount();
    if (finalPrice <= 0) {
        finalPrice = HotelPriceUtil.parsePleaseAmount(reservation.getBootPlease(), "총요금");
    }
    if (finalPrice <= 0) {
        int room = HotelPriceUtil.parsePleaseAmount(reservation.getBootPlease(), "객실요금");
        int breakfast = HotelPriceUtil.parsePleaseAmount(reservation.getBootPlease(), "조식요금");
        int fastCheckin = HotelPriceUtil.parsePleaseAmount(reservation.getBootPlease(), "빠른체크인요금");
        finalPrice = room + breakfast + fastCheckin;
    }
    String displayAmount = (finalPrice > 0)
            ? String.format("%,d", finalPrice) + " 円"
            : "—";

    // [장부 바인딩 구역] 
    String paymentStatus = reservation.getPaymentStatus();
    if (paymentStatus == null) {
        paymentStatus = "PENDING";
    }
    
    String displayStatus = "";
    boolean isPaid = false; 

    if ("PAID".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "予約完了";              
        isPaid = true;
    } else if ("PENDING".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "決済待ち";              
    } else if ("REFUNDED".equalsIgnoreCase(paymentStatus)) {
        displayStatus = "キャンセル/返金完了"; 
    } else {
        displayStatus = "その他状態 (" + paymentStatus + ")";
    }

    String pleaseSummary = HotelPriceUtil.formatPleaseSummary(reservation.getBootPlease());

    // [DB 장부 팩트 반영] 지점 코드(companyNo)별 지점 이름 확정
    int cNo = reservation.getCompanyNo(); 
    String companyName = "";

    if (cNo == 1) {
        companyName = "JYP HOTEL 東京店";
    } else if (cNo == 2) {
        companyName = "JYP HOTEL 新宿店";
    } else if (cNo == 3) {
        companyName = "JYP HOTEL 横浜店";
    } else {
        companyName = "JYP HOTEL 店舗 " + cNo;
    }

    // [객실 이미지 및 타입 문자열 매핑] 등급 + 인원수 규격(1, 2, 5 -> single, twin, family) 자동 조립
    String gradeRaw = reservation.getRoomGrade(); 
    int typeRaw = reservation.getRoomType(); 
    
    String filename = "standard_single.png"; 
    String displayRoomType = "Single"; 
    
    if (gradeRaw != null && !gradeRaw.trim().isEmpty()) {
        String grade = gradeRaw.trim().toLowerCase(); 
        String type = "single"; 
        
        if (typeRaw == 2) {
            type = "twin";
            displayRoomType = "Twin";
        } else if (typeRaw == 5) {
            type = "family";
            displayRoomType = "Family";
        } else {
            type = "single";
            displayRoomType = "Single";
        }
        
        filename = grade + "_" + type + ".png";
    }
    
    String roomImageUrl = request.getContextPath() + "/images/rooms/" + filename;
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>予約履歴 (BOOT)</title>

<style>
    :root {
        --gold-primary: #e5cf98;
        --gold-shadow: rgba(229, 207, 152, 0.25);
        --dark-bg: #141414;
        --card-bg: #1f1f1f;
        --border-color: #2e2e2e;
    }

    body {
        margin: 0;
        padding: 0;
        background-color: var(--dark-bg);
        color: #e0e0e0;
        font-family: 'Helvetica Neue', Arial, 'Hiragino Kaku Gothic ProN', Meiryo, sans-serif;
    }

    /* 럭셔리 탑 헤더 */
    .header {
        background-color: #0b0b0b;
        border-bottom: 1px solid var(--border-color);
        padding: 20px 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .logo {
        font-size: 24px;
        font-weight: 700;
        color: var(--gold-primary);
        letter-spacing: 2px;
        text-shadow: 0 0 10px var(--gold-shadow);
    }

    .header-actions {
        display: flex;
        gap: 15px;
    }

    .header-button {
        color: #a0a0a0;
        text-decoration: none;
        font-size: 13px;
        border: 1px solid #333;
        padding: 8px 16px;
        border-radius: 4px;
        background: #111;
        transition: all 0.3s;
    }

    .header-button:hover {
        color: var(--gold-primary);
        border-color: var(--gold-primary);
        background: #1a1a1a;
        box-shadow: 0 0 8px var(--gold-shadow);
    }

    /* 레이아웃 구조 */
    .layout {
        display: flex;
        min-height: calc(100vh - 74px);
    }

    .sidebar {
        width: 240px;
        background-color: #0d0d0d;
        border-right: 1px solid var(--border-color);
        padding: 30px 20px;
    }

    .sidebar h2 {
        font-size: 14px;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 20px;
        padding-left: 10px;
    }

    .side-menu a {
        display: block;
        color: #999;
        text-decoration: none;
        padding: 12px 15px;
        border-radius: 6px;
        margin-bottom: 8px;
        font-size: 14px;
        transition: all 0.3s;
    }

    .side-menu a:hover, .side-menu a.active {
        background-color: #1a1a1a;
        color: var(--gold-primary);
        font-weight: bold;
    }

    .content {
        flex: 1;
        padding: 40px 60px;
    }

    .page-title {
        font-size: 26px;
        color: #ffffff;
        font-weight: 600;
        margin-bottom: 35px;
        letter-spacing: 1px;
    }

    /* 메인 예약 명품 카드 */
    .reservation-card {
        background-color: var(--card-bg);
        border: 1px solid var(--border-color);
        border-radius: 12px;
        padding: 30px;
        display: flex;
        align-items: center;
        gap: 35px;
        position: relative;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    /* 🔥 사진 밖으로 웅장하게 탈출 줌인 컨테이너 */
    .zoom-wrapper {
        position: relative; 
        width: 280px;
        height: 170px;
        flex-shrink: 0;
    }

    .zoom-wrapper .zoom-img {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 8px;
        border: 1px solid #444;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.4);
        transition: all 0.35s cubic-bezier(0.25, 1, 0.5, 1);
        z-index: 1; 
    }

    .zoom-wrapper:hover .zoom-img {
        width: 520px;         
        height: 330px;        
        top: -80px;           
        left: -20px;          
        z-index: 999;         
        border-color: var(--gold-primary);
        box-shadow: 0 20px 45px rgba(0, 0, 0, 0.9), 0 0 20px rgba(229, 207, 152, 0.2); 
    }

    /* 카드 텍스트 정보 구역 */
    .hotel-name {
        font-size: 22px;
        color: #fff;
        margin-top: 0;
        margin-bottom: 18px;
        font-weight: 600;
        letter-spacing: 0.5px;
    }

    .info-line {
        margin: 6px 0;
        font-size: 14px;
        color: #aaaaaa;
    }

    .status-badge {
        display: inline-block;
        background: rgba(229, 207, 152, 0.12);
        color: var(--gold-primary);
        border: 1px solid rgba(229, 207, 152, 0.3);
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        margin-top: 14px;
        letter-spacing: 0.5px;
    }

    /* 액션 제어 버튼 구역 */
    .card-actions {
        display: flex;
        flex-direction: column;
        gap: 12px;
        min-width: 180px;
    }

    .detail-btn-luxury {
        background: linear-gradient(135deg, #d4af37, #aa7c11);
        color: #000 !important;
        border: none;
        padding: 12px 20px;
        font-size: 14px;
        font-weight: 700;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.3s;
        text-align: center;
        box-shadow: 0 4px 15px rgba(170, 124, 17, 0.3);
    }

    .detail-btn-luxury:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(229, 207, 152, 0.5);
        background: linear-gradient(135deg, #f3e5ab, #c59b27);
    }

    .refund-button-luxury {
        background: transparent;
        color: #ff5252;
        border: 1px solid rgba(255, 82, 82, 0.4);
        padding: 11px 20px;
        font-size: 13px;
        font-weight: 600;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.3s;
    }

    .refund-button-luxury:hover {
        background: rgba(255, 82, 82, 0.1);
        border-color: #ff5252;
        box-shadow: 0 0 12px rgba(255, 82, 82, 0.2);
    }

    .back-link {
        display: inline-block;
        margin-top: 30px;
        color: #777;
        text-decoration: none;
        font-size: 14px;
        transition: color 0.3s;
    }

    .back-link:hover {
        color: var(--gold-primary);
    }

    /* 모달 장부 스위트룸 인테리어 스타일 */
    .modal-bg {
        display: none;
        position: fixed;
        top: 0; left: 0; width: 100%; height: 100%;
        background-color: rgba(0,0,0,0.85);
        backdrop-filter: blur(5px);
        z-index: 1000;
    }

    .modal {
        background-color: #1a1a1a;
        border: 1px solid #333;
        border-radius: 16px;
        width: 500px;
        padding: 35px;
        position: absolute;
        top: 50%; left: 50%;
        transform: translate(-50%, -50%);
        box-shadow: 0 20px 50px rgba(0,0,0,0.8), 0 0 30px rgba(229, 207, 152, 0.05);
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #2e2e2e;
        padding-bottom: 18px;
        margin-bottom: 22px;
    }

    .modal-title {
        font-size: 20px;
        font-weight: 600;
        color: var(--gold-primary);
        margin: 0;
    }

    .close-button {
        background: none;
        border: none;
        color: #777;
        font-size: 28px;
        cursor: pointer;
        transition: color 0.3s;
    }

    .close-button:hover {
        color: #fff;
    }

    .detail-row {
        display: flex;
        justify-content: space-between;
        padding: 12px 0;
        border-bottom: 1px solid #222;
        font-size: 14px;
    }

    .detail-label {
        color: #888;
    }

    .detail-value {
        color: #e0e0e0;
        font-weight: 500;
    }

    .highlight-price {
        color: var(--gold-primary) !important;
        font-size: 18px;
        font-weight: 700 !important;
        text-shadow: 0 0 10px rgba(229, 207, 152, 0.3);
    }
</style>
</head>
<body>

<header class="header">
    <div class="logo">JYP HOTEL</div>
    <div class="header-actions">
        <% if (isLogin) { %>
            <a href="#" class="header-button">マイページ</a>
            <a href="${pageContext.request.contextPath}/logout" class="header-button">ログアウト</a>
        <% } %>
    </div>
</header>

<div class="layout">
    <aside class="sidebar">
        <h2>予約メニュー</h2>
        <nav class="side-menu">
            <a href="#" class="active">予約履歴</a>
            <a onclick="openDetail()" style="cursor:pointer;">予約詳細</a>
        </nav>
    </aside>

    <main class="content">
        <h1 class="page-title">予約履歴</h1>

        <section class="reservation-card">
            
            <div class="zoom-wrapper">
                <img src="<%= roomImageUrl %>" alt="<%= reservation.getRoomGrade() %>" class="zoom-img"
                     onerror="this.style.display='none'; this.parentNode.innerHTML='<span style=\'color:#e5cf98; font-size:14px; font-weight:bold;\'><%= reservation.getRoomGrade() %></span>';">
            </div>

            <div style="flex: 1;">
                <h2 class="hotel-name"><%= companyName %></h2>
                <p class="info-line">予約番号 : <%= reservation.getBootNo() %></p>
                <p class="info-line">通信コード : <%= reservationCode %></p>
                <p class="info-line">予約者名 : <%= reservation.getBootName() %></p>
                <p class="info-line">チェックイン : <%= reservation.getBootCheckin() %></p>
                <p class="info-line">チェックアウト : <%= reservation.getBootCheckout() %></p>
                <span class="status-badge"><%= displayStatus %></span>
            </div>

            <div class="card-actions">
                <button type="button" class="detail-btn-luxury" onclick="openDetail()">[予約詳細を見る]</button>

                <% if (isPaid) { %>
                <form action="${pageContext.request.contextPath}/kakaoRefund" method="post"
                      class="refund-form"
                      data-checkin="<%= reservation.getBootCheckin() %>"
                      onsubmit="return checkRefundAvailable(this);">
                    <input type="hidden" name="bootNo" value="<%= reservation.getBootNo() %>">
                    <button type="submit" class="refund-button-luxury">[予約キャンセル/返金]</button>
                </form>
                <% } %>
            </div>
        </section>

        <a href="${pageContext.request.contextPath}/BootSearch.jsp" class="back-link">← 再照会하는</a>
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
            <div class="detail-value" style="font-weight: bold; color: #fff;"><%= reservation.getRoomGrade() %> / <%= reservation.getRoomType() %>名室 (<%= displayRoomType %>)</div>
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
            <div class="detail-value highlight-price"><%= displayAmount %></div>
        </div>

        <div class="detail-row">
            <div class="detail-label">予約状態</div>
            <div class="detail-value"><span class="status-badge" style="margin:0;"><%= displayStatus %></span></div>
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

function checkRefundAvailable(formObj) {
    try {
        let checkinRaw = formObj.getAttribute("data-checkin");
        if (!checkinRaw) return true;
        
        let checkinDateStr = checkinRaw.substring(0, 10).trim();
        
        let today = new Date();
        let yyyy = today.getFullYear();
        let mm = String(today.getMonth() + 1).padStart(2, '0');
        let dd = String(today.getDate()).padStart(2, '0');
        let todayStr = yyyy + "-" + mm + "-" + dd;
        
        console.log("[당일 환불 검증선] 오늘: " + todayStr + " / 체크인 데이트: " + checkinDateStr);
        
        if (todayStr === checkinDateStr) {
            alert("チェックイン当日のキャンセルおよび払い戻しは不可能です。");
            return false; 
        }
        
        return confirm("本当に予約をキャンセルして返金しますか？");
        
    } catch (e) {
        console.error(e);
        return confirm("本当に予約을キャンセルして返金しますか？");
    }
}
</script>

</body>
</html>