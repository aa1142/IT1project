<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYP HOTEL - 予約照会</title>
    <style>
        body { font-family: sans-serif; background: #f5f6f7; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .search-box { background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.07); width: 100%; max-width: 400px; text-align: center; }
        .logo { font-size: 28px; font-weight: bold; color: #333; margin-bottom: 30px; letter-spacing: 1px; }
        .input-group { text-align: left; margin-bottom: 20px; }
        .input-group label { display: block; font-size: 14px; font-weight: bold; color: #555; margin-bottom: 8px; }
        .input-group input { width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box; font-size: 15px; }
        .input-group input:focus { border-color: #fee500; outline: none; }
        .btn-search { width: 100%; padding: 14px; background: #333; color: #fff; border: none; border-radius: 6px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 10px; transition: background 0.2s; }
        .btn-search:hover { background: #111; }
        .footer-link { margin-top: 20px; font-size: 14px; }
        .footer-link a { color: #666; text-decoration: none; }
        .error-msg { color: #ff3b30; font-size: 14px; margin-bottom: 15px; font-weight: bold; text-align: left; }
    </style>
</head>
<body>

<div class="search-box">
    <div class="logo">JYP HOTEL</div>
    <h3 style="margin-bottom: 25px; color: #444;">非会員予約確認</h3>
    
    <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="error-msg">⚠️ <%= request.getAttribute("errorMessage") %></div>
    <% } %>
    
    <form action="${pageContext.request.contextPath}/bootSearch" method="post">
        <div class="input-group">
            <label for="reservationCode">予約コード</label>
            <input type="text" id="reservationCode" name="reservationCode" placeholder="KPC-で始まる固有コードを入力" required>
        </div>
        
        <div class="input-group">
            <label for="bootKeyword">検証キーワード（電話番号またはメール）</label>
            <input type="text" id="bootKeyword" name="bootKeyword" placeholder="予約時に入力したメールまたは電話番号" required>
        </div>

        <button type="submit" class="btn-search">予約を照会する</button>
    </form>
    
    <div class="footer-link">
        <a href="${pageContext.request.contextPath}/wls/index.jsp">◀ ホームへ戻る</a>
    </div>
</div>

</body>
</html>