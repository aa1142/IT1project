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
    int boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    int boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);
    String boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);

    RoomVO room = dao.selectSingleRoomTypePriceInfo(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    CompanyVO company = dao.selectBranchDetailByNo(company_no);

    if (room == null || company == null) {
        response.sendRedirect("hotelsearch.jsp");
        return;
    }

    int guestCount = HotelPriceUtil.getGuestCount(boot_adult, boot_child);
    int roomTotal = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, boot_adult, boot_child);
    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.JAPAN);

    String sessionUserId = (String) session.getAttribute("sessionUserId");
    MemberVO member = null;
    if (sessionUserId != null) {
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
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JYP HOTEL | 予約</title>
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
        <span>ホテル選択</span><span class="arrow">→</span>
        <span>客室選択</span><span class="arrow">→</span>
        <span class="active">予約情報入力</span><span class="arrow">→</span>
        <span>予約完了</span>
      </div>
    </div>
  </header>

  <main>
    <form method="post" action="<%= request.getContextPath() %>/testex2/reservationProc" id="reserveForm"
          data-room-total="<%= roomTotal %>"
          data-breakfast-total="<%= breakfastTotal %>"
          data-fastcheckin-unit="<%= fastCheckinUnit %>"
          onsubmit="return submitReserveForm()">
      <input type="hidden" name="company_no" value="<%= company_no %>">
      <input type="hidden" name="room_type" value="<%= room_type %>">
      <input type="hidden" name="room_grade" value="<%= room_grade %>">
      <input type="hidden" name="boot_checkin" value="<%= boot_checkin %>">
      <input type="hidden" name="boot_checkout" value="<%= boot_checkout %>">
      <input type="hidden" name="nights" value="<%= nights %>">
      <input type="hidden" name="boot_adult" value="<%= boot_adult %>">
      <input type="hidden" name="boot_child" value="<%= boot_child %>">
      <input type="hidden" name="breakfast_yn" id="breakfast_yn" value="N">
      <input type="hidden" name="fast_checkin_yn" id="fast_checkin_yn" value="N">

      <div class="main-content">
        <div class="form-section">

          <div class="card">
            <div class="card-header">
              <div class="card-title">予約者情報</div>
            </div>
            <div class="card-content">
              <div class="checkbox-wrapper" style="margin-bottom:16px;">
                <input type="checkbox" id="loadMemberInfo" onchange="handleLoadMemberInfo()"<%= isLoggedIn ? "" : " disabled" %>>
                <label for="loadMemberInfo">会員情報を読み込む</label>
              </div>
              <% if (!isLoggedIn) { %>
              <p style="font-size:12px;color:#b45309;margin:-8px 0 12px;">ログイン後に会員情報を読み込めます。</p>
              <% } else if (!hasMemberData) { %>
              <p style="font-size:12px;color:#71717a;margin:-8px 0 12px;">保存された会員情報がありません。直接入力してください。</p>
              <% } %>
              <div class="form-row">
                <div class="form-group">
                  <label>姓 *</label>
                  <input type="text" id="booker_last_name" name="booker_last_name" placeholder="山田">
                </div>
                <div class="form-group">
                  <label>名 *</label>
                  <input type="text" id="booker_first_name" name="booker_first_name" placeholder="太郎">
                </div>
              </div>
              <div class="form-group">
                <label>電話番号 *</label>
                <input type="tel" id="boot_phone" name="boot_phone" placeholder="010-1234-5678">
              </div>
              <div class="form-group">
                <label>メールアドレス *</label>
                <input type="email" id="boot_email" name="boot_email" placeholder="example@email.com">
              </div>
              <div class="form-group">
                <label>メールアドレス（確認） *</label>
                <input type="email" id="boot_email_confirm" placeholder="メールアドレスを再入力">
              </div>
              <div class="form-group">
                <label>住所</label>
                <input type="text" id="member_address" name="member_address" placeholder="住所">
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">宿泊者情報</div>
            </div>
            <div class="card-content">
              <div class="checkbox-wrapper" style="margin-bottom:16px;">
                <input type="checkbox" id="sameAsBooker" onchange="handleSameAsBooker()">
                <label for="sameAsBooker">予約者と同じ</label>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label>姓 *</label>
                  <input type="text" id="guest_last_name" name="guest_last_name" placeholder="山田">
                </div>
                <div class="form-group">
                  <label>名 *</label>
                  <input type="text" id="guest_first_name" name="guest_first_name" placeholder="太郎">
                </div>
              </div>
              <div class="form-group">
                <label>電話番号 *</label>
                <input type="tel" id="guest_phone" name="guest_phone" placeholder="010-1234-5678">
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header"><div class="card-title">追加オプション</div></div>
            <div class="card-content">
              <button type="button" class="option-card" id="option-breakfast">
                <div class="option-card-content">
                  <div class="option-info">
                    <span class="option-title">朝食ビュッフェ</span>
                    <span class="option-unit-price">¥<%= breakfastUnit %> / 1名1泊</span>
                  </div>
                </div>
              </button>
              <div class="price-row" id="price-breakfast" style="display:none;">
                <span>+ ¥<%= nf.format(breakfastTotal) %></span>
              </div>
              <button type="button" class="option-card" id="option-fastCheckin">
                <div class="option-card-content">
                  <div class="option-info">
                    <span class="option-title">アーリーチェックイン</span>
                    <span class="option-unit-price">¥<%= fastCheckinUnit %> <span class="option-note">· 13時からチェックイン可能</span></span>
                  </div>
                </div>
              </button>
              <div class="price-row" id="price-fastCheckin" style="display:none;">
                <span>+ ¥<%= nf.format(fastCheckinUnit) %></span>
              </div>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">お支払い方法</div>
            </div>
            <div class="card-content">
              <label class="radio-card selected" id="payCardOnline">
                <input type="radio" name="payment_method" value="online" checked onchange="handlePaymentMethodChange()">
                <div class="radio-card-content">
                  <div class="radio-card-text">
                    <p>カカオペイ オンライン決済</p>
                    <p>決済完了後、予約が確定します。</p>
                  </div>
                </div>
              </label>
              <label class="radio-card" id="payCardOnsite">
                <input type="radio" name="payment_method" value="onsite" onchange="handlePaymentMethodChange()">
                <div class="radio-card-content">
                  <div class="radio-card-text">
                    <p>現地決済</p>
                    <p>チェックイン時にフロントでお支払いください。</p>
                  </div>
                </div>
              </label>
              <p class="payment-note" id="paymentNoteOnline">カカオペイ決済後、管理者が客室を割り当てると予約が最終確定されます。</p>
              <p class="payment-note" id="paymentNoteOnsite" style="display:none;">現地決済は予約申込のみ受付します。管理者確認・客室割当後、チェックイン時にお支払いください。</p>
            </div>
          </div>

          <div class="card">
            <div class="card-header">
              <div class="card-title">宿泊規約への同意</div>
            </div>
            <div class="card-content">
              <div class="terms-box">
                <p class="title">JYP HOTEL 宿泊規約</p>
                <p><strong>第1条（予約およびご利用）</strong></p>
                <ul>
                  <li>予約は大人1名以上の正確な情報で行う必要があり、予約者と実際の宿泊者の情報が異なる場合は事前にお知らせください。</li>
                  <li>チェックインは15:00から、チェックアウトは11:00までです。アーリーチェックインオプションを選択した場合は別途ご案内の時間に従ってご利用いただけます。</li>
                  <li>未成年者は法定代理人の同伴または同意なく単独での宿泊はできません。</li>
                </ul>
                <p><strong>第2条（料金およびお支払い）</strong></p>
                <ul>
                  <li>客室料金は選択した人数（大人・子供）、宿泊日数、客室数を基準に算出されます。</li>
                  <li>朝食などの追加オプションは選択時に案内された金額が総料金に含まれます。</li>
                  <li>現地での追加人数宿泊、延長宿泊、未申告オプションの利用時は追加料金が発生する場合があります。</li>
                </ul>
                <p><strong>第3条（予約変更およびキャンセル）</strong></p>
                <ul>
                  <li>予約の変更・キャンセルはマイページまたはカスタマーセンターを通じて申請できます。</li>
                  <li>キャンセル料は以下の基準に従います。</li>
                  <li>チェックイン7日前まで：無料キャンセル</li>
                  <li>チェックイン3〜6日前：宿泊料金の20%</li>
                  <li>チェックイン2日前：宿泊料金の50%</li>
                  <li>チェックイン前日・当日キャンセルおよびノーショー：宿泊料金の100%</li>
                </ul>
                <p><strong>第4条（宿泊者の義務）</strong></p>
                <ul>
                  <li>他の客室のお客様に迷惑をかける騒音、喫煙、同伴動物（介助動物を除く）の持ち込みは禁止です。</li>
                  <li>客室備品の破損・紛失時は実費が請求される場合があります。</li>
                  <li>ホテルは安全と秩序維持のため必要な場合、宿泊を制限または退去をお願いすることがあります。</li>
                </ul>
                <p><strong>第5条（個人情報の取扱い）</strong></p>
                <ul>
                  <li>収集した予約者・宿泊者情報は予約確認、お客様対応、宿泊サービス提供の目的にのみ使用されます。</li>
                  <li>関連法令に従い保管期間経過後は安全に破棄します。</li>
                </ul>
                <p><strong>第6条（免責およびその他）</strong></p>
                <ul>
                  <li>天災、施設点検、不可抗力によりサービス提供が困難な場合、ホテルはお客様に事前または事後にご案内いたします。</li>
                  <li>本規約に明記されていない事項は関連法令およびホテル運営方針に従います。</li>
                </ul>
              </div>
              <div class="checkbox-wrapper">
                <input type="checkbox" id="agreeTerms">
                <label for="agreeTerms">上記宿泊規約および個人情報処理方針に同意します。 <span style="color:#c00;">*</span></label>
              </div>
            </div>
          </div>
        </div>

        <div class="sidebar">
          <div class="sidebar-inner">
            <div class="card">
              <div class="sidebar-header"><h2>予約内容</h2></div>
              <div class="sidebar-info">
                <p><strong><%= company.getCompany_name() %></strong></p>
                <p><%= RoomTypeUtil.toUiGrade(room_grade) %> · <%= RoomTypeUtil.getDisplayName(room_grade, room_type) %></p>
                <p>チェックイン <%= boot_checkin %></p>
                <p>チェックアウト <%= boot_checkout %></p>
                <p><%= nights %>泊 · 大人 <%= boot_adult %> / 子供 <%= boot_child %></p>
              </div>
              <div class="card-content">
                <div class="price-row">
                  <span>客室料金 (<%= guestCount %>名 × <%= nights %>泊)</span>
                  <span id="roomPrice">¥<%= nf.format(roomTotal) %></span>
                </div>
                <div class="price-row" id="sidebar-breakfast" style="display:none;">
                  <span>朝食ビュッフェ (<%= guestCount %>名 × <%= nights %>泊)</span>
                  <span id="sidebarBreakfastPrice">¥<%= nf.format(breakfastTotal) %></span>
                </div>
                <div class="price-row" id="sidebar-fastCheckin" style="display:none;">
                  <span>アーリーチェックイン</span>
                  <span id="sidebarFastCheckinPrice">¥<%= nf.format(fastCheckinUnit) %></span>
                </div>
                <div class="separator"></div>
                <div class="price-total-row">
                  <span>合計</span>
                  <span class="value" id="reserveTotal">¥<%= nf.format(roomTotal) %></span>
                </div>
                <button type="submit" class="btn-primary" id="reserveBtn" style="margin-top:16px;">予約する</button>
                <p class="btn-note" id="reserveBtnNote" style="margin-top:8px;font-size:12px;color:#71717a;text-align:center;">カカオペイ決済画面へ移動します</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </form>
  </main>

  <script type="text/javascript" src="reservation.js?v=7"></script>
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