<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>予約管理</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        /* 상단 네비바 스타일 */
        .admin-nav {
            background-color: #1a2536 !important;
        }
        /* 테이블 스타일 공통화 */
        .table th {
            color: #8a92a6;
            font-weight: 500;
            background-color: #f8f9fa;
            border-bottom: 1px solid #edeff2;
        }
        .table td {
            vertical-align: middle;
            color: #495057;
            font-size: 14px;
        }
        /* 예약 상태 배지 라운드 스타일 공통화 */
        .badge-status {
            border-radius: 20px;
            padding: 6px 16px;
            font-weight: bold;
            white-space: nowrap;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark admin-nav mb-4">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold fs-3" id="dynamic-brand" href="/HotelReservation/Admin/bootmng">予約管理</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto" id="dynamic-menu-list">
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/roomStatus">客室割り当て・状況</a></li>
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/bootStatus">予約状況</a></li>
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/onsitePayment">現地決済</a></li>
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/notice/noticeList.jsp">お知らせ</a></li>
            </ul>
            <span class="navbar-text text-white">
                ${not empty adminData ? adminData.adminName : '管理者'}様
            </span>
            <a href="${pageContext.request.contextPath}/Admin/logout" class="btn btn-outline-light btn-sm ms-3fw-bold">Logout</a>
        </div>
    </div>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const currentPath = window.location.pathname; 
        const brandLogo = document.getElementById('dynamic-brand');
        const menuList = document.getElementById('dynamic-menu-list');
        
        // 🎯 1. 安全対策（Null Check）の追加
        // 特定のページで要素が一時的にロードされなくても、スクリプトエラーでページ全体が停止するのを防ぎます。
        if (brandLogo && menuList) {
            const navLinks = menuList.querySelectorAll('.nav-link');
            let matchedLink = null;
            
            navLinks.forEach(link => {
                const hrefAttr = link.getAttribute('href');
                if (hrefAttr && currentPath.includes(hrefAttr)) {
                    matchedLink = link;
                }
            });
            
            // 2. 一致するサブメニューのスワップ（Swapping）実行
            if (matchedLink) {
                const currentMenuText = matchedLink.innerText; 
                
                brandLogo.innerText = currentMenuText;
                brandLogo.setAttribute('href', matchedLink.getAttribute('href'));
                
                const parentLi = matchedLink.parentElement;
                parentLi.innerHTML = `<a class="nav-link" href="/HotelReservation/Admin/bootmng">予約管理</a>`;
            }
        }
    });
</script>
</body>
</html>