<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>JYP HOTEL | 호텔 검색</title>

<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&family=Noto+Serif+KR:wght@400;600;700&display=swap" rel="stylesheet">
<script src="https://unpkg.com/lucide@latest"></script>

<style>
:root {
  --gold: #c9a24d;
  --gold-dark: #8a6423;
  --black: #15120d;
  --brown: #241a10;
  --bg: #f7f3eb;
  --card: #ffffff;
  --line: #e5dccb;
  --text: #1a1714;
  --muted: #756f66;
  --soft: #f3eee5;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text);
}

.header {
  background: linear-gradient(135deg, #17110a, #2b1f10 65%, #17110a);
  color: #fff;
  padding: 34px 20px 30px;
  text-align: center;
  border-bottom: 3px solid var(--gold);
}

.header h1 {
  font-family: 'Noto Serif KR', serif;
  font-size: 42px;
  font-weight: 700;
  letter-spacing: 3px;
  color: #f8e6b0;
}

.header p {
  margin-top: 8px;
  font-size: 14px;
  color: rgba(255,255,255,0.78);
  letter-spacing: 2px;
}

.main-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 28px 20px 60px;
  display: grid;
  grid-template-columns: 310px 1fr;
  gap: 24px;
}

.sidebar {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 24px;
  height: fit-content;
  position: sticky;
  top: 20px;
  box-shadow: 0 12px 30px rgba(0,0,0,0.06);
}

.sidebar h2 {
  font-size: 20px;
  margin-bottom: 18px;
  padding-bottom: 14px;
  border-bottom: 2px solid rgba(201,162,77,0.35);
}

.section {
  padding: 18px 0;
  border-bottom: 1px solid var(--line);
}

.section:last-child {
  border-bottom: none;
}

.section-title {
  font-size: 12px;
  font-weight: 800;
  color: var(--gold-dark);
  letter-spacing: 1.5px;
  margin-bottom: 12px;
}

.hotel-list {
  display: grid;
  gap: 8px;
}

.hotel-option {
  padding: 13px 14px;
  border: 1px solid var(--line);
  background: var(--soft);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.hotel-option:hover,
.hotel-option.selected {
  border-color: var(--gold);
  background: #fff8e9;
  box-shadow: inset 4px 0 0 var(--gold);
}

.hotel-option strong {
  display: block;
  font-size: 14px;
  margin-bottom: 4px;
}

.hotel-option span {
  font-size: 12px;
  color: var(--muted);
}

.form-group {
  margin-bottom: 14px;
}

.form-group label {
  display: block;
  margin-bottom: 7px;
  font-size: 13px;
  font-weight: 700;
  color: var(--muted);
}

.form-group input,
.form-group select {
  width: 100%;
  height: 42px;
  padding: 0 12px;
  border: 1px solid var(--line);
  border-radius: 6px;
  background: var(--soft);
  font-family: inherit;
  font-size: 14px;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--gold);
  box-shadow: 0 0 0 3px rgba(201,162,77,0.16);
}

.counter-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.btn-search {
  width: 100%;
  height: 48px;
  border: none;
  border-radius: 6px;
  background: linear-gradient(135deg, var(--gold-dark), var(--gold));
  color: #fff;
  font-family: inherit;
  font-size: 15px;
  font-weight: 800;
  cursor: pointer;
}

.btn-search:hover {
  filter: brightness(1.08);
}

.content {
  min-width: 0;
}

.search-summary {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 22px 26px;
  margin-bottom: 22px;
  box-shadow: 0 12px 30px rgba(0,0,0,0.05);
}

.search-summary h2 {
  font-family: 'Noto Serif KR', serif;
  font-size: 28px;
  margin-bottom: 12px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
}

.summary-item {
  padding: 14px;
  background: var(--soft);
  border-radius: 6px;
}

.summary-item span {
  display: block;
  font-size: 12px;
  color: var(--muted);
  margin-bottom: 5px;
}

.summary-item strong {
  font-size: 14px;
}

.hotel-card {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 24px;
  box-shadow: 0 12px 30px rgba(0,0,0,0.06);
}

.hotel-hero {
  height: 300px;
  position: relative;
  background-size: cover;
  background-position: center;
}

.hotel-hero::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.62), rgba(0,0,0,0.08));
}

.hotel-hero-text {
  position: absolute;
  left: 28px;
  bottom: 24px;
  z-index: 2;
  color: #fff;
}

.hotel-hero-text h3 {
  font-size: 34px;
  font-weight: 800;
  margin-bottom: 6px;
}

.hotel-hero-text p {
  color: rgba(255,255,255,0.86);
}

.room-section {
  padding: 26px;
}

.room-section-title {
  font-size: 22px;
  font-weight: 800;
  margin-bottom: 18px;
}

.room-list {
  display: grid;
  gap: 18px;
}

.room-card {
  display: grid;
  grid-template-columns: 260px 1fr 190px;
  gap: 22px;
  padding: 18px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fffdf8;
}

.room-image {
  height: 180px;
  border-radius: 6px;
  background: linear-gradient(135deg, #282016, #b8922e);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 800;
  letter-spacing: 1px;
  overflow: hidden;
}

.room-info h4 {
  font-size: 22px;
  margin-bottom: 8px;
}

.room-info p {
  color: var(--muted);
  line-height: 1.7;
  margin-bottom: 12px;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  padding: 6px 10px;
  background: var(--soft);
  border: 1px solid var(--line);
  border-radius: 999px;
  font-size: 12px;
  color: var(--gold-dark);
  font-weight: 700;
}

.room-price {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-end;
  border-left: 1px solid var(--line);
  padding-left: 20px;
}

.room-price span {
  font-size: 12px;
  color: var(--muted);
}

.room-price strong {
  font-size: 26px;
  color: var(--gold-dark);
  margin: 6px 0 14px;
}

.btn-reserve {
  width: 150px;
  height: 44px;
  border: none;
  border-radius: 6px;
  background: var(--black);
  color: #fff;
  font-family: inherit;
  font-weight: 800;
  cursor: pointer;
}

.btn-reserve:hover {
  background: var(--gold-dark);
}

.empty-message {
  padding: 80px 20px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 8px;
  text-align: center;
  color: var(--muted);
}

@media (max-width: 1050px) {
  .main-container {
    grid-template-columns: 1fr;
  }

  .sidebar {
    position: static;
  }

  .summary-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .room-card {
    grid-template-columns: 1fr;
  }

  .room-price {
    align-items: flex-start;
    border-left: none;
    border-top: 1px solid var(--line);
    padding-left: 0;
    padding-top: 18px;
  }
}

@media (max-width: 640px) {
  .header h1 {
    font-size: 30px;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .hotel-hero {
    height: 220px;
  }

  .hotel-hero-text h3 {
    font-size: 25px;
  }
}
</style>
</head>

<body>
<header class="header">
  <h1>JYP HOTEL</h1>
  <p>HOTEL SEARCH & ROOM SELECTION</p>
</header>

<div class="main-container">
  <aside class="sidebar">
    <h2>호텔 검색</h2>

    <div class="section">
      <div class="section-title">지점 선택</div>
      <div class="hotel-list" id="hotelList"></div>
    </div>

    <div class="section">
      <div class="section-title">숙박 일정</div>

      <div class="form-group">
        <label for="checkInDate">체크인</label>
        <input type="date" id="checkInDate">
      </div>

      <div class="form-group">
        <label for="checkOutDate">체크아웃</label>
        <input type="date" id="checkOutDate">
      </div>
    </div>

    <div class="section">
      <div class="section-title">인원 / 객실</div>

      <div class="counter-row">
        <div class="form-group">
          <label for="adults">성인</label>
          <input type="number" id="adults" min="1" max="4" value="2">
        </div>

        <div class="form-group">
          <label for="children">어린이</label>
          <input type="number" id="children" min="0" max="4" value="0">
        </div>
      </div>

      <div class="form-group">
        <label for="rooms">객실 수</label>
        <input type="number" id="rooms" min="1" max="3" value="1">
      </div>
    </div>

    <div class="section">
      <div class="section-title">객실 등급</div>
      <div class="form-group">
        <select id="roomGrade">
          <option value="all">전체</option>
          <option value="standard">스탠다드</option>
          <option value="deluxe">디럭스</option>
          <option value="suite">스위트</option>
        </select>
      </div>
    </div>

    <button type="button" class="btn-search" onclick="searchRooms()">검색</button>
  </aside>

  <main class="content">
    <section class="search-summary">
      <h2>검색 결과</h2>
      <div class="summary-grid">
        <div class="summary-item">
          <span>선택 지점</span>
          <strong id="summaryHotel">-</strong>
        </div>
        <div class="summary-item">
          <span>체크인</span>
          <strong id="summaryCheckIn">-</strong>
        </div>
        <div class="summary-item">
          <span>체크아웃</span>
          <strong id="summaryCheckOut">-</strong>
        </div>
        <div class="summary-item">
          <span>숙박</span>
          <strong id="summaryNights">-</strong>
        </div>
        <div class="summary-item">
          <span>인원 / 객실</span>
          <strong id="summaryPeople">-</strong>
        </div>
      </div>
    </section>

    <section id="results"></section>
  </main>
</div>

<script>
lucide.createIcons();

var contextPath = '<%= request.getContextPath() %>';

var hotels = [
  {
    companyNo: 1,
    name: 'JYP HOTEL SHINJUKU',
    location: '도쿄 신주쿠',
    image: contextPath + '/images/shinmain.png'
  },
  {
    companyNo: 2,
    name: 'JYP HOTEL TOKYO',
    location: '도쿄 마루노우치',
    image: contextPath + '/images/tokyomain.png'
  },
  {
    companyNo: 3,
    name: 'JYP HOTEL YOKOHAMA',
    location: '요코하마 미나토미라이',
    image: contextPath + '/images/yokomain.png'
  }
];

var roomTemplates = [
  {
    gradeCode: 'standard',
    gradeName: '스탠다드 더블',
    typeName: 'Standard Double',
    price: 28000,
    capacity: '최대 2명',
    description: '깔끔하고 실용적인 객실로 비즈니스와 짧은 여행에 적합합니다.',
    tags: ['금연', '더블베드', '무료 Wi-Fi', '욕실']
  },
  {
    gradeCode: 'deluxe',
    gradeName: '디럭스 트윈',
    typeName: 'Deluxe Twin',
    price: 42000,
    capacity: '최대 3명',
    description: '넓은 공간과 안정적인 편의시설을 갖춘 고급형 객실입니다.',
    tags: ['금연', '트윈베드', '무료 Wi-Fi', '시티뷰']
  },
  {
    gradeCode: 'suite',
    gradeName: '프리미엄 스위트',
    typeName: 'Premium Suite',
    price: 78000,
    capacity: '최대 4명',
    description: '여유로운 거실 공간과 프리미엄 서비스를 제공하는 스위트 객실입니다.',
    tags: ['금연', '스위트', '라운지', '고층뷰']
  }
];

var selectedCompanyNo = 1;

function getParams() {
  return new URLSearchParams(window.location.search);
}

function getTodayText() {
  var today = new Date();
  return formatDate(today);
}

function getTomorrowText() {
  var tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  return formatDate(tomorrow);
}

function formatDate(date) {
  var y = date.getFullYear();
  var m = String(date.getMonth() + 1).padStart(2, '0');
  var d = String(date.getDate()).padStart(2, '0');
  return y + '-' + m + '-' + d;
}

function parseDate(value) {
  var parts = value.split('-');
  return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
}

function getNights() {
  var checkIn = document.getElementById('checkInDate').value;
  var checkOut = document.getElementById('checkOutDate').value;

  if (!checkIn || !checkOut) {
    return 1;
  }

  var inDate = parseDate(checkIn);
  var outDate = parseDate(checkOut);
  var diff = outDate.getTime() - inDate.getTime();
  var nights = Math.ceil(diff / (1000 * 60 * 60 * 24));

  return nights < 1 ? 1 : nights;
}

function getSelectedHotel() {
  for (var i = 0; i < hotels.length; i++) {
    if (hotels[i].companyNo === selectedCompanyNo) {
      return hotels[i];
    }
  }

  return hotels[0];
}

function renderHotelList() {
  var hotelList = document.getElementById('hotelList');
  var html = '';

  for (var i = 0; i < hotels.length; i++) {
    var hotel = hotels[i];
    var selectedClass = hotel.companyNo === selectedCompanyNo ? ' selected' : '';

    html += ''
      + '<div class="hotel-option' + selectedClass + '" onclick="selectHotel(' + hotel.companyNo + ')">'
      + '  <strong>' + hotel.name + '</strong>'
      + '  <span>' + hotel.location + ' · 객실 구성 동일</span>'
      + '</div>';
  }

  hotelList.innerHTML = html;
}

function selectHotel(companyNo) {
  selectedCompanyNo = companyNo;
  renderHotelList();
  updateSummary();
  renderResults();
}

function updateSummary() {
  var hotel = getSelectedHotel();
  var checkIn = document.getElementById('checkInDate').value;
  var checkOut = document.getElementById('checkOutDate').value;
  var adults = document.getElementById('adults').value;
  var children = document.getElementById('children').value;
  var rooms = document.getElementById('rooms').value;
  var nights = getNights();

  document.getElementById('summaryHotel').textContent = hotel.name;
  document.getElementById('summaryCheckIn').textContent = checkIn;
  document.getElementById('summaryCheckOut').textContent = checkOut;
  document.getElementById('summaryNights').textContent = nights + '박';
  document.getElementById('summaryPeople').textContent = '성인 ' + adults + '명 · 어린이 ' + children + '명 · 객실 ' + rooms + '개';
}

function searchRooms() {
  var checkIn = document.getElementById('checkInDate').value;
  var checkOut = document.getElementById('checkOutDate').value;
  var adults = parseInt(document.getElementById('adults').value, 10);
  var children = parseInt(document.getElementById('children').value, 10);

  if (!checkIn) {
    alert('체크인 날짜를 선택해주세요.');
    return;
  }

  if (!checkOut) {
    alert('체크아웃 날짜를 선택해주세요.');
    return;
  }

  if (parseDate(checkOut).getTime() <= parseDate(checkIn).getTime()) {
    alert('체크아웃 날짜는 체크인 날짜보다 뒤여야 합니다.');
    return;
  }

  if (adults + children < 1) {
    alert('인원은 최소 1명 이상이어야 합니다.');
    return;
  }

  if (adults + children > 4) {
    alert('총 인원은 최대 4명까지 가능합니다.');
    return;
  }

  updateSummary();
  renderResults();
}

function renderResults() {
  var hotel = getSelectedHotel();
  var selectedGrade = document.getElementById('roomGrade').value;
  var nights = getNights();

  var rooms = roomTemplates.filter(function(room) {
    return selectedGrade === 'all' || room.gradeCode === selectedGrade;
  });

  if (rooms.length === 0) {
    document.getElementById('results').innerHTML = '<div class="empty-message">조건에 맞는 객실이 없습니다.</div>';
    return;
  }

  var html = ''
    + '<article class="hotel-card">'
    + '  <div class="hotel-hero" style="background-image:url(' + hotel.image + ');">'
    + '    <div class="hotel-hero-text">'
    + '      <h3>' + hotel.name + '</h3>'
    + '      <p>' + hotel.location + ' · 선택한 조건에 맞는 객실입니다.</p>'
    + '    </div>'
    + '  </div>'
    + '  <div class="room-section">'
    + '    <div class="room-section-title">객실 선택</div>'
    + '    <div class="room-list">';

  for (var i = 0; i < rooms.length; i++) {
    var room = rooms[i];
    var totalPrice = room.price * nights;

    html += ''
      + '<div class="room-card">'
      + '  <div class="room-image">' + room.gradeName + '</div>'
      + '  <div class="room-info">'
      + '    <h4>' + room.gradeName + '</h4>'
      + '    <p>' + room.typeName + ' · ' + room.capacity + '</p>'
      + '    <p>' + room.description + '</p>'
      + '    <div class="tags">';

    for (var j = 0; j < room.tags.length; j++) {
      html += '<span class="tag">' + room.tags[j] + '</span>';
    }

    html += ''
      + '    </div>'
      + '  </div>'
      + '  <div class="room-price">'
      + '    <span>' + nights + '박 기준</span>'
      + '    <strong>¥' + totalPrice.toLocaleString() + '</strong>'
      + '    <button type="button" class="btn-reserve" onclick="goRoomDetail(\'' + room.gradeCode + '\')">예약하기</button>'
      + '  </div>'
      + '</div>';
  }

  html += ''
    + '    </div>'
    + '  </div>'
    + '</article>';

  document.getElementById('results').innerHTML = html;
}

function goRoomDetail(roomGrade) {
  var hotel = getSelectedHotel();
  var checkIn = document.getElementById('checkInDate').value;
  var checkOut = document.getElementById('checkOutDate').value;
  var adults = document.getElementById('adults').value;
  var children = document.getElementById('children').value;
  var rooms = document.getElementById('rooms').value;
  var nights = getNights();

  var selectedRoom = null;

  for (var i = 0; i < roomTemplates.length; i++) {
    if (roomTemplates[i].gradeCode === roomGrade) {
      selectedRoom = roomTemplates[i];
      break;
    }
  }

  if (!selectedRoom) {
    alert('객실 정보를 찾을 수 없습니다.');
    return;
  }

  var totalPrice = selectedRoom.price * nights;

  var url = contextPath + '/res/roomDetail.jsp'
    + '?companyNo=' + encodeURIComponent(hotel.companyNo)
    + '&hotelName=' + encodeURIComponent(hotel.name)
    + '&roomGrade=' + encodeURIComponent(selectedRoom.gradeName)
    + '&roomType=' + encodeURIComponent(selectedRoom.typeName)
    + '&checkInDate=' + encodeURIComponent(checkIn)
    + '&checkOutDate=' + encodeURIComponent(checkOut)
    + '&adults=' + encodeURIComponent(adults)
    + '&children=' + encodeURIComponent(children)
    + '&rooms=' + encodeURIComponent(rooms)
    + '&totalAmount=' + encodeURIComponent(totalPrice);

  location.href = url;
}

function applyParamsFromMain() {
  var params = getParams();

  var companyNo = params.get('companyNo');
  var checkInDate = params.get('checkInDate');
  var checkOutDate = params.get('checkOutDate');
  var adults = params.get('adults');
  var children = params.get('children');
  var rooms = params.get('rooms');

  if (companyNo) {
    selectedCompanyNo = parseInt(companyNo, 10);
  }

  document.getElementById('checkInDate').value = checkInDate || getTodayText();
  document.getElementById('checkOutDate').value = checkOutDate || getTomorrowText();
  document.getElementById('adults').value = adults || '2';
  document.getElementById('children').value = children || '0';
  document.getElementById('rooms').value = rooms || '1';
}

document.addEventListener('DOMContentLoaded', function() {
  applyParamsFromMain();
  renderHotelList();
  updateSummary();
  renderResults();

  document.getElementById('checkInDate').addEventListener('change', function() {
    updateSummary();
    renderResults();
  });

  document.getElementById('checkOutDate').addEventListener('change', function() {
    updateSummary();
    renderResults();
  });

  document.getElementById('adults').addEventListener('change', updateSummary);
  document.getElementById('children').addEventListener('change', updateSummary);
  document.getElementById('rooms').addEventListener('change', updateSummary);
  document.getElementById('roomGrade').addEventListener('change', renderResults);
});
</script>
</body>
</html>