<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>APA 호텔 | 예약</title>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<script src="https://unpkg.com/lucide@latest"></script>

<style>
:root {
  --background: #f7f9fc;
  --foreground: #1a2234;
  --card: #ffffff;
  --primary: #2563eb;
  --primary-foreground: #ffffff;
  --muted: #f1f5f9;
  --muted-foreground: #64748b;
  --border: #e2e8f0;
  --destructive: #ef4444;
  --radius: 0.5rem;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--background);
  color: var(--foreground);
  line-height: 1.6;
}

.header {
  background: var(--card);
  border-bottom: 1px solid var(--border);
}

.header-container,
main {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 2rem;
}

.header-content {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 40px;
  height: 40px;
  background: var(--primary);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-foreground);
}

.logo-text h1 {
  font-size: 18px;
  font-weight: 700;
}

.logo-text p {
  font-size: 12px;
  color: var(--muted-foreground);
}

.nav,
.header-actions {
  display: flex;
  align-items: center;
  gap: 24px;
}

.nav a,
.header-actions a,
.header-actions button {
  font-size: 14px;
  color: var(--muted-foreground);
  text-decoration: none;
  background: none;
  border: none;
  cursor: pointer;
}

.nav a:hover,
.header-actions a:hover,
.header-actions button:hover {
  color: var(--foreground);
}

.progress-bar {
  background: rgba(241, 245, 249, 0.7);
  padding: 12px 0;
}

.progress-bar-content {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 2rem;
  display: flex;
  gap: 8px;
  font-size: 14px;
}

.progress-bar span {
  color: var(--muted-foreground);
}

.progress-bar .active {
  color: var(--primary);
  font-weight: 700;
}

main {
  padding-top: 32px;
  padding-bottom: 32px;
}

.main-content {
  display: flex;
  gap: 32px;
}

.form-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.sidebar {
  width: 380px;
  flex-shrink: 0;
}

.sidebar-inner {
  position: sticky;
  top: 32px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.card-header {
  padding: 20px 20px 16px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 700;
}

.card-title-icon {
  width: 32px;
  height: 32px;
  background: rgba(37,99,235,0.1);
  color: var(--primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-description {
  margin-top: 4px;
  font-size: 14px;
  color: var(--muted-foreground);
}

.card-content {
  padding: 0 20px 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-row-3 {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 16px;
}

.form-group {
  margin-bottom: 16px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 600;
}

.required {
  color: var(--destructive);
}

input[type="text"],
input[type="email"],
input[type="tel"] {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  font-family: inherit;
  font-size: 14px;
}

input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
}

input.error {
  border-color: var(--destructive);
}

.input-hint,
.sidebar-label,
.sidebar-value-small,
.btn-note {
  font-size: 12px;
  color: var(--muted-foreground);
}

.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.checkbox-wrapper input {
  width: 18px;
  height: 18px;
  accent-color: var(--primary);
}

.option-card,
.radio-card {
  width: 100%;
  margin-bottom: 12px;
  padding: 16px;
  border: 2px solid var(--border);
  border-radius: var(--radius);
  background: var(--card);
  cursor: pointer;
  text-align: left;
}

.option-card.selected,
.radio-card.selected {
  border-color: var(--primary);
  background: rgba(37,99,235,0.05);
}

.option-card-content,
.radio-card-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.option-icon {
  width: 40px;
  height: 40px;
  background: var(--muted);
  color: var(--muted-foreground);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.option-card.selected .option-icon {
  background: var(--primary);
  color: var(--primary-foreground);
}

.option-info {
  flex: 1;
}

.option-header,
.option-price-row,
.price-row,
.price-total-row,
.sidebar-stay-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.option-title {
  font-weight: 700;
}

.option-description {
  margin-top: 4px;
  font-size: 14px;
  color: var(--muted-foreground);
}

.option-unit-price {
  font-size: 12px;
  color: var(--muted-foreground);
}

.option-total-price {
  color: var(--primary);
  font-weight: 700;
}

.radio-card {
  display: flex;
  align-items: center;
  gap: 16px;
}

.radio-card input {
  accent-color: var(--primary);
}

.payment-note,
.terms-box {
  margin-top: 16px;
  padding: 12px;
  background: rgba(241,245,249,0.6);
  border-radius: var(--radius);
  font-size: 14px;
  color: var(--muted-foreground);
}

.terms-box {
  max-height: 160px;
  overflow-y: auto;
  margin-bottom: 16px;
}

.terms-box ul {
  margin-left: 18px;
}

.sidebar-header {
  padding: 16px 20px;
  background: var(--primary);
  color: var(--primary-foreground);
  border-radius: var(--radius) var(--radius) 0 0;
}

.sidebar-info {
  padding: 20px;
}

.sidebar-row {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.sidebar-row i,
.sidebar-stay-item i {
  color: var(--primary);
}

.sidebar-value {
  font-size: 14px;
  font-weight: 700;
}

.sidebar-dates {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.sidebar-date-value,
.sidebar-date-time,
.sidebar-stay-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.separator {
  height: 1px;
  background: var(--border);
  margin: 16px 0;
}

.price-row {
  margin-bottom: 8px;
  font-size: 14px;
}

.price-row .label {
  color: var(--muted-foreground);
}

.price-total-row .label {
  font-weight: 700;
}

.price-total-row .value {
  font-size: 20px;
  font-weight: 800;
  color: var(--primary);
}

.btn-primary {
  width: 100%;
  height: 48px;
  margin-top: 16px;
  border: none;
  border-radius: var(--radius);
  background: var(--primary);
  color: var(--primary-foreground);
  font-family: inherit;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
}

.btn-primary:hover {
  background: #1d4ed8;
}

.btn-note {
  margin-top: 12px;
  text-align: center;
}

@media (max-width: 1024px) {
  .main-content {
    flex-direction: column;
  }

  .sidebar {
    width: 100%;
  }

  .sidebar-inner {
    position: static;
  }

  .nav {
    display: none;
  }
}

@media (max-width: 640px) {
  .header-container,
  main {
    padding-left: 16px;
    padding-right: 16px;
  }

  .form-row,
  .form-row-3,
  .sidebar-dates {
    grid-template-columns: 1fr;
  }
}
</style>
</head>

<body>
<header class="header">
  <div class="header-container">
    <div class="header-content">
      <div class="logo">
        <div class="logo-icon">
          <i data-lucide="building-2"></i>
        </div>
        <div class="logo-text">
          <h1>APA HOTEL</h1>
          <p>Online Reservation</p>
        </div>
      </div>

      <nav class="nav">
        <a href="#">호텔 검색</a>
        <a href="${pageContext.request.contextPath}/reservationSearch.jsp">예약번호로 확인</a>
        <a href="#">회원 서비스</a>
      </nav>

      <div class="header-actions">
        <a href="tel:+81-3-1234-5678">
          <i data-lucide="phone"></i>
          <span>03-1234-5678</span>
        </a>
        <button type="button">
          <i data-lucide="globe"></i>
          <span>KR</span>
        </button>
      </div>
    </div>
  </div>

  <div class="progress-bar">
    <div class="progress-bar-content">
      <span>호텔 선택</span>
      <span>→</span>
      <span>객실 선택</span>
      <span>→</span>
      <span class="active">예약 정보 입력</span>
      <span>→</span>
      <span>예약 완료</span>
    </div>
  </div>
</header>

<main>
  <div class="main-content">
    <div class="form-section">
      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon"><i data-lucide="user"></i></div>
            숙박자 정보
          </div>
          <p class="card-description">체크인 시 필요한 숙박자 정보를 입력해주세요</p>
        </div>

        <div class="card-content">
          <div class="checkbox-wrapper" style="margin-bottom:20px;">
            <input type="checkbox" id="sameAsBooker" onchange="handleSameAsBooker()">
            <label for="sameAsBooker">예약자와 동일</label>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="guestLastName">성 <span class="required">*</span></label>
              <input type="text" id="guestLastName" name="guestLastName" form="paymentForm" placeholder="홍">
            </div>
            <div class="form-group">
              <label for="guestFirstName">이름 <span class="required">*</span></label>
              <input type="text" id="guestFirstName" name="guestFirstName" form="paymentForm" placeholder="길동">
            </div>
          </div>

          <div class="form-group">
            <label for="guestPhone">전화번호 <span class="required">*</span></label>
            <input type="tel" id="guestPhone" name="guestPhone" form="paymentForm" placeholder="010-1234-5678">
            <p class="input-hint">긴급 연락을 위해 사용됩니다</p>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon"><i data-lucide="user-check"></i></div>
            예약자 정보
          </div>
          <p class="card-description">예약 확인 및 연락을 위한 정보를 입력해주세요</p>
        </div>

        <div class="card-content">
          <div class="form-row">
            <div class="form-group">
              <label for="bookerLastName">성 <span class="required">*</span></label>
              <input type="text" id="bookerLastName" name="bookerLastName" form="paymentForm" placeholder="홍">
            </div>
            <div class="form-group">
              <label for="bookerFirstName">이름 <span class="required">*</span></label>
              <input type="text" id="bookerFirstName" name="bookerFirstName" form="paymentForm" placeholder="길동">
            </div>
          </div>

          <div class="form-group">
            <label for="bookerPhone">전화번호 <span class="required">*</span></label>
            <input type="tel" id="bookerPhone" name="bookerPhone" form="paymentForm" placeholder="010-1234-5678">
          </div>

          <div class="form-group">
            <label for="bookerEmail">이메일 <span class="required">*</span></label>
            <input type="email" id="bookerEmail" name="bookerEmail" form="paymentForm" placeholder="example@email.com">
          </div>

          <div class="form-group">
            <label for="bookerEmailConfirm">이메일 확인 <span class="required">*</span></label>
            <input type="email" id="bookerEmailConfirm" name="bookerEmailConfirm" form="paymentForm" placeholder="이메일 주소를 다시 입력해주세요">
          </div>

          <div class="form-row-3">
            <div class="form-group">
              <label for="postalCode">우편번호</label>
              <input type="text" id="postalCode" name="postalCode" form="paymentForm" placeholder="123-4567">
            </div>
            <div class="form-group">
              <label for="address">주소</label>
              <input type="text" id="address" name="address" form="paymentForm" placeholder="상세 주소를 입력해주세요">
            </div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon"><i data-lucide="plus"></i></div>
            추가 옵션
          </div>
          <p class="card-description">편리한 숙박을 위한 추가 서비스를 선택하세요</p>
        </div>

        <div class="card-content">
          <button type="button" class="option-card" id="option-breakfast" onclick="toggleOption('breakfast')">
            <div class="option-card-content">
              <div class="option-icon"><i data-lucide="coffee"></i></div>
              <div class="option-info">
                <div class="option-header">
                  <span class="option-title">조식 뷔페</span>
                </div>
                <p class="option-description">호텔 레스토랑에서 제공되는 조식 뷔페</p>
                <div class="option-price-row">
                  <span class="option-unit-price">¥2,500 / 1인 1박</span>
                  <span class="option-total-price" id="breakfast-total">+ ¥15,000</span>
                </div>
              </div>
            </div>
          </button>

          <button type="button" class="option-card" id="option-fastCheckin" onclick="toggleOption('fastCheckin')">
            <div class="option-card-content">
              <div class="option-icon"><i data-lucide="zap"></i></div>
              <div class="option-info">
                <div class="option-header">
                  <span class="option-title">빠른 체크인</span>
                </div>
                <p class="option-description">대기 없이 빠른 체크인 서비스 이용</p>
                <div class="option-price-row">
                  <span class="option-unit-price">¥1,000 / 1회</span>
                  <span class="option-total-price">+ ¥1,000</span>
                </div>
              </div>
            </div>
          </button>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon"><i data-lucide="credit-card"></i></div>
            결제 방법
          </div>
          <p class="card-description">원하시는 결제 방법을 선택해주세요</p>
        </div>

        <div class="card-content">
          <label class="radio-card selected" id="payment-card" onclick="selectPayment('card')">
            <input type="radio" name="payment" value="card" checked form="paymentForm">
            <div class="radio-card-content">
              <div class="option-icon" style="background:var(--primary); color:var(--primary-foreground);">
                <i data-lucide="credit-card"></i>
              </div>
              <div>
                <p><strong>온라인 결제</strong></p>
                <p class="input-hint">카카오페이</p>
              </div>
            </div>
          </label>

          <label class="radio-card" id="payment-onsite" onclick="selectPayment('onsite')">
            <input type="radio" name="payment" value="onsite" form="paymentForm">
            <div class="radio-card-content">
              <div class="option-icon"><i data-lucide="banknote"></i></div>
              <div>
                <p><strong>현장 결제</strong></p>
                <p class="input-hint">체크인 시 프론트에서 결제</p>
              </div>
            </div>
          </label>

          <div class="payment-note" id="payment-note" style="display:none;">
            현장 결제 시에는 카카오페이 결제창으로 이동하지 않습니다.
          </div>
        </div>
      </div>

      <div class="card" id="terms-card">
        <div class="card-header">
          <div class="card-title">
            <div class="card-title-icon"><i data-lucide="file-text"></i></div>
            이용약관 동의
          </div>
        </div>

        <div class="card-content">
          <div class="terms-box">
            <p><strong>숙박약관</strong></p>
            <p>1. 체크인 시간은 15:00부터이며, 체크아웃 시간은 11:00까지입니다.</p>
            <p>2. 예약 취소 시 취소 수수료가 발생할 수 있습니다.</p>
            <ul>
              <li>7일 전까지: 무료 취소</li>
              <li>3~6일 전: 숙박 요금의 20%</li>
              <li>2일 전: 숙박 요금의 50%</li>
              <li>전일/당일/노쇼: 숙박 요금의 100%</li>
            </ul>
          </div>

          <div class="checkbox-wrapper">
            <input type="checkbox" id="agreeTerms">
            <label for="agreeTerms">위 숙박약관 및 개인정보 처리방침에 동의합니다. <span class="required">*</span></label>
          </div>
        </div>
      </div>
    </div>

    <aside class="sidebar">
      <div class="sidebar-inner">
        <div class="card">
          <div class="sidebar-header">
            <h2>예약 내용</h2>
          </div>

          <div class="sidebar-info">
            <div class="sidebar-row">
              <i data-lucide="map-pin"></i>
              <div>
                <h3>APA 호텔 긴자 츄오</h3>
                <p class="sidebar-value-small">APA Hotel Ginza Chuo</p>
              </div>
            </div>

            <div class="separator"></div>

            <p class="sidebar-label">객실 타입</p>
            <p class="sidebar-value">스탠다드 더블</p>
            <p class="sidebar-value-small">Standard Double</p>

            <div class="separator"></div>

            <div class="sidebar-dates">
              <div>
                <p class="sidebar-label">체크인</p>
                <div class="sidebar-date-value">
                  <i data-lucide="calendar"></i>
                  <span>2025년 1월 15일</span>
                </div>
                <div class="sidebar-date-time">
                  <i data-lucide="clock"></i>
                  <span>15:00 ~</span>
                </div>
              </div>

              <div>
                <p class="sidebar-label">체크아웃</p>
                <div class="sidebar-date-value">
                  <i data-lucide="calendar"></i>
                  <span>2025년 1월 17일</span>
                </div>
                <div class="sidebar-date-time">
                  <i data-lucide="clock"></i>
                  <span>~ 11:00</span>
                </div>
              </div>
            </div>

            <div class="separator"></div>

            <div class="sidebar-stay-info">
              <div class="sidebar-stay-item">
                <i data-lucide="moon"></i>
                <span>2박</span>
              </div>
              <div class="sidebar-stay-item">
                <i data-lucide="users"></i>
                <span>성인 2명, 어린이 1명</span>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-content" style="padding-top:20px;">
            <h3 style="margin-bottom:12px;">요금 상세</h3>

            <div class="price-row">
              <span class="label">객실 요금 (2박)</span>
              <span>¥56,000</span>
            </div>

            <div class="price-row" id="price-breakfast" style="display:none;">
              <span class="label">조식 옵션</span>
              <span id="price-breakfast-value">¥15,000</span>
            </div>

            <div class="price-row" id="price-fastCheckin" style="display:none;">
              <span class="label">빠른 체크인</span>
              <span>¥1,000</span>
            </div>

            <div class="separator"></div>

            <div class="price-row">
              <span class="label">소계</span>
              <span id="subtotal">¥56,000</span>
            </div>

            <div class="price-row">
              <span class="label">세금 (10%)</span>
              <span id="tax">¥5,600</span>
            </div>

            <div class="separator"></div>

            <div class="price-total-row">
              <span class="label">합계 (세금 포함)</span>
              <span class="value" id="total">¥61,600</span>
            </div>

            <form id="paymentForm"
                  action="${pageContext.request.contextPath}/reservationCreate"
                  method="post"
                  onsubmit="return handleReserve();">
              <input type="hidden" name="itemName" value="스탠다드 더블 예약금">
              <input type="hidden" name="quantity" value="1">
              <input type="hidden" name="totalAmount" id="totalAmountInput" value="61600">
              <input type="hidden" name="taxFreeAmount" value="0">
              <input type="hidden" name="roomId" value="1">
              <input type="hidden" name="checkInDate" value="2025-01-15">
              <input type="hidden" name="checkOutDate" value="2025-01-17">
              <input type="hidden" name="peopleCount" value="3">

              <button type="submit" class="btn-primary" id="reserveBtn">예약하기</button>
            </form>

            <p class="btn-note">예약 확정 후 확인 이메일이 발송됩니다</p>
          </div>
        </div>
      </div>
    </aside>
  </div>
</main>

<script>
lucide.createIcons();

const state = {
  selectedPlans: [],
  paymentMethod: 'card',
  reservationData: {
    basePrice: 28000,
    nights: 2,
    adults: 2,
    children: 1,
    taxRate: 0.1
  }
};

function formatPrice(price) {
  return new Intl.NumberFormat('ja-JP').format(price);
}

function toggleOption(optionId) {
  const index = state.selectedPlans.indexOf(optionId);

  if (index > -1) {
    state.selectedPlans.splice(index, 1);
  } else {
    state.selectedPlans.push(optionId);
  }

  const card = document.getElementById('option-' + optionId);
  card.classList.toggle('selected');

  document.getElementById('price-' + optionId).style.display =
    state.selectedPlans.includes(optionId) ? 'flex' : 'none';

  updateTotal();
  lucide.createIcons();
}

function selectPayment(method) {
  state.paymentMethod = method;

  const cardPayment = document.getElementById('payment-card');
  const onsitePayment = document.getElementById('payment-onsite');
  const note = document.getElementById('payment-note');

  if (method === 'card') {
    cardPayment.classList.add('selected');
    onsitePayment.classList.remove('selected');
    note.style.display = 'none';
  } else {
    onsitePayment.classList.add('selected');
    cardPayment.classList.remove('selected');
    note.style.display = 'block';
  }
}

function copyBookerToGuest() {
	  document.getElementById('guestLastName').value =
	    document.getElementById('bookerLastName').value;

	  document.getElementById('guestFirstName').value =
	    document.getElementById('bookerFirstName').value;

	  document.getElementById('guestPhone').value =
	    document.getElementById('bookerPhone').value;
	}

	function handleSameAsBooker() {
	  const checked = document.getElementById('sameAsBooker').checked;

	  if (checked) {
	    copyBookerToGuest();
	  } else {
	    document.getElementById('guestLastName').value = '';
	    document.getElementById('guestFirstName').value = '';
	    document.getElementById('guestPhone').value = '';
	  }

	  document.getElementById('guestLastName').readOnly = checked;
	  document.getElementById('guestFirstName').readOnly = checked;
	  document.getElementById('guestPhone').readOnly = checked;
	}

function updateTotal() {
  const data = state.reservationData;
  const totalGuests = data.adults + data.children;

  let subtotal = data.basePrice * data.nights;

  if (state.selectedPlans.includes('breakfast')) {
    subtotal += totalGuests * 2500 * data.nights;
  }

  if (state.selectedPlans.includes('fastCheckin')) {
    subtotal += 1000;
  }

  const tax = Math.floor(subtotal * data.taxRate);
  const total = subtotal + tax;

  document.getElementById('subtotal').textContent = '¥' + formatPrice(subtotal);
  document.getElementById('tax').textContent = '¥' + formatPrice(tax);
  document.getElementById('total').textContent = '¥' + formatPrice(total);
  document.getElementById('totalAmountInput').value = total;
}

function validateForm() {
  const fields = [
    { id: 'guestLastName', name: '숙박자 성' },
    { id: 'guestFirstName', name: '숙박자 이름' },
    { id: 'guestPhone', name: '숙박자 전화번호' },
    { id: 'bookerLastName', name: '예약자 성' },
    { id: 'bookerFirstName', name: '예약자 이름' },
    { id: 'bookerPhone', name: '예약자 전화번호' },
    { id: 'bookerEmail', name: '이메일' },
    { id: 'bookerEmailConfirm', name: '이메일 확인' }
  ];

  for (const field of fields) {
    const input = document.getElementById(field.id);
    input.classList.remove('error');

    if (!input.value.trim()) {
      input.classList.add('error');
      alert(field.name + '을(를) 입력해주세요.');
      return false;
    }
  }

  const email = document.getElementById('bookerEmail').value;
  const emailConfirm = document.getElementById('bookerEmailConfirm').value;

  if (email !== emailConfirm) {
    document.getElementById('bookerEmailConfirm').classList.add('error');
    alert('이메일 주소가 일치하지 않습니다.');
    return false;
  }

  if (!document.getElementById('agreeTerms').checked) {
    alert('이용약관에 동의해주세요.');
    return false;
  }

  if (state.paymentMethod !== 'card') {
    alert('카카오페이 결제를 진행하려면 온라인 결제를 선택해주세요.');
    return false;
  }

  return true;
}

function handleReserve() {
	  if (document.getElementById('sameAsBooker').checked) {
	    copyBookerToGuest();
	  }

	  updateTotal();

	  if (!validateForm()) {
	    return false;
	  }

	  const btn = document.getElementById('reserveBtn');
	  btn.disabled = true;
	  btn.textContent = '결제창으로 이동 중...';

	  return true;
	}

const totalGuests = state.reservationData.adults + state.reservationData.children;
const breakfastTotal = totalGuests * 2500 * state.reservationData.nights;

document.getElementById('breakfast-total').textContent = '+ ¥' + formatPrice(breakfastTotal);
document.getElementById('price-breakfast-value').textContent = '¥' + formatPrice(breakfastTotal);

updateTotal();
</script>
</body>
</html>