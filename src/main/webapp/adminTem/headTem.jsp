<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        <a class="navbar-brand fw-bold fs-3" id="dynamic-brand" href="/HotelReservation/Admin/bootmng">예약관리</a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto" id="dynamic-menu-list">
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/roomStatus">룸 배정/현황</a></li>
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/roomList">방 예약현황</a></li>
                <li class="nav-item"><a class="nav-link" href="/HotelReservation/Admin/onsitePayment">현장결제</a></li>
            </ul>
            <span class="navbar-text text-white">
                ${not empty adminData ? adminData.adminName : '관리자'}님
            </span>
        </div>
    </div>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const currentPath = window.location.pathname; 
        const brandLogo = document.getElementById('dynamic-brand');
        const menuList = document.getElementById('dynamic-menu-list');
        
        // 🎯 1. 안전장치(Null Check) 추가
        // 특정 페이지에서 요소가 일시적으로 로드되지 않더라도 스크립트 에러로 전체 페이지가 멈추는 것을 방임합니다.
        if (brandLogo && menuList) {
            const navLinks = menuList.querySelectorAll('.nav-link');
            let matchedLink = null;
            
            navLinks.forEach(link => {
                const hrefAttr = link.getAttribute('href');
                if (hrefAttr && currentPath.includes(hrefAttr)) {
                    matchedLink = link;
                }
            });
            
            // 2. 일치하는 서브메뉴 스와핑(Swapping) 실행
            if (matchedLink) {
                const currentMenuText = matchedLink.innerText; 
                
                brandLogo.innerText = currentMenuText;
                brandLogo.setAttribute('href', matchedLink.getAttribute('href'));
                
                const parentLi = matchedLink.parentElement;
                parentLi.innerHTML = `<a class="nav-link" href="/HotelReservation/Admin/bootmng">예약관리</a>`;
            }
        }
    });
</script>