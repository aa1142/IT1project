<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>예약관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
	<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
	<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
        }
        /* 상단 네비바 스타일 변경 (이미지 반영) */
        .admin-nav {
            background-color: #1a2536 !important;
        }
        /* 테이블 폰트 및 스타일 미세 조정 */
        .table th {
            color: #8a92a6;
            font-weight: 500;
            background-color: #f8f9fa;
        }
        .table td {
            vertical-align: middle;
        }
        /* 예약 상태 배지 라운드 스타일 */
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
        <a class="navbar-brand fw-bold fs-3" id="dynamic-brand" href="/bootmng">예약관리</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto" id="dynamic-menu-list">
                <li class="nav-item"><a class="nav-link" href="roomStatus.jsp">룸 지정/현황</a></li>
                <li class="nav-item"><a class="nav-link" href="roomList.jsp">방 예약현황</a></li>
                <li class="nav-item"><a class="nav-link" href="onsitePayment.jsp">현장결제</a></li>
            </ul>
            <span class="navbar-text text-white">${adminData.adminName}님</span>
        </div>
    </div>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const currentPath = window.location.pathname; // 현재 브라우저 URL 경로
        const brandLogo = document.getElementById('dynamic-brand');
        const menuList = document.getElementById('dynamic-menu-list');
        const navLinks = menuList.querySelectorAll('.nav-link');
        
        // 2. 다른 서브페이지(roomStatus.jsp, onsitePayment.jsp 등)일 때 서브메뉴 찾기
        let matchedLink = null;
        navLinks.forEach(link => {
            const hrefAttr = link.getAttribute('href');
            if (hrefAttr && currentPath.includes(hrefAttr)) {
                matchedLink = link;
            }
        });
        
        // 3. 일치하는 서브메뉴가 있다면 위치와 텍스트 스와핑(Swapping) 실행
        if (matchedLink) {
            const currentMenuText = matchedLink.innerText; // 예: "현장결제"
            
            // 맨 왼쪽 대형 타이틀을 현재 메뉴 이름("현장결제")으로 변경
            brandLogo.innerText = currentMenuText;
            brandLogo.setAttribute('href', matchedLink.getAttribute('href'));
            
            // 원래 우측 메뉴판에 있던 자리를 '예약관리' 메뉴로 교체하되,
            // 현재 활성화된 상태이므로 'active' 클래스를 부여하여 글자를 밝게 만듭니다.
            const parentLi = matchedLink.parentElement;
            parentLi.innerHTML = `<a class="nav-link active" href="bootmng.jsp">예약관리</a>`;
        }
    });
</script>