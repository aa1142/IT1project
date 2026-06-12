<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.jyphotel.*" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    request.setCharacterEncoding("UTF-8");

    int company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    int room_type = HotelPriceUtil.toInt(request.getParameter("room_type"), 0);
    String room_grade = RoomTypeUtil.toDbGrade(request.getParameter("room_grade"));
    String boot_checkin = request.getParameter("boot_checkin");
    if (boot_checkin == null) boot_checkin = "";
    int nights = HotelPriceUtil.toInt(request.getParameter("nights"), 1);
    int rooms = HotelPriceUtil.toInt(request.getParameter("rooms"), 1);
    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);
    String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

    // 🚨 [변경 1] getOneRoom -> selectSingleRoomTypePriceInfo 개명 반영
    RoomVO room = dao.selectSingleRoomTypePriceInfo(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    
    // 🚨 [변경 2] getCompany -> selectBranchDetailByNo 개명 반영
    CompanyVO company = dao.selectBranchDetailByNo(company_no);

    if (room == null || company == null) {
        response.sendRedirect("hotelsearch.jsp");
        return;
    }

    int guestCount = HotelPriceUtil.getGuestCount(boot_adult, boot_child);
    int roomTotal = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, rooms, boot_adult, boot_child);
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.KOREA);

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    MemberVO member = null;
    if (sessionUserId != null) {
        // 🚨 [변경 3] getMember -> selectClientProfile 개명 반영
        member = dao.selectClientProfile(sessionUserId);
    }

    boolean isLoggedIn = (sessionUserId != null);
    String sessionUserName = (String) session.getAttribute("sessionUserName");

    String mLast = "", mFirst = "", mPhone = "", mEmail = "", mAddr = "";
    if (member != null) {
        if (member.getMember_name() != null && member.getMember_name().length() >= 2) {
            mLast = member.getMember_name().substring(0, 1);
            mFirst = member.getMember_name().substring(1);
        } else if (member.getMember_name() != null) {
            mFirst = member.getMember_name();
        }
        if (member.getMember_phone() != null) {
            mPhone = HotelPriceUtil.normalizeBootPhone(member.getMember_phone());
        }
        if (member.getMember_email() != null) mEmail = member.getMember_email();
        if (member.getMember_address() != null) mAddr = member.getMember_address();
    } else if (isLoggedIn && sessionUserName != null && !sessionUserName.trim().isEmpty()) {
        String nm = sessionUserName.trim();
        if (nm.length() >= 2) {
            mLast = nm.substring(0, 1);
            mFirst = nm.substring(1);
        } else {
            mFirst = nm;
        }
    }

    boolean hasMemberData = member != null
            || (!mLast.isEmpty() || !mFirst.isEmpty() || !mPhone.isEmpty() || !mEmail.isEmpty());

    int breakfastUnit = HotelPriceUtil.BREAKFAST_UNIT;
    int fastCheckinUnit = HotelPriceUtil.FAST_CHECKIN_UNIT;
    int breakfastTotal = HotelPriceUtil.calcBreakfastTotal(boot_adult, boot_child, nights);

    String mLastJs = mLast.replace("\\", "\\\\").replace("'", "\\'");
    String mFirstJs = mFirst.replace("\\", "\\\\").replace("'", "\\'");
    String mPhoneJs = mPhone.replace("\\", "\\\\").replace("'", "\\'");
    String mEmailJs = mEmail.replace("\\", "\\\\").replace("'", "\\'");
    String mAddrJs = mAddr.replace("\\", "\\\\").replace("'", "\\'").replace("\r", " ").replace("\n", " ");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JYP 호텔 | 예약</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://unpkg.com/lucide@latest"></script>
  <link href="hotel-common.css" type="text/css" rel="stylesheet">
  <link href="restyle.css" type="text/css" rel="stylesheet">
</head>
<body>
  <jsp:include page="siteNav.jsp" />

  <header class="header">
    <div class="header-container">
      <div class="header-content">
        <div class="logo">
          <div class="logo-icon" style="font-weight:700;font-size:14px;">JYP</div>
          <div class="logo-text"><h1>JYP HOTEL</h1><p>Online Reservation</p></div>
        </div>
      </div>
    </div>
    <div class="progress-bar">
      <div class="progress-bar-content">
        <span>호텔 선택</span><span class="arrow">→</span>
        <span>객실 선택</span><span class="arrow">→</span>
        <span class="active">예약 정보 입력</span><span class="arrow">→</span>
        <span>예약 완료</span>
      </div>
    </div>
  </header>

  <main>
    <form method="post" action="reservationProc.jsp" id="reserveForm"
          data-room-total="<%= roomTotal %>"
          data-breakfast-total="<%= breakfastTotal %>"
          data-fastcheckin-unit="<%= fastCheckinUnit %>"
          onsubmit="return submitReserveForm()">
      <input type="hidden" name="company_no" value="<%= company_no %>">
      <input type="hidden" name="room_type" value="<%= room_type %>">
      <input type="hidden" name="room_grade" value="<%= room_grade %>">
      <input type="hidden" name="boot_checkin" value="<%= boot_checkin %>">
      <input type="hidden" name="nights" value="<%= nights %>">
      <input type="hidden" name="rooms" value="<%= rooms %>">
      <input type="hidden" name="boot_adult" value="<%= boot_adult %>">
      <input type="hidden" name="boot_child" value="<%= boot_child %>">
      <input type="hidden" name="breakfast_yn" id="breakfast_yn" value="N">
      <input type="hidden" name="fast_checkin_yn" id="fast_checkin_yn" value="N">

      <div class="main-content">
        <div class="form-section">

          <div class="card">
            <div class="card-header">
              <div class="card-title">예약자 정보</div>
            </div>
            <div class="card-content">
              <div class="checkbox-wrapper" style="margin-bottom:16px;">
                <input type="checkbox" id="loadMemberInfo" onchange="handleLoadMemberInfo()"<%= isLoggedIn ? "" : " disabled" %>>
                <label for="loadMemberInfo">회원 정보 불러오기</label>
              </div>
              <% if (!isLoggedIn) { %>
              <p style="font-size:12px;color:#b45309;margin:-8px 0 12px;">로그인 후 회원 정보를 불러올 수 있습니다.</p>
              <% } else if (!hasMemberData) { %>
              <p style="font-size:12px;color:#71717a;margin:-8px 0 12px;">저장된 회원 정보가 없습니다. 직접 입력해 주세요.</p>
              <% } %>
              <div class="form-row">
                <div class="form-group">
                  <label>성 *</label>
                  <input type="text" id="booker_last_name" name="booker_last_name" placeholder="홍">
                </div>
                <div class="form-group">
                  <label>이름 *</label>
                  <input type="text" id="booker_first_name" name="booker_first_name" placeholder="길동">
                </div>
              </div>
              <div class="form-group">
                <label>전화번호 *</label>
                <input type="tel" id="boot_phone" name="boot_phone" placeholder="010-1234-5678">
              </div>
              <div class="form-group">
                <label>이메일 *</label>
                <input type="email" id="boot_email" name="boot_email" placeholder="example@email.com">
              </div>
              <div class="form-group">
                <label>이메일 확인 *</label>
                <input type="email" id="boot_email_confirm" placeholder="이메일 재입력">
              </div>
              <div class="form-group">
                <label>주소</label>
                <input type="text" id="member_address" name="member_address" placeholder="주소">
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">숙박자 정보</div>
            </div>
            <div class="card-content">
              <div class="checkbox-wrapper" style="margin-bottom:16px;">
                <input type="checkbox" id="sameAsBooker" onchange="handleSameAsBooker()">
                <label for="sameAsBooker">예약자와 동일</label>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label>성 *</label>
                  <input type="text" id="guest_last_name" name="guest_last_name" placeholder="홍">
                </div>
                <div class="form-group">
                  <label>이름 *</label>
                  <input type="text" id="guest_first_name" name="guest_first_name" placeholder="길동">
                </div>
              </div>
              <div class="form-group">
                <label>전화번호 *</label>
                <input type="tel" id="guest_phone" name="guest_phone" placeholder="010-1234-5678">
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header"><div class="card-title">추가 옵션</div></div>
            <div class="card-content">
              <button type="button" class="option-card" id="option-breakfast">
                <div class="option-card-content">
                  <div class="option-info">
                    <span class="option-title">조식 뷔페</span>
                    <span class="option-unit-price">₩<%= breakfastUnit %> / 1인 1박</span>
                  </div>
                </div>
              </button>
              <div class="price-row" id="price-breakfast" style="display:none;">
                <span>+ ₩<%= nf.format(breakfastTotal) %></span>
              </div>
              <button type="button" class="option-card" id="option-fastCheckin">
                <div class="option-card-content">
                  <div class="option-info">
                    <span class="option-title">빠른 체크인</span>
                    <span class="option-unit-price">₩<%= fastCheckinUnit %> <span class="option-note">· 13시부터 체크인 가능</span></span>
                  </div>
                </div>
              </button>
              <div class="price-row" id="price-fastCheckin" style="display:none;">
                <span>+ ₩<%= nf.format(fastCheckinUnit) %></span>
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">결제 방법</div>
            </div>
            <div class="card-content">
              <label class="radio-card selected" id="payCardOnline">
                <input type="radio" name="payment_method" value="online" checked onchange="handlePaymentMethodChange()">
                <div class="radio-card-content">
                  <div class="radio-card-text">
                    <p>카카오페이 온라인 결제</p>
                    <p>결제 완료 후 예약이 확정됩니다.</p>
                  </div>
                </div>
              </label>
              <label class="radio-card" id="payCardOnsite">
                <input type="radio" name="payment_method" value="onsite" onchange="handlePaymentMethodChange()">
                <div class="radio-card-content">
                  <div class="radio-card-text">
                    <p>현장 결제</p>
                    <p>체크인 시 프론트에서 결제합니다.</p>
                  </div>
                </div>
              </label>
              <p class="payment-note" id="paymentNoteOnline">온라인 결제를 선택하면 카카오페이 결제 화면으로 이동합니다.</p>
              <p class="payment-note" id="paymentNoteOnsite" style="display:none;">현장 결제 예약은 예약 신청 후 예약이 확정이 나면 체크인 시 현장에서 결제합니다.</p>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">숙박 약관 동의</div>
            </div>
            <div class="card-content">
              <div class="terms-box">
                <p class="title">JYP HOTEL 숙박약관</p>
                <p><strong>제1조 (예약 및 이용)</strong></p>
                <ul>
                  <li>예약은 성인 1명 이상의 정확한 정보로 진행해야 하며, 예약자와 실제 투숙객 정보가 다를 경우 사전에 알려 주셔야 합니다.</li>
                  <li>체크인은 15:00부터, 체크아웃은 11:00까지입니다. 빠른 체크인 옵션을 선택한 경우 별도 안내 시간에 따라 이용 가능합니다.</li>
                  <li>미성년자는 법정대리인 동반 또는 동의 없이 단독 투숙할 수 없습니다.</li>
                </ul>
                <p><strong>제2조 (요금 및 결제)</strong></p>
                <ul>
                  <li>객실 요금은 선택한 인원(성인·어린이), 숙박 일수, 객실 수를 기준으로 산정됩니다.</li>
                  <li>조식 등 추가 옵션은 선택 시 안내된 금액이 총 요금에 포함됩니다.</li>
                  <li>현장에서 추가 인원 투숙, 연장 숙박, 미고지 옵션 이용 시 추가 요금이 발생할 수 있습니다.</li>
                </ul>
                <p><strong>제3조 (예약 변경 및 취소)</strong></p>
                <ul>
                  <li>예약 변경·취소는 마이페이지 또는 고객센터를 통해 신청할 수 있습니다.</li>
                  <li>취소 수수료는 아래 기준에 따릅니다.</li>
                  <li>체크인 7일 전까지: 무료 취소</li>
                  <li>체크인 3~6일 전: 숙박 요금의 20%</li>
                  <li>체크인 2일 전: 숙박 요금의 50%</li>
                  <li>체크인 전일·당일 취소 및 노쇼: 숙박 요금의 100%</li>
                </ul>
                <p><strong>제4조 (투숙객의 의무)</strong></p>
                <ul>
                  <li>타 객실 손님에게 피해를 주는 소음, 흡연, 반려동물 동반(안내 동물 제외)은 금지됩니다.</li>
                  <li>객실 비품 파손·분실 시 실비가 청구될 수 있습니다.</li>
                  <li>호텔은 안전과 질서 유지를 위해 필요한 경우 투숙을 제한하거나 퇴실을 요청할 수 있습니다.</li>
                </ul>
                <p><strong>제5조 (개인정보 처리)</strong></p>
                <ul>
                  <li>수집된 예약자·투숙객 정보는 예약 확인, 고객 응대, 숙박 서비스 제공 목적으로만 사용됩니다.</li>
                  <li>관련 법령에 따라 보관 기간 경과 후 안전하게 파기합니다.</li>
                </ul>
                <p><strong>제6조 (면책 및 기타)</strong></p>
                <ul>
                  <li>천재지변, 시설 점검, 불가항력 사유로 서비스 제공이 어려운 경우 호텔은 고객에게 사전 또는 사후 안내를 드립니다.</li>
                  <li>본 약관에 명시되지 않은 사항은 관련 법령 및 호텔 운영 정책을 따릅니다.</li>
                </ul>
              </div>
              <div class="checkbox-wrapper">
                <input type="checkbox" id="agreeTerms">
                <label for="agreeTerms">위 숙박약관 및 개인정보 처리방침에 동의합니다. <span style="color:#c00;">*</span></label>
              </div>
            </div>
          </div>
        </div>

        <div class="sidebar">
          <div class="sidebar-inner">
            <div class="card">
              <div class="sidebar-header"><h2>예약 내용</h2></div>
              <div class="sidebar-info">
                <p><strong><%= company.getCompany_name() %></strong></p>
                <p><%= RoomTypeUtil.toUiGrade(room_grade) %> · <%= RoomTypeUtil.getDisplayName(room_grade, room_type) %></p>
                <p>체크인 <%= boot_checkin %></p>
                <p>체크아웃 <%= boot_checkout %></p>
                <p><%= nights %>박 · 성인 <%= boot_adult %> / 어린이 <%= boot_child %></p>
              </div>
              <div class="card-content">
                <div class="price-row">
                  <span>객실 요금 (<%= guestCount %>인 × <%= nights %>박)</span>
                  <span id="roomPrice">₩<%= nf.format(roomTotal) %></span>
                </div>
                <div class="price-row" id="sidebar-breakfast" style="display:none;">
                  <span>조식 뷔페 (<%= guestCount %>인 × <%= nights %>박)</span>
                  <span id="sidebarBreakfastPrice">₩<%= nf.format(breakfastTotal) %></span>
                </div>
                <div class="price-row" id="sidebar-fastCheckin" style="display:none;">
                  <span>빠른 체크인</span>
                  <span id="sidebarFastCheckinPrice">₩<%= nf.format(fastCheckinUnit) %></span>
                </div>
                <div class="separator"></div>
                <div class="price-total-row">
                  <span>합계</span>
                  <span class="value" id="reserveTotal">₩<%= nf.format(roomTotal) %></span>
                </div>
                <button type="submit" class="btn-primary" id="reserveBtn" style="margin-top:16px;">예약하기</button>
                <p class="btn-note" id="reserveBtnNote" style="margin-top:8px;font-size:12px;color:#71717a;text-align:center;">카카오페이 결제 화면으로 이동합니다</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </form>
  </main>

  <script type="text/javascript" src="reservation.js?v=5"></script>
  <script>
  window.resConfig = {
    isLoggedIn: <%= isLoggedIn %>,
    hasMemberData: <%= hasMemberData %>,
    loginUrl: '<%= request.getContextPath() %>/wls/login.jsp',
    memberLastName: '<%= mLastJs %>',
    memberFirstName: '<%= mFirstJs %>',
    memberPhone: '<%= mPhoneJs %>',
    memberEmail: '<%= mEmailJs %>',
    memberAddress: '<%= mAddrJs %>'
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initReservationPage);
  } else {
    initReservationPage();
  }
  </script>
</body>
</html>