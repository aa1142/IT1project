<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>JYP HOTEL | 메인</title>

<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<script src="https://unpkg.com/lucide@latest"></script>

<style>
:root {
  --gold: #c9a24d;
  --gold-dark: #9a772e;
  --black: #111111;
  --deep: #181818;
  --white: #ffffff;
  --muted: #777777;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  font-family: 'Noto Sans KR', sans-serif;
  color: var(--black);
  background: #f5f2ea;
}

.header {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 50;
  background: rgba(255, 255, 255, 0.94);
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
}

.header-inner {
  max-width: 1280px;
  height: 92px;
  margin: 0 auto;
  padding: 0 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo-area {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.logo-top {
  font-size: 13px;
  color: var(--gold-dark);
  font-weight: 500;
}

.logo {
  font-size: 30px;
  font-weight: 800;
  letter-spacing: 1px;
  color: var(--gold-dark);
}

.logo-sub {
  font-size: 13px;
  color: #8a6a2d;
}

.nav {
  display: flex;
  align-items: center;
  gap: 38px;
}

.nav a {
  color: #8a6a2d;
  text-decoration: none;
  font-size: 17px;
  font-weight: 500;
}

.nav a:hover {
  color: var(--black);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.lang-btn,
.reserve-btn {
  height: 36px;
  padding: 0 22px;
  border: none;
  font-family: inherit;
  font-weight: 700;
  cursor: pointer;
}

.lang-btn {
  background: #4f83ad;
  color: #fff;
}

.reserve-btn {
  background: var(--gold);
  color: #fff;
}

.hero {
  min-height: 100vh;
  position: relative;
  overflow: hidden;
}

.hero-slide {
  position: absolute;
  inset: 0;
  opacity: 0;
  background-size: cover;
  background-position: center;
  transition: opacity 1.2s ease;
}

.hero-slide.active {
  opacity: 1;
}

.hero::after {
  content: "";
  position: absolute;
  inset: 0;
  background:
    linear-gradient(to bottom, rgba(0,0,0,0.08), rgba(0,0,0,0.38)),
    linear-gradient(to right, rgba(0,0,0,0.30), rgba(0,0,0,0.04));
  z-index: 1;
}

.hero-content {
  position: relative;
  z-index: 2;
  min-height: 100vh;
  max-width: 1280px;
  margin: 0 auto;
  padding: 180px 48px 80px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.hero-text {
  color: #fff;
  max-width: 720px;
  text-shadow: 0 4px 18px rgba(0,0,0,0.4);
}

.hero-text .eyebrow {
  font-size: 18px;
  color: #f1d99a;
  font-weight: 700;
  margin-bottom: 14px;
}

.hero-text h1 {
  font-size: 58px;
  line-height: 1.18;
  font-weight: 800;
  margin-bottom: 18px;
}

.hero-text p {
  font-size: 19px;
  line-height: 1.8;
  color: rgba(255,255,255,0.92);
}

.search-box {
  margin-top: 52px;
  width: 100%;
  max-width: 1240px;
  display: grid;
  grid-template-columns: 1.15fr 1fr 1fr 1.35fr 160px;
  gap: 8px;
}

.search-item {
  min-height: 86px;
  background: rgba(255,255,255,0.96);
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 0 20px;
  border-radius: 4px;
  box-shadow: 0 12px 30px rgba(0,0,0,0.18);
}

.search-item i {
  width: 28px;
  height: 28px;
  color: var(--black);
  flex-shrink: 0;
}

.search-label {
  font-size: 12px;
  color: var(--muted);
  margin-bottom: 4px;
}

.search-item select,
.search-item input {
  width: 100%;
  border: none;
  outline: none;
  background: transparent;
  font-family: inherit;
  font-size: 16px;
  font-weight: 700;
  color: var(--black);
}

.guest-controls {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: nowrap;
}

.guest-controls select {
  width: auto;
  min-width: 82px;
  padding-right: 18px;
  font-size: 14px;
  font-weight: 800;
  white-space: nowrap;
}

.search-btn {
  min-height: 86px;
  border: none;
  border-radius: 4px;
  background: linear-gradient(135deg, #c9a24d, #8a6423);
  color: #fff;
  font-size: 18px;
  font-weight: 800;
  font-family: inherit;
  cursor: pointer;
  box-shadow: 0 12px 30px rgba(0,0,0,0.24);
}

.search-btn:hover {
  background: linear-gradient(135deg, #d5b15f, #9a772e);
}

.branch-indicator {
  position: absolute;
  right: 48px;
  bottom: 48px;
  z-index: 3;
  display: flex;
  gap: 10px;
}

.dot {
  width: 42px;
  height: 4px;
  background: rgba(255,255,255,0.45);
}

.dot.active {
  background: var(--gold);
}

.service-section {
  position: relative;
  min-height: 760px;
  background:
    linear-gradient(rgba(0,0,0,0.58), rgba(0,0,0,0.58)),
    url('${pageContext.request.contextPath}/images/tokyomain.png');
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
}

.service-content {
  position: relative;
  z-index: 2;
  text-align: center;
  color: #fff;
  padding: 80px 24px;
}

.service-content h2 {
  font-size: 50px;
  line-height: 1.35;
  font-weight: 400;
  letter-spacing: 1px;
  margin-bottom: 58px;
  text-shadow: 0 5px 24px rgba(0,0,0,0.45);
}

.service-icons {
  display: flex;
  justify-content: center;
  gap: 28px;
  margin-bottom: 64px;
}

.service-icon {
  width: 116px;
  height: 116px;
  border: 2px solid rgba(255,255,255,0.92);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.18);
  backdrop-filter: blur(2px);
}

.service-icon i {
  width: 58px;
  height: 58px;
  color: #fff;
  stroke-width: 1.7;
}

.service-title {
  width: 460px;
  height: 86px;
  margin: 0 auto 42px;
  background: linear-gradient(135deg, #c9a24d, #8a6423);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 34px;
  font-weight: 800;
  letter-spacing: 1px;
}

.service-desc {
  font-size: 22px;
  color: rgba(255,255,255,0.92);
  text-shadow: 0 3px 14px rgba(0,0,0,0.45);
}

.quick-section {
  background: #fff;
  padding: 70px 48px;
}

.quick-inner {
  max-width: 1280px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 22px;
}

.quick-card {
  padding: 30px;
  border: 1px solid #e6dcc6;
  background: #fff;
  min-height: 160px;
}

.quick-card h3 {
  font-size: 22px;
  margin-bottom: 10px;
}

.quick-card p {
  color: #666;
  line-height: 1.7;
}

.top-button {
  position: fixed;
  right: 28px;
  bottom: 28px;
  width: 54px;
  height: 54px;
  border: none;
  border-radius: 6px;
  background: var(--gold);
  color: #fff;
  cursor: pointer;
  z-index: 60;
  display: flex;
  align-items: center;
  justify-content: center;
}

.top-button i {
  width: 26px;
  height: 26px;
}

@media (max-width: 1180px) {
  .search-box {
    grid-template-columns: 1fr 1fr;
  }

  .search-btn {
    grid-column: span 2;
  }
}

@media (max-width: 1024px) {
  .header-inner {
    padding: 0 24px;
  }

  .nav {
    display: none;
  }

  .hero-content {
    padding: 150px 24px 60px;
  }

  .hero-text h1 {
    font-size: 42px;
  }

  .quick-inner {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .search-box {
    grid-template-columns: 1fr;
  }

  .search-btn {
    grid-column: span 1;
  }

  .service-section {
    min-height: 680px;
  }

  .service-content h2 {
    font-size: 32px;
    margin-bottom: 38px;
  }

  .service-icons {
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 42px;
  }

  .service-icon {
    width: 82px;
    height: 82px;
  }

  .service-icon i {
    width: 42px;
    height: 42px;
  }

  .service-title {
    width: 280px;
    height: 68px;
    font-size: 26px;
  }

  .service-desc {
    font-size: 16px;
    line-height: 1.7;
  }
}

@media (max-width: 640px) {
  .header-inner {
    height: 76px;
  }

  .logo {
    font-size: 22px;
  }

  .logo-top,
  .logo-sub,
  .header-actions {
    display: none;
  }

  .hero-text h1 {
    font-size: 34px;
  }

  .hero-text p {
    font-size: 15px;
  }

  .search-item,
  .search-btn {
    min-height: 72px;
  }

  .guest-controls {
    grid-template-columns: 1fr;
  }
}
</style>
</head>

<body>
<header class="header">
  <div class="header-inner">
    <div class="logo-area">
      <div class="logo-top">일본 주요 도시에 위치한 프리미엄 호텔</div>
      <div class="logo">JYP HOTEL</div>
      <div class="logo-sub">Luxury Stay in Japan</div>
    </div>

    <nav class="nav">
      <a href="${pageContext.request.contextPath}/res/main.jsp">호텔</a>
      <a href="${pageContext.request.contextPath}/res/hotelSearch.jsp">호텔 검색</a>
      <a href="#">상품</a>
      <a href="#">소식</a>
      <a href="#">자주 묻는 질문</a>
      <a href="${pageContext.request.contextPath}/res/reservationSearch.jsp">예약 조회</a>
    </nav>

    <div class="header-actions">
      <button type="button" class="lang-btn">한국어</button>
      <button type="button" class="reserve-btn" onclick="location.href='${pageContext.request.contextPath}/res/hotelSearch.jsp'">예약</button>
    </div>
  </div>
</header>

<section class="hero" id="top">
  <div class="hero-slide active" style="background-image:url('${pageContext.request.contextPath}/images/shinmain.png');"></div>
  <div class="hero-slide" style="background-image:url('${pageContext.request.contextPath}/images/tokyomain.png');"></div>
  <div class="hero-slide" style="background-image:url('${pageContext.request.contextPath}/images/yokomain.png');"></div>

  <div class="hero-content">
    <div class="hero-text">
      <div class="eyebrow" id="branchName">JYP HOTEL SHINJUKU</div>
      <h1>도심 속에서 만나는<br>품격 있는 호텔 스테이</h1>
      <p>
        신주쿠, 도쿄, 요코하마의 중심에서 편안한 객실과 세련된 서비스를 제공합니다.
        여행과 비즈니스 모두에 어울리는 JYP HOTEL에서 특별한 하루를 시작하세요.
      </p>
    </div>

    <form class="search-box" action="${pageContext.request.contextPath}/res/hotelSearch.jsp" method="get">
      <div class="search-item">
        <i data-lucide="building-2"></i>
        <div style="width:100%;">
          <div class="search-label">호텔 선택</div>
          <select name="companyNo">
            <option value="1">JYP HOTEL SHINJUKU</option>
            <option value="2">JYP HOTEL TOKYO</option>
            <option value="3">JYP HOTEL YOKOHAMA</option>
          </select>
        </div>
      </div>

      <div class="search-item">
        <i data-lucide="calendar-days"></i>
        <div style="width:100%;">
          <div class="search-label">체크인</div>
          <input type="date" name="checkInDate" value="2026-06-10">
        </div>
      </div>

      <div class="search-item">
        <i data-lucide="calendar-days"></i>
        <div style="width:100%;">
          <div class="search-label">체크아웃</div>
          <input type="date" name="checkOutDate" value="2026-06-12">
        </div>
      </div>

      <div class="search-item">
        <i data-lucide="users"></i>
        <div style="width:100%;">
          <div class="search-label">인원</div>
          <div class="guest-controls">
            <select name="adults">
              <option value="1">성인 1명</option>
              <option value="2" selected>성인 2명</option>
              <option value="3">성인 3명</option>
              <option value="4">성인 4명</option>
            </select>

            <select name="children">
              <option value="0" selected>어린이 0명</option>
              <option value="1">어린이 1명</option>
              <option value="2">어린이 2명</option>
              <option value="3">어린이 3명</option>
            </select>

          </div>
        </div>
      </div>

      <button type="submit" class="search-btn">검색</button>
    </form>
  </div>

  <div class="branch-indicator">
    <span class="dot active"></span>
    <span class="dot"></span>
    <span class="dot"></span>
  </div>
</section>

<section class="service-section">
  <div class="service-content">
    <h2>
      당신이 가진 모든 기대를<br>
      만족시키는 JYP HOTEL
    </h2>

    <div class="service-icons">
      <div class="service-icon">
        <i data-lucide="utensils"></i>
      </div>
      <div class="service-icon">
        <i data-lucide="waves"></i>
      </div>
      <div class="service-icon">
        <i data-lucide="washing-machine"></i>
      </div>
      <div class="service-icon">
        <i data-lucide="microwave"></i>
      </div>
      <div class="service-icon">
        <i data-lucide="wifi"></i>
      </div>
    </div>

    <div class="service-title">서비스 목록</div>

    <p class="service-desc">
      일부 서비스 또는 편의 시설은 지점과 객실 타입에 따라 이용이 제한될 수 있습니다.
    </p>
  </div>
</section>

<section class="quick-section">
  <div class="quick-inner">
    <div class="quick-card">
      <h3>신주쿠 지점</h3>
      <p>도쿄의 활기와 가까운 중심 입지. 쇼핑, 관광, 비즈니스 이동에 편리합니다.</p>
    </div>
    <div class="quick-card">
      <h3>도쿄 지점</h3>
      <p>고급스러운 도심 분위기와 안정적인 객실 서비스를 제공하는 프리미엄 지점입니다.</p>
    </div>
    <div class="quick-card">
      <h3>요코하마 지점</h3>
      <p>야경과 항구 풍경을 즐길 수 있는 감성적인 호텔 스테이를 경험할 수 있습니다.</p>
    </div>
  </div>
</section>

<button type="button" class="top-button" onclick="location.href='#top'">
  <i data-lucide="chevron-up"></i>
</button>

<script>
lucide.createIcons();

var slides = document.querySelectorAll('.hero-slide');
var dots = document.querySelectorAll('.dot');
var branchName = document.getElementById('branchName');

var names = [
  'JYP HOTEL SHINJUKU',
  'JYP HOTEL TOKYO',
  'JYP HOTEL YOKOHAMA'
];

var current = 0;

function changeSlide() {
  slides[current].classList.remove('active');
  dots[current].classList.remove('active');

  current = (current + 1) % slides.length;

  slides[current].classList.add('active');
  dots[current].classList.add('active');
  branchName.textContent = names[current];
}

setInterval(changeSlide, 4500);
</script>
</body>
</html>