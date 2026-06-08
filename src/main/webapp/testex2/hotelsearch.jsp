<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>호텔 예약 사이트</title>
    <%-- 서버 사이드 JSP 로직은 여기에 추가 --%>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Noto+Serif+KR:wght@300;400;600&family=Noto+Sans+KR:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script type="text/javascript" src="sescript.js"></script>
    <link href="sestyle.css" type="text/css" rel="stylesheet">
    <!--<style></style>-->
</head>
<body>
    <!-- 이미지 업로드 입력 (숨김 — 이미지 클릭 시 활용 가능) -->
    <input type="file" id="imgUploadInput" accept="image/*" style="display:none">

    <!-- 라이트박스: 이미지 클릭 시 전체화면으로 표시 -->
    <div class="lightbox-overlay" id="lightboxOverlay" onclick="closeLightbox()">
        <span class="lightbox-close" onclick="closeLightbox()">✕</span>
        <img class="lightbox-img" id="lightboxImg" src="" alt="" onclick="event.stopPropagation()">
    </div>

    <!-- 헤더 -->
    <header>
        <h1>호텔 예약 사이트</h1>
        <p>호텔을 선택하고 방을 예약하세요</p>
    </header>

    <!-- 메인 레이아웃 -->
    <div class="main-container">

        <!-- 왼쪽 사이드바: 검색 조건 입력 -->
        <div class="sidebar-left">
            <h2>예약 검색</h2>

            <!-- 호텔 지점 검색 -->
            <div class="hotel-search-section sidebar-section">
                <h3>호텔 지점 검색</h3>
                <div class="hotel-search-input">
                    <input type="text" id="hotelSearchInput" placeholder="지점명 검색...">
                    <button type="button" onclick="searchHotels()">검색</button>
                    <button type="button" onclick="clearHotelSearch()">초기화</button>
                </div>
                <!-- 호텔 목록이 JS로 렌더링됨 -->
                <div id="hotelList" class="hotel-list"></div>
            </div>

            <!-- 객실 등급 선택 -->
            <div class="sidebar-section">
                <h3>객실 등급</h3>
                <div class="room-class-selector">
                    <div class="room-class-buttons">
                        <button type="button" class="room-class-btn selected" data-class="스탠다드" onclick="selectRoomClass('스탠다드')">스탠다드</button>
                        <button type="button" class="room-class-btn" data-class="디럭스" onclick="selectRoomClass('디럭스')">디럭스</button>
                        <button type="button" class="room-class-btn" data-class="스위트" onclick="selectRoomClass('스위트')">스위트</button>
                    </div>
                </div>
            </div>

            <!-- 날짜 / 인원 선택 -->
            <div class="sidebar-section">
                <h3>날짜 및 인원</h3>

                <!-- 체크인 날짜 (커스텀 달력) -->
                <div class="form-group date-picker-container">
                    <label for="checkinDate">체크인 날짜</label>
                    <input type="text" id="checkinDate" class="date-input" placeholder="YYYY-MM-DD" readonly>
                    <div class="calendar" id="checkinCalendar"></div>
                </div>

                <!-- 숙박 일수 -->
                <div class="form-group">
                    <label for="nights">숙박 일수</label>
                    <div class="counter-input">
                        <button type="button" onclick="changeCount('nights', -1, 1, 30)">−</button>
                        <input type="number" id="nights" value="1" min="1" max="30" readonly>
                        <button type="button" onclick="changeCount('nights', 1, 1, 30)">+</button>
                    </div>
                </div>

                <!-- 방 수 -->
                <div class="form-group">
                    <label for="rooms">방 수</label>
                    <div class="counter-input">
                        <button type="button" onclick="changeCount('rooms', -1, 1, 10)">−</button>
                        <input type="number" id="rooms" value="1" min="1" max="10" readonly>
                        <button type="button" onclick="changeCount('rooms', 1, 1, 10)">+</button>
                    </div>
                </div>

                <!-- 성인 인원 -->
                <div class="counter-group">
                    <div class="counter">
                        <label for="adults">성인</label>
                        <div class="counter-input">
                            <button type="button" onclick="changeCount('adults', -1, 1, 20)">−</button>
                            <input type="number" id="adults" value="1" min="1" max="20" readonly>
                            <button type="button" onclick="changeCount('adults', 1, 1, 20)">+</button>
                        </div>
                    </div>
                </div>

                <!-- 어린이 인원 -->
                <div class="counter-group">
                    <div class="counter">
                        <label for="children">어린이</label>
                        <div class="counter-input">
                            <button type="button" onclick="changeCount('children', -1, 0, 20)">−</button>
                            <input type="number" id="children" value="0" min="0" max="20" readonly>
                            <button type="button" onclick="changeCount('children', 1, 0, 20)">+</button>
                        </div>
                    </div>
                </div>

                <!-- 현재 선택된 예약 정보 요약 -->
                <div class="info-box">
                    <strong>예약 정보:</strong><br>
                    호텔: <span id="infoHotelName">-</span><br>
                    체크인: <span id="infoCheckin">-</span><br>
                    체크아웃: <span id="infoCheckout">-</span><br>
                    숙박: <span id="infoNights">-</span>박<br>
                    방: <span id="infoRooms">-</span>개<br>
                    인원: 성인 <span id="infoAdults">1</span>명, 어린이 <span id="infoChildren">0</span>명<br>
                    객실 등급: <span id="infoRoomClass">스탠다드</span>
                </div>

                <div class="button-group">
                    <button type="button" class="btn-search" id="btnSearch">검색</button>
                </div>
            </div>
        </div><!-- /sidebar-left -->

        <!-- 오른쪽 콘텐츠: 검색 결과 -->
        <div class="content" id="mainContent">
            <!-- 검색 결과 (초기엔 숨김) -->
            <div id="resultsContainer" style="display:none;">
                <div class="results-header">
                    <h2>예약 정보</h2>
                    <div class="result-count" id="resultCount"></div>
                </div>
                <div id="results"></div>
            </div>
            <!-- 검색 전 안내 메시지 -->
            <div id="initialMessage" class="no-results">
                왼쪽에서 호텔 지점을 검색하고 선택하세요
            </div>
        </div><!-- /content -->

    </div><!-- /main-container -->


   <!-- <script></script> -->
</body>
</html>
