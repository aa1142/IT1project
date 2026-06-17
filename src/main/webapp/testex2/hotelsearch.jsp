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
    if (request.getAttribute("companyList") != null) {
        companyList = (Vector<CompanyVO>) request.getAttribute("companyList");
    } else {
    	companyList = dao.selectActiveBranchList("");
    }

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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>호텔 예약 사이트</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Noto+Serif+KR:wght@300;400;600&family=Noto+Sans+KR:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link href="hotel-common.css" type="text/css" rel="stylesheet">
    <link href="sestyle.css?v=7" type="text/css" rel="stylesheet">
    <script type="text/javascript">
        var initRoomGrade = '<%= room_grade %>';
        var initCheckin = '<%= boot_checkin %>';
        var initCheckout = '<%= boot_checkout %>';
        var initNights = <%= nights %>;
        var initAdults = <%= boot_adult %>;
        var initChildren = <%= boot_child %>;
    </script>
    <script type="text/javascript" src="sescript.js?v=6"></script>
</head>
<body>
    <jsp:include page="siteNav.jsp" />

    <div class="lightbox-overlay" id="lightboxOverlay" onclick="closeLightbox()">
        <span class="lightbox-close" onclick="closeLightbox()">✕</span>
        <img class="lightbox-img" id="lightboxImg" src="" alt="" onclick="event.stopPropagation()">
    </div>

    <header>
        <h1>호텔 예약 사이트</h1>
        <p>호텔을 선택하고 방을 예약하세요</p>
    </header>

    <div class="main-container">
        <div class="sidebar-left">
            <h2>예약 검색</h2>

            <form method="post" action="searchProc.jsp" id="searchForm" onsubmit="return validateSearchForm()">
                <div class="hotel-search-section sidebar-section">
                    <h3>호텔 지점 선택</h3>
                    <div class="hotel-list">
                        <% if (companyList.isEmpty()) { %>
                            <div style="padding:12px;color:#71717a;text-align:center;font-size:13px;line-height:1.6;">
                                등록된 지점이 없습니다.<br>
                                <span style="font-size:12px;">proid 계정에 company 데이터가 있는지, Tomcat을 재시작했는지 확인해 주세요.</span>
                                <% if (!dbError.isEmpty()) { %>
                                <br><span style="font-size:11px;color:#b91c1c;margin-top:6px;display:inline-block;">DB 오류: <%= dbError %></span>
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
                                <span>🏨 <%= c.getRoom_type_count() %>가지 객실</span>
                            </div>
                        </label>
                        <%   }
                           } %>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>객실 등급</h3>
                    <input type="hidden" name="room_grade" id="room_grade" value="<%= room_grade %>">
                    <div class="room-class-selector">
                        <div class="room-class-buttons">
                            <button type="button" class="room-class-btn<%= "스탠다드".equals(room_grade)?" selected":"" %>" data-class="스탠다드" onclick="selectRoomClass('스탠다드')">스탠다드</button>
                            <button type="button" class="room-class-btn<%= "디럭스".equals(room_grade)?" selected":"" %>" data-class="디럭스" onclick="selectRoomClass('디럭스')">디럭스</button>
                            <button type="button" class="room-class-btn<%= "스위트".equals(room_grade)?" selected":"" %>" data-class="스위트" onclick="selectRoomClass('스위트')">스위트</button>
                        </div>
                    </div>
                </div>

                <div class="sidebar-section">
                    <h3>날짜 및 인원</h3>
                    <div class="form-group date-picker-container">
                        <label for="checkinDate">체크인 날짜</label>
                        <input type="text" name="boot_checkin" id="checkinDate" class="date-input" readonly value="<%= boot_checkin %>">
                        <div class="calendar" id="checkinCalendar"></div>
                    </div>
                    <div class="form-group">
                        <label>숙박 일수</label>
                        <div class="counter-input">
                            <button type="button" onclick="changeCount('nights',-1,1,30)">−</button>
                            <input type="number" name="nights" id="nights" value="<%= nights %>" min="1" max="30" readonly>
                            <button type="button" onclick="changeCount('nights',1,1,30)">+</button>
                        </div>
                    </div>
                    <div class="counter-group">
                        <div class="counter">
                            <label>성인</label>
                            <div class="counter-input">
                                <button type="button" onclick="changeCount('adults',-1,1,20)">−</button>
                                <input type="number" name="boot_adult" id="adults" value="<%= boot_adult %>" min="1" max="20" readonly>
                                <button type="button" onclick="changeCount('adults',1,1,20)">+</button>
                            </div>
                        </div>
                    </div>
                    <div class="counter-group">
                        <div class="counter">
                            <label>어린이</label>
                            <div class="counter-input">
                                <button type="button" onclick="changeCount('children',-1,0,20)">−</button>
                                <input type="number" name="boot_child" id="children" value="<%= boot_child %>" min="0" max="20" readonly>
                                <button type="button" onclick="changeCount('children',1,0,20)">+</button>
                            </div>
                        </div>
                    </div>
                    <div class="info-box">
                        <strong>예약 정보:</strong><br>
                        호텔: <span id="infoHotelName"><%= hotelNameInfo %></span><br>
                        체크인: <span id="infoCheckin"><%= boot_checkin.equals("")?"-":boot_checkin %></span><br>
                        체크아웃: <span id="infoCheckout"><%= boot_checkout.equals("")?"-":boot_checkout %></span><br>
                        숙박: <span id="infoNights"><%= nights %></span>박<br>
                        인원: 성인 <span id="infoAdults"><%= boot_adult %></span>명, 어린이 <span id="infoChildren"><%= boot_child %></span>명<br>
                        객실 등급: <span id="infoRoomClass"><%= room_grade %></span>
                    </div>
                    <div class="button-group">
                        <button type="submit" class="btn-search">검색</button>
                    </div>
                </div>
            </form>
        </div>

        <div class="content" id="mainContent">
            <% if ("Y".equals(searchDone) && selectedCompany != null) { %>
                <jsp:include page="searchResult.jsp" />
            <% } else if ("Y".equals(searchDone)) { %>
                <div class="no-results">DB에 호텔(company) 데이터가 없습니다. seed_data.sql 을 실행해 주세요.</div>
            <% } else { %>
                <div class="no-results">왼쪽에서 호텔 지점을 선택하고 검색하세요</div>
            <% } %>
        </div>
    </div>
</body>
</html>
