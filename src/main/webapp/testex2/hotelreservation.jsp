<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    =====================================================================
    test01-1.jsp  —  호텔 예약 정보 입력 페이지 (3단계 중 3번째)
    =====================================================================
    연동 출처  : test002.jsp 의 bookRoom() 함수 → POST 전송
    수신 파라미터:
      hotelName      호텔 지점명
      roomGrade      객실 등급명 (예: 트윈 베드룸)
      roomClass      스탠다드 / 디럭스 / 스위트
      capacity       최대 인원 (예: 최대 2인)
      basePrice      1박 단가 (숫자)
      totalPrice     nights × basePrice
      checkin        체크인 날짜 YYYY-MM-DD
      checkout       체크아웃 날짜 YYYY-MM-DD
      checkinLabel   체크인 한국어 표시 (예: 2026년 6월 10일)
      checkoutLabel  체크아웃 한국어 표시
      nights         숙박 일수
      rooms          방 수
      adults         성인 수
      children       어린이 수
    =====================================================================
--%>
<%
    /* ── POST 파라미터 수신 (한글 깨짐 방지) ── */
    request.setCharacterEncoding("UTF-8");

    /* ── 문자열 파라미터 수신 ── */
    String hotelName     = request.getParameter("hotelName");
    String roomGrade     = request.getParameter("roomGrade");
    String roomClass     = request.getParameter("roomClass");
    String capacity      = request.getParameter("capacity");
    String checkin       = request.getParameter("checkin");
    String checkout      = request.getParameter("checkout");
    String checkinLabel  = request.getParameter("checkinLabel");
    String checkoutLabel = request.getParameter("checkoutLabel");

    /* ── 숫자 파라미터 수신 (null·파싱 실패 시 기본값 적용) ── */
    int nights     = 1;
    int rooms      = 1;
    int adults     = 2;
    int children   = 0;
    int basePrice  = 280000;
    int totalPrice = 280000;

    try { nights     = Integer.parseInt(request.getParameter("nights"));     } catch (Exception e) {}
    try { rooms      = Integer.parseInt(request.getParameter("rooms"));      } catch (Exception e) {}
    try { adults     = Integer.parseInt(request.getParameter("adults"));     } catch (Exception e) {}
    try { children   = Integer.parseInt(request.getParameter("children"));   } catch (Exception e) {}
    try { basePrice  = Integer.parseInt(request.getParameter("basePrice"));  } catch (Exception e) {}
    try { totalPrice = Integer.parseInt(request.getParameter("totalPrice")); } catch (Exception e) {}

    /* ── null 방어 처리 (파라미터 미전달 시 기본값 설정) ── */
    if (hotelName     == null || hotelName.isEmpty())     hotelName     = "JYP 호텔";
    if (roomGrade     == null || roomGrade.isEmpty())     roomGrade     = "스탠다드 더블";
    if (roomClass     == null || roomClass.isEmpty())     roomClass     = "스탠다드";
    if (capacity      == null || capacity.isEmpty())      capacity      = "최대 2인";
    if (checkin       == null || checkin.isEmpty())       checkin       = "";
    if (checkout      == null || checkout.isEmpty())      checkout      = "";
    if (checkinLabel  == null || checkinLabel.isEmpty())  checkinLabel  = checkin;
    if (checkoutLabel == null || checkoutLabel.isEmpty()) checkoutLabel = checkout;

    /* ── request scope 저장 (EL 표현식 ${...} 으로 JSP 화면에서 접근) ── */
    request.setAttribute("hotelName",      hotelName);
    request.setAttribute("roomGrade",      roomGrade);
    request.setAttribute("roomClass",      roomClass);
    request.setAttribute("capacity",       capacity);
    request.setAttribute("checkin",        checkin);
    request.setAttribute("checkout",       checkout);
    request.setAttribute("checkinLabel",   checkinLabel);
    request.setAttribute("checkoutLabel",  checkoutLabel);
    request.setAttribute("nights",         nights);
    request.setAttribute("rooms",          rooms);
    request.setAttribute("adults",         adults);
    request.setAttribute("children",       children);
    request.setAttribute("basePrice",      basePrice);
    request.setAttribute("totalPrice",     totalPrice);

    /* ── 금액 콤마 포맷 (예: 280000 → 280,000) ── */
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.KOREA);
    request.setAttribute("totalPriceFmt", nf.format(totalPrice));
    request.setAttribute("basePriceFmt",  nf.format(basePrice));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JYP 호텔 | 예약</title>

  <%-- Google Fonts: Noto Sans KR --%>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <%-- Lucide Icons (아이콘 라이브러리) --%>
  <script src="https://unpkg.com/lucide@latest"></script>
  <link href="restyle.css" type="text/css" rel="stylesheet">
  <style>
  </style>
</head>
<body>

  <%-- ════════════════════════════
       헤더: 로고 + 진행 단계 표시
  ════════════════════════════ --%>
  <header class="header">
    <div class="header-container">
      <div class="header-content">
        <div class="logo">

          <%-- 로고 이미지 (경로: 프로젝트 컨텍스트 루트 기준으로 수정) --%>
          <div class="logo-icon">
            <img src="images/jyp6.png" alt="호텔 로고">
          </div>

          <div class="logo-text">
            <h1>JYP HOTEL</h1>
            <p>Online Reservation</p>
          </div>
        </div>
      </div>
    </div>

    <%-- 예약 프로세스 단계 표시 바 --%>
    <div class="progress-bar">
      <div class="progress-bar-content">
        <span>호텔 선택</span>
        <span class="arrow">→</span>
        <span>객실 선택</span>
        <span class="arrow">→</span>
        <span class="active">예약 정보 입력</span><%-- 현재 단계 --%>
        <span class="arrow">→</span>
        <span>예약 완료</span>
      </div>
    </div>
  </header>

  <main>
    <%--
      서버에서 전달받는 데이터 (request scope):
        hotelName, roomGrade, roomClass, capacity
        checkinLabel, checkoutLabel, nights, adults, children
        totalPriceFmt, basePriceFmt  (콤마 포맷 금액)
      회원 정보 (세션/request scope):
        memberInfo.lastName, memberInfo.firstName, memberInfo.phone, memberInfo.email
    --%>
    <div class="main-content">

      <%-- ══════════════════════════
           왼쪽: 입력 폼 영역
      ══════════════════════════ --%>
      <div class="form-section">

        <%-- ── 1. 예약자 정보 카드 (위치 변경: 원래 2번 → 1번) ── --%>
        <div class="card">
          <div class="card-header">
            <div class="card-title">
              <div class="card-title-icon">
                <i data-lucide="user-check" style="width: 16px; height: 16px;"></i>
              </div>
              예약자 정보
            </div>
            <p class="card-description">예약 확인 및 연락을 위한 정보를 입력해주세요</p>
          </div>
          <div class="card-content">

            <%-- "회원 정보 입력" 체크 시 로그인 회원 데이터 자동 채우기 --%>
            <div class="checkbox-wrapper" style="margin-bottom: 20px;">
              <input type="checkbox" id="loadMemberInfo" onchange="handleLoadMemberInfo()">
              <label for="loadMemberInfo">회원 정보 입력</label>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="bookerLastName">성 <span class="required">*</span></label>
                <input type="text" id="bookerLastName" name="bookerLastName"
                       placeholder="홍" value="${param.bookerLastName}">
              </div>
              <div class="form-group">
                <label for="bookerFirstName">이름 <span class="required">*</span></label>
                <input type="text" id="bookerFirstName" name="bookerFirstName"
                       placeholder="길동" value="${param.bookerFirstName}">
              </div>
            </div>

            <div class="form-group">
              <label for="bookerPhone">전화번호 <span class="required">*</span></label>
              <input type="tel" id="bookerPhone" name="bookerPhone"
                     placeholder="010-1234-5678" value="${param.bookerPhone}">
            </div>

            <div class="form-group">
              <label for="bookerEmail">이메일 <span class="required">*</span></label>
              <input type="email" id="bookerEmail" name="bookerEmail"
                     placeholder="example@email.com" value="${param.bookerEmail}">
              <p class="input-hint">예약 확인 메일이 발송됩니다</p>
            </div>

            <div class="form-group">
              <label for="bookerEmailConfirm">이메일 확인 <span class="required">*</span></label>
              <input type="email" id="bookerEmailConfirm" name="bookerEmailConfirm"
                     placeholder="이메일 주소를 다시 입력해주세요">
            </div>

            <div class="form-row-3">
              <div class="form-group">
                <label for="postalCode">우편번호</label>
                <input type="text" id="postalCode" name="postalCode"
                       placeholder="123-456" value="${param.postalCode}">
              </div>
              <div class="form-group">
                <label for="address">주소</label>
                <input type="text" id="address" name="address"
                       placeholder="상세 주소를 입력해주세요" value="${param.address}">
              </div>
            </div>
          </div>
        </div>

        <%-- ── 2. 숙박자 정보 카드 (위치 변경: 원래 1번 → 2번) ── --%>
        <div class="card">
          <div class="card-header">
            <div class="card-title">
              <div class="card-title-icon">
                <i data-lucide="user" style="width: 16px; height: 16px;"></i>
              </div>
              숙박자 정보
            </div>
            <p class="card-description">체크인 시 필요한 숙박자 정보를 입력해주세요</p>
          </div>
          <div class="card-content">

            <%-- "예약자와 동일" 체크 시 위에 입력한 예약자 값을 아래 필드에 자동 복사 --%>
            <div class="checkbox-wrapper" style="margin-bottom: 20px;">
              <input type="checkbox" id="sameAsBooker" onchange="handleSameAsBooker()">
              <label for="sameAsBooker">예약자와 동일</label>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="guestLastName">성 <span class="required">*</span></label>
                <input type="text" id="guestLastName" name="guestLastName"
                       placeholder="홍" value="${param.guestLastName}">
              </div>
              <div class="form-group">
                <label for="guestFirstName">이름 <span class="required">*</span></label>
                <input type="text" id="guestFirstName" name="guestFirstName"
                       placeholder="길동" value="${param.guestFirstName}">
              </div>
            </div>

            <div class="form-group">
              <label for="guestPhone">전화번호 <span class="required">*</span></label>
              <input type="tel" id="guestPhone" name="guestPhone"
                     placeholder="010-1234-5678" value="${param.guestPhone}">
              <p class="input-hint">긴급 연락을 위해 사용됩니다</p>
            </div>
          </div>
        </div>

        <%-- ── 3. 추가 옵션 카드 ── --%>
        <div class="card">
          <div class="card-header">
            <div class="card-title">
              <div class="card-title-icon">
                <i data-lucide="plus" style="width: 16px; height: 16px;"></i>
              </div>
              추가 옵션
            </div>
            <p class="card-description">편리한 숙박을 위한 추가 서비스를 선택하세요</p>
          </div>
          <div class="card-content">

            <%-- 조식 옵션: 클릭 시 toggleOption('breakfast') 호출 → 선택 상태 토글 + 금액 갱신 --%>
            <button type="button" class="option-card" id="option-breakfast"
                    onclick="toggleOption('breakfast')">
              <div class="option-card-content">
                <div class="option-icon">
                  <i data-lucide="coffee" style="width: 20px; height: 20px;"></i>
                </div>
                <div class="option-info">
                  <div class="option-header">
                    <span class="option-title">조식 뷔페</span>
                    <div class="option-check">
                      <i data-lucide="check" style="width: 12px; height: 12px;"></i>
                    </div>
                  </div>
                  <p class="option-description">호텔 레스토랑에서 제공되는 조식 뷔페</p>
                  <div class="option-price-row">
                    <span class="option-unit-price">₩25,000 / 1인 1박</span>
                    <%-- JS에서 인원×박수 계산 후 동적으로 채워짐 --%>
                    <span class="option-total-price" id="breakfast-total">+ ₩150,000</span>
                  </div>
                </div>
              </div>
            </button>

            <%-- 빠른 체크인 옵션: 고정 요금 ₩10,000 --%>
            <button type="button" class="option-card" id="option-fastCheckin"
                    onclick="toggleOption('fastCheckin')">
              <div class="option-card-content">
                <div class="option-icon">
                  <i data-lucide="zap" style="width: 20px; height: 20px;"></i>
                </div>
                <div class="option-info">
                  <div class="option-header">
                    <span class="option-title">빠른 체크인</span>
                    <div class="option-check">
                      <i data-lucide="check" style="width: 12px; height: 12px;"></i>
                    </div>
                  </div>
                  <p class="option-description">오후 1시에 빠른 체크인 서비스 이용</p>
                  <div class="option-price-row">
                    <span class="option-unit-price">₩10,000 / 1회</span>
                    <span class="option-total-price">+ ₩10,000</span>
                  </div>
                </div>
              </div>
            </button>
          </div>
        </div>

        <%-- ── 4. 결제 방법 카드 ── --%>
        <div class="card">
          <div class="card-header">
            <div class="card-title">
              <div class="card-title-icon">
                <i data-lucide="credit-card" style="width: 16px; height: 16px;"></i>
              </div>
              결제 방법
            </div>
            <p class="card-description">원하시는 결제 방법을 선택해주세요</p>
          </div>
          <div class="card-content">

            <%-- 온라인 결제 (기본 선택) --%>
            <label class="radio-card selected" id="payment-card" onclick="selectPayment('card')">
              <input type="radio" name="payment" value="card" checked>
              <div class="radio-card-content">
                <div class="option-icon" style="background: var(--secondary); color: var(--primary);">
                  <i data-lucide="credit-card" style="width: 20px; height: 20px;"></i>
                </div>
                <div class="radio-card-text">
                  <p>온라인 결제</p>
                  <p>카카오페이</p>
                </div>
              </div>
            </label>

            <%-- 현장 결제: 선택 시 payment-note 안내 문구 표시 --%>
            <label class="radio-card" id="payment-onsite" onclick="selectPayment('onsite')">
              <input type="radio" name="payment" value="onsite">
              <div class="radio-card-content">
                <div class="option-icon">
                  <i data-lucide="banknote" style="width: 20px; height: 20px;"></i>
                </div>
                <div class="radio-card-text">
                  <p>현장 결제</p>
                  <p>체크인 시 프론트에서 결제</p>
                </div>
              </div>
            </label>

            <div class="payment-note" id="payment-note" style="display: none;">
              현장 결제 시 현금, 신용카드 등으로 결제 가능합니다.
            </div>
          </div>
        </div>

        <%-- ── 5. 이용약관 동의 카드 ── --%>
        <div class="card" id="terms-card">
          <div class="card-header">
            <div class="card-title">
              <div class="card-title-icon">
                <i data-lucide="file-text" style="width: 16px; height: 16px;"></i>
              </div>
              이용약관 동의
            </div>
          </div>
          <div class="card-content">
            <div class="terms-box">
              <p class="title">숙박약관</p>
              <p>1. 체크인 시간은 15:00부터이며, 체크아웃 시간은 11:00까지입니다.</p>
              <p>2. 예약 취소 시 아래의 취소 수수료가 발생합니다:</p>
              <ul>
                <li>7일 전까지: 무료 취소</li>
                <li>3~6일 전: 숙박 요금의 20%</li>
                <li>2일 전: 숙박 요금의 50%</li>
                <li>전일/당일/노쇼: 숙박 요금의 100%</li>
              </ul>
              <p>3. 객실 내 흡연은 금지되어 있습니다. 위반 시 청소비가 청구될 수 있습니다.</p>
              <p>4. 반려동물 동반은 허용되지 않습니다.</p>
              <p>5. 개인정보는 예약 관리 및 서비스 제공 목적으로만 사용됩니다.</p>
            </div>

            <div class="checkbox-wrapper">
              <input type="checkbox" id="agreeTerms">
              <label for="agreeTerms">
                위 숙박약관 및 <a href="#">개인정보 처리방침</a>에 동의합니다.
                <span class="required">*</span>
              </label>
            </div>
          </div>
        </div>

      </div><%-- /.form-section --%>

      <%-- ══════════════════════════
           오른쪽: 예약 요약 사이드바
      ══════════════════════════ --%>
      <div class="sidebar">
        <div class="sidebar-inner">

          <%-- ── 예약 내용 요약 카드 ── --%>
          <div class="card">
            <div class="sidebar-header">
              <h2>예약 내용</h2>
            </div>
            <div class="sidebar-info">

              <%-- 호텔명 & 등급 --%>
              <div class="sidebar-row">
                <i data-lucide="map-pin" style="width: 16px; height: 16px;"></i>
                <div class="sidebar-row-content">
                  <h3>${hotelName}</h3>
                  <p>${roomClass} 등급</p>
                </div>
              </div>

              <div class="separator"></div>

              <%-- 객실 타입 --%>
              <div>
                <p class="sidebar-label">객실 타입</p>
                <p class="sidebar-value">${roomGrade}</p>
                <p class="sidebar-value-small">${capacity} · ${roomClass}</p>
              </div>

              <div class="separator"></div>

              <%-- 체크인 / 체크아웃 날짜 --%>
              <div class="sidebar-dates">
                <div>
                  <p class="sidebar-label">체크인</p>
                  <div class="sidebar-date-value">
                    <i data-lucide="calendar" style="width: 14px; height: 14px; color: var(--primary-dark);"></i>
                    <span>${checkinLabel}</span>
                  </div>
                  <div class="sidebar-date-time">
                    <i data-lucide="clock" style="width: 14px; height: 14px;"></i>
                    <span>15:00 ~</span>
                  </div>
                </div>
                <div>
                  <p class="sidebar-label">체크아웃</p>
                  <div class="sidebar-date-value">
                    <i data-lucide="calendar" style="width: 14px; height: 14px; color: var(--primary-dark);"></i>
                    <span>${checkoutLabel}</span>
                  </div>
                  <div class="sidebar-date-time">
                    <i data-lucide="clock" style="width: 14px; height: 14px;"></i>
                    <span>~ 11:00</span>
                  </div>
                </div>
              </div>

              <div class="separator"></div>

              <%-- 박수 / 인원 수 --%>
              <div class="sidebar-stay-info">
                <div class="sidebar-stay-item">
                  <i data-lucide="moon" style="width: 16px; height: 16px;"></i>
                  <span>${nights}박</span>
                </div>
                <div class="sidebar-stay-item">
                  <i data-lucide="users" style="width: 16px; height: 16px;"></i>
                  <span>성인 ${adults}명, 어린이 ${children}명</span>
                </div>
              </div>
            </div>
          </div>

          <%-- ── 요금 상세 + 예약하기 버튼 카드 ── --%>
          <div class="card">
            <div class="card-content" style="padding-top: 20px;">
              <h3 style="font-weight: 600; margin-bottom: 12px; color: var(--secondary);">요금 상세</h3>

              <%-- 객실 기본 요금 --%>
              <div class="price-row">
                <span class="label">객실 요금 (${nights}박)</span>
                <span style="font-weight: 500; color: var(--secondary);">₩${totalPriceFmt}</span>
              </div>

              <%-- 조식 옵션 선택 시 표시 (초기 hidden) --%>
              <div class="price-row" id="price-breakfast" style="display: none;">
                <span class="label">조식 옵션</span>
                <span id="price-breakfast-value" style="font-weight: 500; color: var(--secondary);">₩150,000</span>
              </div>

              <%-- 빠른 체크인 선택 시 표시 (초기 hidden) --%>
              <div class="price-row" id="price-fastCheckin" style="display: none;">
                <span class="label">빠른 체크인</span>
                <span style="font-weight: 500; color: var(--secondary);">₩10,000</span>
              </div>

              <div class="separator"></div>

              <%-- 소계 (JS updateTotal()에 의해 갱신) --%>
              <div class="price-row">
                <span class="label">소계</span>
                <span id="subtotal" style="font-weight: 600; color: var(--secondary);">₩${totalPriceFmt}</span>
              </div>

              <div class="separator"></div>

              <%-- 합계 --%>
              <div class="price-total-row">
                <span class="label">합계(세금 포함)</span>
                <span class="value" id="total">₩${totalPriceFmt}</span>
              </div>

              <%-- 예약 확정 버튼 --%>
              <button type="button" class="btn-primary" id="reserveBtn"
                      onclick="handleReserve()" style="margin-top: 16px;">
                예약하기
              </button>

              <p class="btn-note">예약 확정 후 확인 이메일이 발송됩니다</p>
            </div>
          </div>

        </div>
      </div><%-- /.sidebar --%>

    </div><%-- /.main-content --%>
  </main>

  <script>
  /* ── Lucide 아이콘 초기화 ── */
  lucide.createIcons();

  /* ════════════════════════════
     전역 상태 (state)
     - selectedPlans  : 선택된 추가 옵션 ID 배열
     - paymentMethod  : 결제 방법 ('card' | 'onsite')
     - isLoading      : 예약 처리 중 여부
     - reservationData: 서버에서 전달받은 예약 데이터
     - memberData     : 로그인 회원 정보 (미로그인 시 빈 문자열)
  ════════════════════════════ */
  const state = {
    selectedPlans:  [],
    paymentMethod:  'card',
    isLoading:      false,
    reservationData: {
      basePrice : ${basePrice},   // 1박 단가
      nights    : ${nights},      // 숙박 일수
      adults    : ${adults},      // 성인 수
      children  : ${children}     // 어린이 수
    },
    memberData: {
      lastName:  '${not empty memberInfo.lastName  ? memberInfo.lastName  : ""}',
      firstName: '${not empty memberInfo.firstName ? memberInfo.firstName : ""}',
      phone:     '${not empty memberInfo.phone     ? memberInfo.phone     : ""}',
      email:     '${not empty memberInfo.email     ? memberInfo.email     : ""}'
    }
  };

  /* ── 숫자를 한국 원화 표시 형식으로 변환 (예: 150000 → "150,000") ── */
  function formatPrice(price) {
    return new Intl.NumberFormat('ko-KR').format(price);
  }

  /* ── 추가 옵션 토글 (조식 / 빠른 체크인) ── */
  function toggleOption(optionId) {
    const index = state.selectedPlans.indexOf(optionId);

    // 이미 선택된 경우 제거, 아닌 경우 추가
    if (index > -1) {
      state.selectedPlans.splice(index, 1);
    } else {
      state.selectedPlans.push(optionId);
    }

    // 카드 selected 클래스 토글
    const card = document.getElementById('option-' + optionId);
    card.classList.toggle('selected');

    // 아이콘 색상 전환 (선택: 어두운 배경 + 골드 아이콘 / 미선택: 회색 배경)
    const icon = card.querySelector('.option-icon');
    if (state.selectedPlans.includes(optionId)) {
      icon.style.background = 'var(--secondary)';
      icon.style.color      = 'var(--primary)';
    } else {
      icon.style.background = 'var(--muted)';
      icon.style.color      = 'var(--secondary)';
    }

    // 오른쪽 요금 상세에서 해당 항목 행 표시/숨김
    document.getElementById('price-' + optionId).style.display =
      state.selectedPlans.includes(optionId) ? 'flex' : 'none';

    updateTotal();
    lucide.createIcons();
  }

  /* ── 결제 방법 선택 (카드 UI 상태 변경) ── */
  function selectPayment(method) {
    state.paymentMethod = method;

    const cardEl   = document.getElementById('payment-card');
    const onsiteEl = document.getElementById('payment-onsite');
    const note     = document.getElementById('payment-note');

    if (method === 'card') {
      cardEl.classList.add('selected');
      onsiteEl.classList.remove('selected');
      cardEl.querySelector('.option-icon').style.background   = 'var(--secondary)';
      cardEl.querySelector('.option-icon').style.color        = 'var(--primary)';
      onsiteEl.querySelector('.option-icon').style.background = 'var(--muted)';
      onsiteEl.querySelector('.option-icon').style.color      = 'var(--secondary)';
      note.style.display = 'none';
    } else {
      onsiteEl.classList.add('selected');
      cardEl.classList.remove('selected');
      onsiteEl.querySelector('.option-icon').style.background = 'var(--secondary)';
      onsiteEl.querySelector('.option-icon').style.color      = 'var(--primary)';
      cardEl.querySelector('.option-icon').style.background   = 'var(--muted)';
      cardEl.querySelector('.option-icon').style.color        = 'var(--secondary)';
      note.style.display = 'block';
    }
  }

  /* ── "예약자와 동일" 체크박스: 예약자 정보를 숙박자 필드에 복사 ── */
  function handleSameAsBooker() {
    const checked        = document.getElementById('sameAsBooker').checked;
    const guestLastName  = document.getElementById('guestLastName');
    const guestFirstName = document.getElementById('guestFirstName');
    const guestPhone     = document.getElementById('guestPhone');

    if (checked) {
      guestLastName.value  = document.getElementById('bookerLastName').value;
      guestFirstName.value = document.getElementById('bookerFirstName').value;
      guestPhone.value     = document.getElementById('bookerPhone').value;
    }

 // ── 수정 코드 (교체)
    guestLastName.readOnly  = checked;
    guestFirstName.readOnly = checked;
    guestPhone.readOnly     = checked;

    // readonly 시 흐린 배경으로 시각적 표시
    const fields = [guestLastName, guestFirstName, guestPhone];
    fields.forEach(f => {
      f.style.background = checked ? 'var(--muted, #f5f5f5)' : '';
      f.style.cursor     = checked ? 'not-allowed' : '';
    });
  }

  /* ── "회원 정보 입력" 체크박스: 로그인 회원 데이터를 예약자 필드에 채우기 ── */
  function handleLoadMemberInfo() {
    const checked             = document.getElementById('loadMemberInfo').checked;
    const bookerLastName      = document.getElementById('bookerLastName');
    const bookerFirstName     = document.getElementById('bookerFirstName');
    const bookerPhone         = document.getElementById('bookerPhone');
    const bookerEmail         = document.getElementById('bookerEmail');
    const bookerEmailConfirm  = document.getElementById('bookerEmailConfirm');

    if (checked) {
      bookerLastName.value     = state.memberData.lastName;
      bookerFirstName.value    = state.memberData.firstName;
      bookerPhone.value        = state.memberData.phone;
      bookerEmail.value        = state.memberData.email;
      bookerEmailConfirm.value = state.memberData.email;
    } else {
      // 체크 해제 시 초기화
      bookerLastName.value     = '';
      bookerFirstName.value    = '';
      bookerPhone.value        = '';
      bookerEmail.value        = '';
      bookerEmailConfirm.value = '';
    }

    bookerLastName.disabled     = checked;
    bookerFirstName.disabled    = checked;
    bookerPhone.disabled        = checked;
    bookerEmail.disabled        = checked;
    bookerEmailConfirm.disabled = checked;

    // "예약자와 동일"도 체크된 상태라면 숙박자 필드도 연동 갱신
    if (document.getElementById('sameAsBooker').checked) {
      handleSameAsBooker();
    }
  }

  /* ── 소계 / 합계 재계산 및 화면 갱신 ──
     공식:
       소계 = 객실요금(basePrice × nights)
            + 조식(선택 시: 총인원 × 25,000 × nights)
            + 빠른 체크인(선택 시: 10,000)
  ── */
  function updateTotal() {
    const { basePrice, nights, adults, children } = state.reservationData;
    const totalGuests = adults + children;

    let subtotal = basePrice * nights;

    if (state.selectedPlans.includes('breakfast')) {
      subtotal += totalGuests * 25000 * nights;
    }

    if (state.selectedPlans.includes('fastCheckin')) {
      subtotal += 10000;
    }

    document.getElementById('subtotal').textContent = '₩' + formatPrice(subtotal);
    document.getElementById('total').textContent    = '₩' + formatPrice(subtotal);
  }

  /* ── 폼 유효성 검사 ──
     비어 있는 필수 필드에 error 클래스 추가,
     이메일 불일치·약관 미동의도 검사
     반환: 오류 메시지 배열 (빈 배열이면 통과)
  ── */
  function validateForm() {
    const errors = [];

    // 검사할 필수 필드 목록
    const fields = [
      { id: 'guestLastName',      name: '숙박자 성' },
      { id: 'guestFirstName',     name: '숙박자 이름' },
      { id: 'guestPhone',         name: '숙박자 전화번호' },
      { id: 'bookerLastName',     name: '예약자 성' },
      { id: 'bookerFirstName',    name: '예약자 이름' },
      { id: 'bookerPhone',        name: '예약자 전화번호' },
      { id: 'bookerEmail',        name: '이메일' },
      { id: 'bookerEmailConfirm', name: '이메일 확인' }
    ];

    // 이전 오류 스타일 초기화
    fields.forEach(f => document.getElementById(f.id).classList.remove('error'));
    document.getElementById('terms-card').style.borderColor = 'var(--border)';

    // 빈 값 검사 (disabled 또는 readOnly 필드는 제외)
    fields.forEach(field => {
      const input = document.getElementById(field.id);
      if (!input.disabled && !input.readOnly && !input.value.trim()) {
        input.classList.add('error');
        errors.push(field.name + '을(를) 입력해주세요.');
      }
    });

    // 이메일 일치 검사
    const email        = document.getElementById('bookerEmail').value;
    const emailConfirm = document.getElementById('bookerEmailConfirm').value;
    if (email && emailConfirm && email !== emailConfirm) {
      document.getElementById('bookerEmailConfirm').classList.add('error');
      errors.push('이메일 주소가 일치하지 않습니다.');
    }

    // 이용약관 동의 검사
    if (!document.getElementById('agreeTerms').checked) {
      document.getElementById('terms-card').style.borderColor = 'var(--destructive)';
      errors.push('이용약관에 동의해주세요.');
    }

    return errors;
  }

  /* ── 예약하기 버튼 핸들러 ──
     TODO: setTimeout 부분을 실제 서버 API 호출로 교체
     예시:
       fetch('${pageContext.request.contextPath}/reservation/confirm', {
         method: 'POST',
         headers: { 'Content-Type': 'application/json' },
         body: JSON.stringify({ ... })
       }).then(res => res.json()).then(data => { ... });
  ── */
  function handleReserve() {
    // "예약자와 동일" 체크 시 fetch 전 최신 예약자 값으로 숙박자 필드 재동기화
    if (document.getElementById('sameAsBooker').checked) {
      document.getElementById('guestLastName').value  = document.getElementById('bookerLastName').value;
      document.getElementById('guestFirstName').value = document.getElementById('bookerFirstName').value;
      document.getElementById('guestPhone').value     = document.getElementById('bookerPhone').value;
    }

    const errors = validateForm();

    // 첫 번째 오류 메시지 표시 후 중단
    if (errors.length > 0) {
      alert(errors[0]);
      return;
    }

    // 버튼 비활성화 + 스피너 표시
    state.isLoading = true;
    const btn = document.getElementById('reserveBtn');
    btn.disabled  = true;
    btn.innerHTML = '<i data-lucide="loader-2" class="spinner" style="width: 20px; height: 20px;"></i> 처리 중...';
    lucide.createIcons();

    // 실제 구현 시 아래 setTimeout을 fetch POST 요청으로 교체
    fetch('${pageContext.request.contextPath}/reservation/confirm', {
    	  method: 'POST',
    	  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    	  body: new URLSearchParams({
    	    // 호텔 / 객실 정보 (서버에서 받은 값 그대로 재전송)
    	    hotelName     : '${hotelName}',
    	    roomGrade     : '${roomGrade}',
    	    roomClass     : '${roomClass}',
    	    capacity      : '${capacity}',
    	    checkin       : '${checkin}',
    	    checkout      : '${checkout}',
    	    checkinLabel  : '${checkinLabel}',
    	    checkoutLabel : '${checkoutLabel}',
    	    nights        : '${nights}',
    	    rooms         : '${rooms}',
    	    adults        : '${adults}',
    	    children      : '${children}',
    	    basePrice     : '${basePrice}',
    	    totalPrice    : '${totalPrice}',
    	    // 숙박자 / 예약자 정보 (사용자 입력값)
    	    guestLastName  : document.getElementById('guestLastName').value,
    	    guestFirstName : document.getElementById('guestFirstName').value,
    	    guestPhone     : document.getElementById('guestPhone').value,
    	    bookerLastName : document.getElementById('bookerLastName').value,
    	    bookerFirstName: document.getElementById('bookerFirstName').value,
    	    bookerPhone    : document.getElementById('bookerPhone').value,
    	    bookerEmail    : document.getElementById('bookerEmail').value,
    	    postalCode     : document.getElementById('postalCode') ? document.getElementById('postalCode').value : '',
    	    address        : document.getElementById('address')   ? document.getElementById('address').value   : '',
    	    // 추가 옵션 / 결제
    	    breakfastYn   : state.selectedPlans.includes('breakfast')   ? 'Y' : 'N',
    	    fastCheckinYn : state.selectedPlans.includes('fastCheckin') ? 'Y' : 'N',
    	    paymentMethod : state.paymentMethod
    	  })
    	})
    	.then(res => res.json())
    	.then(data => {
    	  if (data.success) {
    	    window.location.href = 'reservationcomplete.jsp?no=' + data.reservationNo;
    	  } else {
    	    alert('예약 처리 중 오류가 발생했습니다: ' + data.message);
    	    state.isLoading = false;
    	    btn.disabled    = false;
    	    btn.innerHTML   = '예약하기';
    	  }
    	})
    	.catch(err => {
    	  alert('서버 연결 오류가 발생했습니다.');
    	  state.isLoading = false;
    	  btn.disabled    = false;
    	  btn.innerHTML   = '예약하기';
    	});
  }

  /* ── 페이지 로드 시 초기화 ── */

  // 조식 총 금액 계산 및 표시
  const totalGuests    = state.reservationData.adults + state.reservationData.children;
  const breakfastTotal = totalGuests * 25000 * state.reservationData.nights;
  document.getElementById('breakfast-total').textContent       = '+ ₩' + formatPrice(breakfastTotal);
  document.getElementById('price-breakfast-value').textContent = '₩'   + formatPrice(breakfastTotal);

  // 소계·합계 초기값 설정
  updateTotal();
  </script>
</body>
</html>
