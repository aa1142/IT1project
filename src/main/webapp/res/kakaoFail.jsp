<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null || errorMessage.trim().isEmpty()) {
        errorMessage = "不明な決済システムエラーが発生しました。管理者にお問い合わせください。";
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>決済失敗 (BOOT)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/res/css/Boot.css?v=1.1">
    
    <style>
        .error-box {
            background: #221a1a; /* 딥 다크 레드 차콜 */
            border: 1px solid #4a2323;
            padding: 18px;
            text-align: left;
            color: #f3a4a4; /* 눈이 편안한 인디핑크 계열 에러 텍스트 */
            font-size: 13px;
            font-family: monospace;
            word-break: break-all;
            margin-bottom: 30px;
            border-radius: 8px;
        }
        .error-box strong {
            color: #e74c3c; /* 강렬한 네온 레드 포인트 */
            display: inline-block;
            margin-bottom: 6px;
        }
    </style>
</head>
<body>
<main class="receipt-container" style="border-top: 6px solid #e74c3c;">
    
    <div class="receipt-header">
        <div class="pay-icon fail">✖</div>
        <h2>決済に失敗しました</h2>
        <p class="notice">処理中に問題が発生し、決済を完了できませんでした。<br>エラーメッセージをご確認の上, 再度お試しください。</p>
    </div>

    <div class="section-title">Error Details</div>
    <div class="error-box">
        <strong>Error Log:</strong><br>
        <%= errorMessage %>
    </div>

    <div class="btn-group">
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/wls/index.jsp">メイン画面へ移動</a>
    </div>
</main>
</body>
</html>