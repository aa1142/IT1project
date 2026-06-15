<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>결제 취소 (BOOT)</title>
<style>
    body { margin: 0; font-family: Arial, 'Noto Sans KR', sans-serif; background: #f5f5f5; color: #222; }
    main { max-width: 550px; margin: 100px auto; padding: 40px; background: #fff; border: 1px solid #ddd; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
    .cancel-icon { font-size: 48px; color: #e67e22; margin-bottom: 15px; }
    h1 { margin-top: 0; color: #111; font-size: 26px; }
    .notice { color: #666; line-height: 1.6; margin-bottom: 30px; }
    .btn-group { display: flex; gap: 10px; }
    .btn { flex: 1; height: 48px; line-height: 48px; font-weight: bold; text-decoration: none; border-radius: 4px; display: inline-block; }
    .btn-dark { background: #333; color: #fff; }
    .btn-light { background: #eee; color: #333; border: 1px solid #ccc; }
</style>
</head>
<body>
<main>
  <div class="cancel-icon">!</div>
  <h1>결제가 취소되었습니다</h1>
  <p class="notice">카카오페이 결제 진행 중 사용자에 의해 결제가 취소되었습니다.<br>다시 예약을 진행하시려면 아래 버튼을 눌러주세요.</p>

  <div class="btn-group">
    <a class="btn btn-light" href="${pageContext.request.contextPath}.../wls/index.jsp">메인으로</a>
    <a class="btn btn-dark" href="javascript:history.back();">이전 화면으로</a>
  </div>
</main>
</body>
</html>