<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    String sessionUserId = (String) session.getAttribute("sessionUserId");
    String sessionUserName = (String) session.getAttribute("sessionUserName");
    boolean isLogin = (sessionUserId != null);
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>JYP HOTEL | 公式予約サイト</title>
    <style>
      @import url("https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700;900&display=swap");

      :root {
        --main-blue: #111111;
        --point-blue: #c8a96b;
        --bg-gray: #f8f6f2;
        --text-dark: #222222;
      }

      * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Noto Sans JP", sans-serif; }
      html { scroll-behavior: smooth; }
      body { background-color: white; color: var(--text-dark); min-width: 1280px; padding-bottom: 110px; }

      header { display: flex; justify-content: space-between; align-items: center; padding: 15px 40px; background: #333; position: sticky; top: 0; z-index: 1000; }
      .logo { font-size: 1.5rem; font-weight: 900; color: white; text-decoration: none; }
      .logo span { color: var(--point-blue); }
      nav ul { display: flex; list-style: none; gap: 20px; align-items: center; }
      nav ul li a { text-decoration: none; color:#f5f5f5; font-weight: 700; font-size: 14px; }
      nav ul li a:hover { color: var(--point-blue); }

      .main-visual { position: relative; height: 650px; overflow: hidden; }
      .slider { position: relative; width: 100%; height: 100%; overflow: hidden; }
      .slide { position: absolute; width: 100%; height: 100%; opacity: 0; animation: fade 18s infinite; background-size: cover; background-position: center; }
      .slide:nth-child(1) { animation-delay: 0s; background-image: url("<%=ctx%>/images/tokyo.png"); }
      .slide:nth-child(2) { animation-delay: 6s; background-image: url("<%=ctx%>/images/shinjuku.png"); }
      .slide:nth-child(3) { animation-delay: 12s; background-image: url("<%=ctx%>/images/yokohama.png"); }
      @keyframes fade { 0% { opacity: 0; } 5% { opacity: 1; } 30% { opacity: 1; } 35% { opacity: 0; } 100% { opacity: 0; } }

      .main-overlay { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: white; z-index: 10; }
      .main-overlay h1 { font-size: 64px; font-weight: 900; margin-bottom: 20px; text-shadow: 0 4px 20px rgba(0,0,0,0.4); }
      
      .btn-wrapper { display: flex; gap: 10px; justify-content: center; }
      .main-btn { width: 180px; height: 54px; border: none; border-radius: 6px; background: #c8a96b; color: #111; font-size: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; }
      .main-btn.secondary { background: rgba(255,255,255,0.2); color: white; backdrop-filter: blur(5px); }
      .main-btn:hover { background: var(--point-blue); color: white; transform: translateY(-2px); }

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

      .booking-container { position: fixed; bottom: 0; left: 0; width: 100%; background: rgba(15,15,15,0.96); padding: 14px 0; z-index: 9999; backdrop-filter: blur(6px); box-shadow: 0 -5px 20px rgba(0,0,0,0.2); }
      .booking-wrapper { max-width: 1200px; margin: 0 auto; display: flex; align-items: end; gap: 14px; padding: 0 20px; }
      .input-group { display: flex; flex-direction: column; flex: 1; }
      .input-group label { color: white; font-size: 12px; font-weight: bold; margin-bottom: 6px; }
      .input-group input, .input-group select { height: 42px; border: none; border-radius: 6px; padding: 0 12px; font-size: 14px; outline: none; }
      .guest-inline-group { flex: 1.3; }
      .guest-inline-box { height: 42px; background: white; border-radius: 6px; display: flex; align-items: center; justify-content: space-around; padding: 0 12px; }
      .guest-inline-item { display: flex; align-items: center; gap: 10px; color: #333; font-size: 13px; font-weight: 600; white-space: nowrap; }
      .counter { display: flex; align-items: center; height: 30px; border: 1px solid #ddd; border-radius: 4px; overflow: hidden; }
      .counter button { width: 28px; height: 30px; border: none; background: #f3f3f3; cursor: pointer; font-weight: bold; }
      .counter button:hover { background: var(--point-blue); color: white; }
      .counter span { width: 32px; text-align: center; font-size: 13px; font-weight: bold; }
      .btn-search { height: 42px; border: none; border-radius: 6px; padding: 0 30px; background: white; color: var(--main-blue); font-weight: 900; cursor: pointer; }
      .btn-search:hover { background: var(--point-blue); color: white; }

      footer { background: #333; color: #ccc; padding: 40px 20px; text-align: center; font-size: 13px; margin-top: 100px; }
    </style>
  </head>
  <body>
    <header>
      <a href="index.jsp" class="logo">JYP <span>HOTEL</span></a>
      <nav>
        <ul>
          <li><a href="<%=ctx%>/review/reviewList.jsp">REVIEW</a></li>
          <li><a href="<%=ctx%>/notice/noticeList.jsp">NOTICE</a></li>
          <% if(!isLogin) { %>
              <li><a href="<%=ctx%>/wls/login.jsp" style="color:var(--point-blue);">ログイン</a></li>
              <li><a href="<%=ctx%>/signupAction">会員登録</a></li>
          <% } else { %>
              <li><a href="<%=ctx%>/myPage" style="color:var(--point-blue);"><%= sessionUserName %>様 マイページ</a></li>
              <li><a href="logout.jsp" style="color:#aaa;">ログアウト</a></li>
          <% } %>
        </ul>
      </nav>
    </header>

    <main class="main-visual">
      <div class="slider"><div class="slide"></div><div class="slide"></div><div class="slide"></div></div>
      <div class="main-overlay">
        <h1>JYP HOTEL</h1>
        <div class="btn-wrapper">
          <button class="main-btn" onclick="scrollToSection('accommodation')">店舗一覧</button>
        </div>
      </div>
    </main>

    <section class="content-section" id="accommodation">
      <div class="grid">
        <div class="grid-item" onclick="scrollToSection('tokyo-section')"><h3>東京</h3><p>東京駅や主要観光地へのアクセス抜群</p></div>
        <div class="grid-item" onclick="scrollToSection('shinjuku-section')"><h3>新宿</h3><p>ショッピングとビジネスの中心エリア</p></div>
        <div class="grid-item" onclick="scrollToSection('yokohama-section')"><h3>横浜</h3><p>港町ならではの開放的な雰囲気</p></div>
      </div>
    </section>

    <section class="detail-section" id="tokyo-section"><div class="detail-box"><img src="<%=ctx%>/images/tokyo.png" class="detail-image" alt="東京"><div class="detail-text"><h2>東京店</h2><p>東京駅近くに位置し、観光やビジネスの双方に最適なアクセスを提供します。</p></div></div></section>
    <section class="detail-section" id="shinjuku-section"><div class="detail-box"><img src="<%=ctx%>/images/shinjuku.png" class="detail-image" alt="新宿"><div class="detail-text"><h2>新宿店</h2><p>新宿駅からほど近く、ショッピングやグルメ、観光を快適にお楽しみいただけます。</p></div></div></section>
    <section class="detail-section" id="yokohama-section"><div class="detail-box"><img src="<%=ctx%>/images/yokohama.png" class="detail-image" alt="横浜"><div class="detail-text"><h2>横浜店</h2><p>美しい港の景色と心地よい客室を提供するプレミアムな店舗です。</p></div></div></section>

    <div class="booking-container">
      <form action="<%=ctx%>/testex2/keywordProc.jsp" method="post" class="booking-wrapper" onsubmit="return checkBookingForm()">
        <div class="input-group">
          <label>店舗名</label>
          <select name="dest" id="dest">
            <option value="tokyo">東京</option>
            <option value="shinjuku">新宿</option>
            <option value="yokohama">横浜</option>
          </select>
        </div>
        <div class="input-group">
          <label>チェックイン</label>
          <input type="date" id="checkin" name="checkin" />
        </div>
        <div class="input-group">
          <label>チェックアウト</label>
          <input type="date" id="checkout" name="checkout" />
        </div>
        <div class="input-group guest-inline-group">
          <label>人数</label>
          <div class="guest-inline-box">
            <div class="guest-inline-item">
              <span>大人</span>
              <div class="counter"><button type="button" onclick="changeAdult(-1)">-</button><span id="adultCount">2</span><button type="button" onclick="changeAdult(1)">+</button></div>
              <input type="hidden" name="adult" id="adult_input" value="2">
            </div>
            <div class="guest-inline-item">
              <span>子供</span>
              <div class="counter"><button type="button" onclick="changeChild(-1)">-</button><span id="childCount">0</span><button type="button" onclick="changeChild(1)">+</button></div>
              <input type="hidden" name="child" id="child_input" value="0">
            </div>
          </div>
        </div>
        <input type="hidden" name="rooms" value="1">
        <input type="hidden" name="room_grade" value="스탠다드">

        <button type="submit" class="btn-search">空室検索</button>
      </form>
    </div>

    <footer><p>&copy; 2026 JYP HOTEL. All rights reserved.</p></footer>

    <script>
      let adultCount = 2; let childCount = 0;
      function changeAdult(amount) { adultCount = Math.max(1, Math.min(10, adultCount + amount)); document.getElementById("adultCount").innerText = adultCount; document.getElementById("adult_input").value = adultCount; }
      function changeChild(amount) { childCount = Math.max(0, Math.min(10, childCount + amount)); document.getElementById("childCount").innerText = childCount; document.getElementById("child_input").value = childCount; }
      function scrollToSection(id) { document.getElementById(id).scrollIntoView({ behavior: "smooth" }); }
      function checkBookingForm() {
        const checkin = document.getElementById("checkin").value; const checkout = document.getElementById("checkout").value;
        if (!checkin || !checkout || new Date(checkin) >= new Date(checkout)) { alert("正しい日付を選択してください。"); return false; }
        return true;
      }
      window.onload = function () {
        const today = new Date(); const tomorrow = new Date(); tomorrow.setDate(today.getDate() + 1);
        const todayStr = today.toISOString().split("T")[0]; const tomorrowStr = tomorrow.toISOString().split("T")[0];
        document.getElementById("checkin").value = todayStr; document.getElementById("checkout").value = tomorrowStr;
        document.getElementById("checkin").min = todayStr; document.getElementById("checkout").min = tomorrowStr;
      };
    </script>
  </body>
</html>