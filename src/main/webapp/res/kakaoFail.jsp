<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null || errorMessage.trim().isEmpty()) {
        errorMessage = "알 수 없는 결제 시스템 오류가 발생했습니다. 관리자에게 문의해 주세요.";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>결제 실패 (BOOT)</title>
<style>
    body { margin: 0; font-family: Arial, 'Noto Sans KR', sans-serif; background: #f5f5f5; color: #222; }
    main { max-width: 550px; margin: 100px auto; padding: 40px; background: #fff; border: 1px solid #d9383a; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
    .fail-icon { font-size: 48px; color: #d9383a; margin-bottom: 15px; }
    h1 { margin-top: 0; color: #d9383a; font-size: 26px; }
    .notice { color: #666; line-height: 1.6; margin-bottom: 20px; }
    .error-box { background: #fff5f5; border: 1px solid #fcc2c3; padding: 15px; text-align: left; color: #b71c1c; font-size: 14px; font-family: monospace; word-break: break-all; margin-bottom: 30px; }
    .home-button { display: inline-block; width: 100%; height: 48px; line-height: 48px; background: #333; color: #fff; font-weight: bold; text-decoration: none; border-radius: 4px; }
</style>
</head>
<body>
<main>
  <div class="fail-icon">✕</div>
  <h1>결제 및 예약 실패</h1>
  <p class="notice">처리 도중 문제가 발생하여 결제가 완료되지 못했습니다.</p>

  <div class="error-box">
    <strong>Error Log:</strong><br>
    <%= errorMessage %>
  </div>

  <a class="home-button" href="${pageContext.request.contextPath}/index.jsp">메인 화면으로 이동</a>
</main>
</body>
</html>