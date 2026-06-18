<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.jyphotel.CompanyVO" %>
<%@ page import="com.jyphotel.RoomVO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<%@ page import="com.jyphotel.RoomTypeUtil" %>
<jsp:useBean id="dao" class="com.jyphotel.HotelDAO" />
<%
    request.setCharacterEncoding("UTF-8");

    Vector<CompanyVO> companyList;

    int company_no = 0;
    if (request.getAttribute("company_no") != null) {
        company_no = (Integer) request.getAttribute("company_no");
    } else {
        company_no = HotelPriceUtil.toInt(request.getParameter("company_no"), 0);
    }

    String room_grade;
    if (request.getAttribute("room_grade") != null) {
        room_grade = (String) request.getAttribute("room_grade");
    } else {
        room_grade = request.getParameter("room_grade");
    }
    room_grade = RoomTypeUtil.normalizeUiGrade(room_grade);

    String boot_checkin = (String) request.getAttribute("boot_checkin");
    if (boot_checkin == null) boot_checkin = request.getParameter("boot_checkin");
    if (boot_checkin == null) boot_checkin = "";

    String boot_checkout = (String) request.getAttribute("boot_checkout");
    if (boot_checkout == null) boot_checkout = request.getParameter("boot_checkout");
    if (boot_checkout == null) boot_checkout = "";

    int nights = 1, boot_adult = 1, boot_child = 0;
    if (request.getAttribute("nights") != null) {
        nights = (Integer) request.getAttribute("nights");
    } else {
        nights = HotelPriceUtil.toInt(request.getParameter("nights"), 1);
    }
    if (request.getAttribute("boot_adult") != null) {
        boot_adult = (Integer) request.getAttribute("boot_adult");
    } else {
        boot_adult = HotelPriceUtil.toInt(request.getParameter("boot_adult"), 1);
    }
    if (request.getAttribute("boot_child") != null) {
        boot_child = (Integer) request.getAttribute("boot_child");
    } else {
        boot_child = HotelPriceUtil.toInt(request.getParameter("boot_child"), 0);
    }

    if (boot_checkout.equals("") && !boot_checkin.equals("")) {
        boot_checkout = HotelPriceUtil.calcCheckout(boot_checkin, nights);
    }

    if (request.getAttribute("companyList") != null) {
        companyList = (Vector<CompanyVO>) request.getAttribute("companyList");
    } else {
        String listCheckin = boot_checkin;
        String listCheckout = boot_checkout;
        if (listCheckin.equals("")) {
            listCheckin = java.time.LocalDate.now().format(
                    java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            listCheckout = HotelPriceUtil.calcCheckout(listCheckin, nights);
        }
        companyList = dao.selectActiveBranchList("", listCheckin, listCheckout, boot_adult, boot_child);
    }

    CompanyVO selectedCompany = (CompanyVO) request.getAttribute("company");
    String searchDone = (String) request.getAttribute("searchDone");

    if (!"Y".equals(searchDone) && "Y".equals(request.getParameter("autoSearch"))
            && company_no > 0 && !boot_checkin.equals("")) {
        selectedCompany = dao.selectBranchDetailByNo(company_no);
        if (selectedCompany == null && companyList.size() > 0) {
            for (int i = 0; i < companyList.size(); i++) {
                CompanyVO c = companyList.elementAt(i);
                if (c.getCompany_no() == company_no) {
                    selectedCompany = c;
                    break;
                }
            }
            if (selectedCompany == null) {
                selectedCompany = companyList.elementAt(0);
                company_no = selectedCompany.getCompany_no();
            }
        }
        if (selectedCompany != null) {
            Vector<RoomVO> roomList = dao.selectAvailableRoomTypeList(company_no, room_grade,
                    boot_checkin, boot_checkout, boot_adult, boot_child);
            searchDone = "Y";
            request.setAttribute("company", selectedCompany);
            request.setAttribute("roomList", roomList);
            request.setAttribute("searchDone", searchDone);
            request.setAttribute("company_no", company_no);
            request.setAttribute("room_grade", room_grade);
            request.setAttribute("boot_checkin", boot_checkin);
            request.setAttribute("boot_checkout", boot_checkout);
            request.setAttribute("nights", nights);
            request.setAttribute("boot_adult", boot_adult);
            request.setAttribute("boot_child", boot_child);
        }
    }

    String hotelNameInfo = "-";
    if (selectedCompany != null) {
        hotelNameInfo = selectedCompany.getCompany_name();
    }

    String dbError = dao.getLastDbError();
    if (dbError == null) dbError = "";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ホテル予約 | JYP HOTEL</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Noto+Serif+KR:wght@300;400;600&family=Noto+Sans+KR:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="hotel-common.css" type="text/css" rel="stylesheet">
    <link href="sestyle.css?v=8" type="text/css" rel="stylesheet">
    <script type="text/javascript">
        var initRoomGrade = '<%= room_grade %>';
        var initCheckin = '<%= boot_checkin %>';
        var initCheckout = '<%= boot_checkout %>';
        var initNights = <%= nights %>;
        var initAdults = <%= boot_adult %>;
        var initChildren = <%= boot_child %>;
    </script>
</head>
<body>
    <jsp:include page="siteNav.jsp" />

    <div class="lightbox-overlay" id="lightboxOverlay" onclick="closeLightbox()">
        <span class="lightbox-close" onclick="closeLightbox()">✕</span>
        <img class="lightbox-img" id="lightboxImg" src="" alt="" onclick="event.stopPropagation()">
    </div>

    <header>
        <h1>ホテル予約</h1>
        <p>ホテルを選んで客室をご予約ください</p>
    </header>

    <div class="main-container">
        <div class="sidebar-left">
            <h2>予約検索</h2>

            <form method="post" action="searchProc.jsp" id="searchForm" onsubmit="return validateSearchForm()">
                <div class="hotel-search-section sidebar-section">
                    <h3>ホテル支店選択</h3>
                    <div class="hotel-list">
                        <% if (companyList.isEmpty()) { %>
                            <div style="padding:12px;color:#71717a;text-align:center;font-size:13px;line-height:1.6;">
                                登録された支店がありません。<br>
                                <span style="font-size:12px;">proidアカウントにcompanyデータがあるか、Tomcatを再起動したかご確認ください。</span>
                                <% if (!dbError.isEmpty()) { %>
                                <br><span style="font-size:11px;color:#b91c1c;margin-top:6px;display:inline-block;">DBエラー: <%= dbError %></span>
                                <% } %>
                            </div>
                        <% } else {
                            for (int i = 0; i < companyList.size(); i++) {
                                CompanyVO c = companyList.get(i);
                                int cno = c.getCompany_no();
                                boolean checked = (cno == company_no);
                                if (company_no == 0 && i == 0) checked = true;
                        %>
                        <label class="hotel-option<%= checked ? " selected" : "" %>" style="display:block;cursor:pointer;">
                            <input type="radio" name="company_no" value="<%= cno %>"<%= checked ? " checked" : "" %>
                                   style="display:none;" onchange="selectCompanyRadio(this)">
                            <div class="hotel-option-name"><%= c.getCompany_name() %></div>
                            <div class="hotel-option-info">
                                <span>⭐ <%= String.format("%.1f", c.getRating()) %>/5.0</span>
                                <span>🏨 <%= c.getRoom_type_count() %>タイプの客室</span>
                            </div>
                        </label>
                        <%   }
                           } %>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>客室グレード</h3>
                    <input type="hidden" name="room_grade" id="room_grade" value="<%= room_grade %>">
                    <div class="room-class-selector">
                        <div class="room-class-buttons">
                            <button type="button" class="room-class-btn<%= "STANDARD".equals(room_grade)?" selected":"" %>" data-class="STANDARD" onclick="selectRoomClass('STANDARD')">STANDARD</button>
                            <button type="button" class="room-class-btn<%= "DELUXE".equals(room_grade)?" selected":"" %>" data-class="DELUXE" onclick="selectRoomClass('DELUXE')">DELUXE</button>
                            <button type="button" class="room-class-btn<%= "SUITE".equals(room_grade)?" selected":"" %>" data-class="SUITE" onclick="selectRoomClass('SUITE')">SUITE</button>
                        </div>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>日程・人数</h3>
                    <div class="form-group date-picker-container">
                        <label for="checkinDate">チェックイン日</label>
                        <input type="text" name="boot_checkin" id="checkinDate" class="date-input" readonly value="<%= boot_checkin %>">
                        <div class="calendar" id="checkinCalendar"></div>
                    </div>
                    <div class="form-group">
                        <label>宿泊日数</label>
                        <div class="counter-input">
                            <button type="button" onclick="changeCount('nights',-1,1,30)">−</button>
                            <input type="number" name="nights" id="nights" value="<%= nights %>" min="1" max="30" readonly>
                            <button type="button" onclick="changeCount('nights',1,1,30)">+</button>
                        </div>
                    </div>
                    <div class="counter-group">
                        <div class="counter">
                            <label>大人</label>
                            <div class="counter-input">
                                <button type="button" onclick="changeCount('adults',-1,1,20)">−</button>
                                <input type="number" name="boot_adult" id="adults" value="<%= boot_adult %>" min="1" max="20" readonly>
                                <button type="button" onclick="changeCount('adults',1,1,20)">+</button>
                            </div>
                        </div>
                    </div>
                    <div class="counter-group">
                        <div class="counter">
                            <label>子供</label>
                            <div class="counter-input">
                                <button type="button" onclick="changeCount('children',-1,0,20)">−</button>
                                <input type="number" name="boot_child" id="children" value="<%= boot_child %>" min="0" max="20" readonly>
                                <button type="button" onclick="changeCount('children',1,0,20)">+</button>
                            </div>
                        </div>
                    </div>
                    <div class="info-box">
                        <strong>予約情報:</strong><br>
                        ホテル: <span id="infoHotelName"><%= hotelNameInfo %></span><br>
                        チェックイン: <span id="infoCheckin"><%= boot_checkin.equals("")?"-":boot_checkin %></span><br>
                        チェックアウト: <span id="infoCheckout"><%= boot_checkout.equals("")?"-":boot_checkout %></span><br>
                        宿泊: <span id="infoNights"><%= nights %></span>泊<br>
                        人数: 大人 <span id="infoAdults"><%= boot_adult %></span>名、子供 <span id="infoChildren"><%= boot_child %></span>名<br>
                        客室グレード: <span id="infoRoomClass"><%= room_grade %></span>
                    </div>
                    <div class="button-group">
                        <button type="submit" class="btn-search">検索</button>
                    </div>
                </div>
            </form>
        </div>

        <div class="content" id="mainContent">
            <% if ("Y".equals(searchDone) && selectedCompany != null) { %>
                <jsp:include page="searchResult.jsp" />
            <% } else if ("Y".equals(searchDone)) { %>
                <div class="no-results">DBにホテル(company)データがありません。seed_data.sql を実行してください。</div>
            <% } else { %>
                <div class="no-results">左側でホテル支店を選んで検索してください</div>
            <% } %>
        </div>
    </div>
    <script type="text/javascript" src="sescript.js?v=8"></script>
</body>
</html>
