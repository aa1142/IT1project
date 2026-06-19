<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>決済キャンセル (BOOT)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/Boot.css?v=1.2">
</head>
<body>
<main class="receipt-container" style="border-top: 6px solid #f1c40f;">
    
    <div class="receipt-header">
        <div class="pay-icon cancel">!</div>
        <h2>決済がキャンセルされました</h2>
        <p class="notice">
            カカオペイ決済中にユーザーによって決済がキャンセルされました。<br>
            再度予約を進める場合は、下記のボタンを押してください。
        </p>
    </div>

    <div class="btn-group" style="display: flex; flex-direction: column; gap: 0;">
        <a class="btn btn-primary" href="javascript:history.back();">前の画面へ戻る</a>
        
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/wls/index.jsp">メイン画面へ移動</a>
    </div>
</main>
</body>
</html>