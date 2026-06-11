<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. KakaoApproveServlet이 최종 승인 후 세션에 바인딩해 준 BOOT 정보 인출
    String partnerOrderId = (String) session.getAttribute("partnerOrderId");
    String bootNo = (String) session.getAttribute("bootNo"); // [수정] String형 bootNo 수집
    String reservationCode = (String) session.getAttribute("reservationCode");
    Object amountObj = session.getAttribute("amount");
    String mailStatus = (String) session.getAttribute("mailStatus");

    // 방어벽: 정상적인 결제 승인 단계를 거치지 않고 다이렉트로 주소창에 쳐서 들어온 경우 차단
    if (bootNo == null) {
%>
    <script>
        alert("유효하지 않은 접근이거나 결제 성공 정보가 만료되었습니다.");
        location.href = "${pageContext.request.contextPath}/res/roomDetail.jsp";
    </script>
<%
        return;
    }

    int amount = 0;
    if (amountObj != null) {
        amount = Integer.parseInt(String.valueOf(amountObj));
    }
    String displayAmountText = String.format("%,d", amount) + "원";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>결제 완료 (BOOT)</title>
<style>
    body { 
        margin: 0; 
        font-family: Arial, 'Noto Sans KR', sans-serif; 
        background: #f5f5f5; 
        color: #222; 
    }
    main { 
        max-width: 600px; 
        margin: 80px auto; 
        padding: 40px; 
        background: #fff; 
        border: 1px solid #ddd; 
        text-align: center;
        box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    }
    .success-icon {
        font-size: 48px;
        color: #2ecc71;
        margin-bottom: 15px;
    }
    h1 { 
        margin-top: 0; 
        color: #111;
        font-size: 28px;
    }
    .notice { 
        color: #666; 
        line-height: 1.6; 
        margin-bottom: 30px;
    }
    .info-box { 
        display: grid; 
        gap: 12px; 
        margin: 24px 0; 
        padding: 24px; 
        background: #fafafa; 
        border: 1px solid #e4e4e4; 
        text-align: left;
    }
    .row { 
        display: flex; 
        justify-content: space-between; 
        border-bottom: 1px dashed #eee;
        padding-bottom: 8px;
    }
    .row:last-child {
        border-bottom: none;
        padding-bottom: 0;
    }
    .mail-alert {
        background: #e8f4fd;
        color: #2980b9;
        padding: 12px;
        font-size: 14px;
        margin-bottom: 25px;
        border-left: 4px solid #3498db;
        text-align: left;
    }
    .home-button { 
        display: inline-block;
        width: 100%; 
        height: 50px; 
        line-height: 50px;
        background: #333; 
        color: #fff; 
        font-weight: bold; 
        text-decoration: none;
        border-radius: 4px;
        transition: background 0.2s;
    }
    .home-button:hover {
        background: #111;
    }
</style>
</head>
<body>
<main>
  <div class="success-icon">✓</div>
  <h1>예약 및 결제 완료</h1>
  <p class="notice">고객님의 호텔 예약이 성공적으로 확정되었습니다.<br>이용해 주셔서 감사합니다.</p>

  <% if (mailStatus != null) { %>
    <div class="mail-alert">
        <strong>안내:</strong> <%= mailStatus %>
    </div>
  <% 
      // 안내 문구를 보여준 후 세션에서 제거하여 일회성으로 유지
      session.removeAttribute("mailStatus");
     } 
  %>

  <div class="info-box">
    <div class="row"><strong>예약 번호 (BOOT_NO)</strong><span><%= bootNo %></span></div>
    <div class="row"><strong>가맹점 주문번호</strong><span><%= partnerOrderId %></span></div>
    <div class="row"><strong>통신용 고유코드</strong><span><%= reservationCode %></span></div>
    <div class="row"><strong>최종 결제금액</strong><span style="color: #d9383a; font-weight: bold;"><%= displayAmountText %></span></div>
    <div class="row"><strong>결제 수단</strong><span>카카오페이 (KAKAOPAY)</span></div>
  </div>

  <a class="home-button" href="${pageContext.request.contextPath}/index.jsp">메인 화면으로 이동</a>
</main>
</body>
</html>