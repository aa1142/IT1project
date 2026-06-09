<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 1. 로그인 세션 정보 추출
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    boolean isLogin = (sessionUserId != null);

    // 2. 프로젝트 컨텍스트 패스 추출
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>JYP HOTEL | 공식 예약 사이트</title>
    <style>
      @import url("https://googleapis.com");

      :root {
        --main-blue: #111111;
        --point-blue: #c8a96b;
        --bg-gray: #f8f6f2;
        --text-dark: #222222;
      }

      * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Noto Sans KR", sans-serif; }
      html { scroll-behavior: smooth; }
      body {
        background-color: white;
        color: var(--text-dark);
        min-width: 1280px;
        padding-bottom: 110px;
      }

      header {
        display: flex; justify-content: space-between; align-items: center;
        padding: 15px 40px; background: #333; border-bottom:1px solid rgba(255,255,255,0.08);
        position: sticky; top: 0; z-index: 1000;
      }

      .logo { font-size: 1.5rem; font-weight: 900; color: white; text-decoration: none; letter-spacing: -1px; }
      .logo span { color: var(--point-blue); }

      nav ul { display: flex; list-style: none; gap: 20px; align-items: center; }
      nav ul li a { text-decoration: none; color:#f5f5f5;; font-weight: 700; font-size: 14px; }
      nav ul li a:hover { color: var(--point-blue); }

    
.main-visual { 
  position: relative; 
  height: 650px;       /* ◀ 전체 높이 650px */
  overflow: hidden; 
}


.slider {
  position: relative;
  width: 100%;
  height: 100%;        /* ◀ 부모 크기인 650px을 100% 꽉 채우도록 변경 */
  overflow: hidden;
}

.slide {
  position: absolute;
  width: 100%;
  height: 100%;
  opacity: 0;
  animation: fade 18s infinite;
  background-size: cover;      /* ◀ 비율을 유지하며 빈틈없이 채우는 속성 */
  background-position: center;  /* ◀ 이미지의 중심을 기준으로 배치 */
}

      .slide:nth-child(1) { animation-delay: 0s; background-image: url("<%=ctx%>/img/tokyo.png"); }
      .slide:nth-child(2) { animation-delay: 6s; background-image: url("<%=ctx%>/img/shinjuku.png"); }
      .slide:nth-child(3) { animation-delay: 12s; background-image: url("<%=ctx%>/img/yokohama.png"); }

      @keyframes fade {
        0% { opacity: 0; }
        5% { opacity: 1; }
        30% { opacity: 1; }
        35% { opacity: 0; }
        100% { opacity: 0; }
      }
      
            /* =========================
         BOOKING BAR
      ========================= */
      .booking-container {
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100%;
        background: rgba(15,15,15,0.96);
        padding: 14px 0;
        z-index: 9999;
        backdrop-filter: blur(6px);
        box-shadow: 0 -5px 20px rgba(0,0,0,0.2);
      }

      .booking-wrapper {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        align-items: end;
        gap: 14px;
        padding: 0 20px;
      }

      .input-group {
        display: flex;
        flex-direction: column;
        flex: 1;
      }

      .input-group label {
        color: white;
        font-size: 12px;
        font-weight: bold;
        margin-bottom: 6px;
      }

      .input-group input,
      .input-group select {
        height: 42px;
        border: none;
        border-radius: 6px;
        padding: 0 12px;
        font-size: 14px;
        outline: none;
      }

      .guest-inline-group {
        flex: 1.3;
      }

      .guest-inline-box {
        height: 42px;
        background: white;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: space-around;
        padding: 0 12px;
      }

      .guest-inline-item {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #333;
        font-size: 13px;
        font-weight: 600;
        white-space: nowrap;
      }

      .guest-inline-item span {
        display: inline-block;
        min-width: 50px;
        text-align: left;
      }

      .counter {
        display: flex;
        align-items: center;
        height: 30px;
        border: 1px solid #ddd;
        border-radius: 4px;
        overflow: hidden;
      }

      .counter button {
        width: 28px;
        height: 30px;
        border: none;
        background: #f3f3f3;
        cursor: pointer;
        font-weight: bold;
      }

      .counter button:hover {
        background: var(--point-blue);
        color: white;
      }

      .counter span {
        width: 32px;
        text-align: center;
        font-size: 13px;
        font-weight: bold;
      }

      .btn-search {
        height: 42px;
        border: none;
        border-radius: 6px;
        padding: 0 30px;
        background: white;
        color: var(--main-blue);
        font-weight: 900;
        cursor: pointer;
        transition: 0.2s;
      }

      .btn-search:hover {
        background: var(--point-blue);
        color: white;
      }

      .main-overlay {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        color: white;
        z-index: 10;
      }

      .main-overlay h1 {
        font-size: 64px;
        font-weight: 900;
        letter-spacing: 2px;
        margin-bottom: 20px;
        text-shadow: 0 4px 20px rgba(0,0,0,0.4);
      }

      .main-btn {
        width: 200px;
        height: 54px;
        border: none;
        border-radius: 6px;
        background: #c8a96b;
        color: #111;
        font-size: 16px;
        font-weight: 700;
        cursor: pointer;
        transition: 0.3s;
      }

      .main-btn:hover {
        background: var(--point-blue);
        color: white;
        transform: translateY(-2px);
      }

      .content-section { max-width: 1200px; margin: 80px auto; padding: 0 20px; text-align: center; }
      .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
      .grid-item { background: var(--bg-gray); padding: 40px 30px; border-radius: 6px; cursor: pointer; transition: 0.3s; }
      .grid-item:hover { transform: translateY(-5px); background: #e9eef5; }
      .grid-item h3 { margin-bottom: 10px; color: var(--main-blue); }

      .detail-section { max-width: 1200px; margin: 100px auto; padding: 0 20px; }
      .detail-box { display: flex; align-items: center; gap: 50px; background: white; border: 1px solid #ddd; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); }
      .detail-image { width: 50%; height: 420px; object-fit: cover; }
      .detail-text { flex: 1; padding: 40px; }
      .detail-text h2 { color: var(--main-blue); margin-bottom: 20px; font-size: 32px; }
      .detail-text p { line-height: 1.9; font-size: 17px; color: #555; }

      footer { background: #333; color: #ccc; padding: 40px 20px; text-align: center; font-size: 13px; margin-top: 100px; }
    </style>
  </head>
  <body>

        <header>
      <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
      <nav>
        <ul>
          <li><a href="#" onclick="scrollToSection('tokyo-section')">지점 찾기</a></li>
          <li><a href="#accommodation">부대시설</a></li>
          
          <% if(!isLogin) { %>
              <!-- 🔓 로그인이 안 된 기본 상태 -->
              <li><a href="login.jsp" style="color:var(--point-blue);">로그인</a></li>
              <li><a href="signup.jsp">회원가입</a></li>
          <% } else { %>
              <!-- 🔒 로그인이 성공한 회원 상태 -->
              <li><a href="myPage.jsp" style="color:var(--point-blue); font-weight:700; text-decoration:none;"><%= sessionUserName %>님 마이페이지</a></li>
              <li><a href="logout.jsp" style="color:#aaa; font-weight:400; margin-left:10px;">로그아웃</a></li>
          <% } %>
        </ul>
      </nav>
    </header>
 


    <main class="main-visual">
      <div class="slider">
        <div class="slide"></div>
        <div class="slide"></div>
        <div class="slide"></div>
      </div>
      <div class="main-overlay">
        <h1>JYP HOTEL</h1>
        <button class="main-btn" onclick="scrollToSection('tokyo-section')">객실 보기</button>
      </div>
    </main>
      
          <section class="content-section" id="accommodation">
      <div class="grid">
        <div class="grid-item" onclick="scrollToSection('tokyo-section')">
          <h3>도쿄</h3>
          <p>도쿄역과 주요 관광지 접근성 우수</p>
        </div>
        <div class="grid-item" onclick="scrollToSection('shinjuku-section')">
          <h3>신주쿠</h3>
          <p>쇼핑과 비즈니스 중심 지역</p>
        </div>
        <div class="grid-item" onclick="scrollToSection('yokohama-section')">
          <h3>요코하마</h3>
          <p>항구도시의 여유로운 분위기</p>
        </div>
      </div>
    </section>

    <section class="detail-section" id="tokyo-section">
      <div class="detail-box">
        <img src="<%=ctx%>/img/tokyo.png" class="detail-image" alt="도쿄">
        <div class="detail-text">
          <h2>도쿄 지점</h2>
          <p>도쿄역 인근에 위치하여 관광과 비즈니스 모두에 최적의 접근성을 제공합니다.</p>
        </div>
      </div>
    </section>

    <section class="detail-section" id="shinjuku-section">
      <div class="detail-box">
        <img src="<%=ctx%>/img/shinjuku.png" class="detail-image" alt="신주쿠">
        <div class="detail-text">
          <h2>신주쿠 지점</h2>
          <p>신주쿠역에서 가까워 쇼핑, 식사, 관광을 편리하게 즐길 수 있습니다.</p>
        </div>
      </div>
    </section>

    <section class="detail-section" id="yokohama-section">
      <div class="detail-box">
        <img src="<%=ctx%>/img/yokohama.png" class="detail-image" alt="요코하마">
        <div class="detail-text">
          <h2>요코하마 지점</h2>
          <p>아름다운 항구 전망과 편안한 객실을 제공하는 프리미엄 지점입니다.</p>
        </div>
      </div>
    </section>

    <div class="booking-container">
      <form action="roomList.jsp" method="get" class="booking-wrapper" onsubmit="return checkBookingForm()">
        <div class="input-group">
          <label>지점명</label>
          <select name="dest" id="dest">
            <option value="tokyo">도쿄</option>
            <option value="shinjuku">신주쿠</option>
            <option value="yokohama">요코하마</option>
          </select>
        </div>

        <div class="input-group">
          <label>체크인</label>
          <input type="date" id="checkin" name="checkin" />
        </div>

        <div class="input-group">
          <label>체크아웃</label>
          <input type="date" id="checkout" name="checkout" />
        </div>

        <div class="input-group guest-inline-group">
          <label>인원</label>
          <div class="guest-inline-box">
            <div class="guest-inline-item">
              <span>성인</span>
              <div class="counter">
                <button type="button" onclick="changeAdult(-1)">-</button>
                <span id="adultCount">2</span>
                <button type="button" onclick="changeAdult(1)">+</button>
              </div>
              <input type="hidden" name="adult" id="adult_input" value="2">
            </div>

            <div class="guest-inline-item">
              <span>어린이</span>
              <div class="counter">
                <button type="button" onclick="changeChild(-1)">-</button>
                <span id="childCount">0</span>
                <button type="button" onclick="changeChild(1)">+</button>
              </div>
              <input type="hidden" name="child" id="child_input" value="0">
            </div>
          </div>
        </div>

        <button type="submit" class="btn-search">호텔 검색</button>
      </form>
    </div>

    <footer>
      <p>&copy; 2026 JYP HOTEL. All rights reserved.</p>
    </footer>

    <script>
      let adultCount = 2;
      let childCount = 0;

      function changeAdult(amount) {
        adultCount += amount;
        if (adultCount < 1) adultCount = 1;
        if (adultCount > 10) adultCount = 10;
        document.getElementById("adultCount").innerText = adultCount;
        document.getElementById("adult_input").value = adultCount;
      }

      function changeChild(amount) {
        childCount += amount;
        if (childCount < 0) childCount = 0;
        if (childCount > 10) childCount = 10;
        document.getElementById("childCount").innerText = childCount;
        document.getElementById("child_input").value = childCount;
      }

      function scrollToSection(id) { 
        document.getElementById(id).scrollIntoView({ behavior: "smooth" }); 
      }

      function checkBookingForm() {
        const checkin = document.getElementById("checkin").value;
        const checkout = document.getElementById("checkout").value;

        if (!checkin || !checkout) {
          alert("날짜를 선택해주세요.");
          return false;
        }

        if(new Date(checkin) >= new Date(checkout)) {
          alert("체크아웃 날짜는 체크인 날짜 이후여야 합니다.");
          return false;
        }
        return true;
      }

      window.onload = function () {
        const today = new Date();
        const tomorrow = new Date();
        tomorrow.setDate(today.getDate() + 1);

        const todayStr = today.toISOString().split("T")[0];
        const tomorrowStr = tomorrow.toISOString().split("T")[0];

        const checkin = document.getElementById("checkin");
        const checkout = document.getElementById("checkout");

        checkin.value = todayStr;
        checkout.value = tomorrowStr;
        checkin.min = todayStr;
        checkout.min = tomorrowStr;
      };

      document.getElementById("checkin").addEventListener("change", function () {
        const checkinDate = new Date(this.value);
        const nextDay = new Date(checkinDate);
        nextDay.setDate(checkinDate.getDate() + 1);

        const checkout = document.getElementById("checkout");
        const nextDayStr = nextDay.toISOString().split("T")[0];

        checkout.min = nextDayStr;
        if (checkout.value <= this.value) checkout.value = nextDayStr;
      });
    </script>
  </body>
</html>
      
      
