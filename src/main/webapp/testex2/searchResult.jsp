<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector" %>
<%@ page import="com.jyphotel.CompanyVO" %>
<%@ page import="com.jyphotel.RoomVO" %>
<%@ page import="com.jyphotel.HotelPriceUtil" %>
<%@ page import="com.jyphotel.RoomTypeUtil" %>
<%@ page import="com.jyphotel.HotelDisplay" %>

<%
    CompanyVO company = (CompanyVO) request.getAttribute("company");
    Vector<RoomVO> roomList = (Vector<RoomVO>) request.getAttribute("roomList");

    if (company == null) {
        return;
    }

    int nights = 1, boot_adult = 1, boot_child = 0;
    if (request.getAttribute("nights") != null) nights = (Integer) request.getAttribute("nights");
    if (request.getAttribute("boot_adult") != null) boot_adult = (Integer) request.getAttribute("boot_adult");
    if (request.getAttribute("boot_child") != null) boot_child = (Integer) request.getAttribute("boot_child");

    String boot_checkin = (String) request.getAttribute("boot_checkin");
    if (boot_checkin == null) boot_checkin = "";
    String boot_checkout = (String) request.getAttribute("boot_checkout");
    if (boot_checkout == null) boot_checkout = "";
    String room_grade = RoomTypeUtil.normalizeUiGrade((String) request.getAttribute("room_grade"));

    java.text.NumberFormat nf = java.text.NumberFormat.getNumberInstance(java.util.Locale.KOREA);
    String ctx = request.getContextPath();
    String[] hotelImages = HotelDisplay.getHotelGalleryPaths(company);
%>
<div id="resultsContainer">
    <div class="results-header"><h2>예약 정보</h2></div>
    <div id="results">

        <div class="hotel-detail-card">
            <div class="detail-title"><%= company.getCompany_name() %></div>
            <div class="detail-header-section">
                <% if (hotelImages.length > 0) {
                    String hotelMainUrl = HotelDisplay.toUrl(ctx, hotelImages[0]);
                    String galleryId = "hotel-gallery-" + company.getCompany_no();
                %>
                <div class="hotel-gallery" id="<%= galleryId %>"
                     data-alt="<%= company.getCompany_name() %>">
                    <button type="button" class="hotel-photo-wrap hotel-gallery-main"
                            title="호텔 사진 크게 보기">
                        <img class="hotel-gallery-img" src="<%= hotelMainUrl %>"
                             alt="<%= company.getCompany_name() %>">
                    </button>
                    <div class="hotel-gallery-thumbs">
                        <% for (int hi = 0; hi < hotelImages.length; hi++) {
                            String thumbUrl = HotelDisplay.toUrl(ctx, hotelImages[hi]);
                        %>
                        <button type="button"
                                class="hotel-gallery-thumb<%= hi == 0 ? " active" : "" %>"
                                data-src="<%= thumbUrl %>"
                                title="사진 <%= hi + 1 %>">
                            <img src="<%= thumbUrl %>" alt="<%= company.getCompany_name() %> <%= hi + 1 %>">
                        </button>
                        <% } %>
                    </div>
                </div>
                <% } %>
                <div class="detail-info">
                    <div class="detail-section">
                        <div class="section-label">위치</div>
                        <div class="section-content"><%= company.getLocation() %></div>
                    </div>
                    <div class="detail-section">
                        <div class="section-label">호텔 특징</div>
                        <div class="section-content expandable" id="feat-<%= company.getCompany_no() %>">
                            <p><%= company.getFeature() %></p>
                        </div>
                        <div class="expand-btn" onclick="toggleExpand('feat-<%= company.getCompany_no() %>')">더보기 ▼</div>
                    </div>
                    <div class="detail-section">
                        <div class="section-label">식사 안내</div>
                        <div class="section-content"><%= company.getMeal_info() %></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="rooms-section">
            <div class="rooms-section-title">객실 선택 — <%= room_grade %> 등급</div>

            <% if (roomList == null || roomList.isEmpty()) { %>
                <div class="no-results" style="padding:16px;">선택한 조건에 맞는 객실이 없습니다.</div>
            <% } else {
                for (int i = 0; i < roomList.size(); i++) {
                    RoomVO room = roomList.get(i);
                    int total = HotelPriceUtil.calcRoomTotal(room.getRoom_price(), nights, boot_adult, boot_child);
                    String[] roomImages = HotelDisplay.getRoomImagePaths(
                            room.getCompany_no(), room.getRoom_grade(), room.getRoom_type());
                    String carouselId = "room-carousel-" + i;
                    String firstRoomImg = roomImages.length > 0
                            ? HotelDisplay.toUrl(ctx, roomImages[0]) : "";
                    StringBuilder imagesJson = new StringBuilder("[");
                    for (int ri = 0; ri < roomImages.length; ri++) {
                        if (ri > 0) imagesJson.append(",");
                        String url = HotelDisplay.toUrl(ctx, roomImages[ri]);
                        imagesJson.append("\"").append(url.replace("\\", "\\\\").replace("\"", "\\\"")).append("\"");
                    }
                    imagesJson.append("]");
            %>
            <div class="room-type-container">
                <div class="room-type-content">
                    <div class="room-left">
                        <div class="room-grade"><%= room.getRoom_type_name() %></div>
                        <div class="room-features">
                            <span class="feature-tag room-class"><%= room.getRoom_grade_ui() %></span>
                            <span class="feature-tag"><%= room.getRoom_type_name() %></span>
                        </div>
                        <% if (roomImages.length == 0) { %>
                        <div class="room-carousel-placeholder">사진 준비중</div>
                        <% } else { %>
                        <div class="img-carousel room-carousel" id="<%= carouselId %>"
                             data-images='<%= imagesJson.toString() %>'
                             data-alt="<%= room.getRoom_type_name() %>">
                            <button type="button" class="carousel-btn carousel-prev" aria-label="이전 사진">&#8249;</button>
                            <div class="carousel-main">
                                <img class="carousel-img" src="<%= firstRoomImg %>" alt="<%= room.getRoom_type_name() %>">
                                <span class="carousel-counter">1 / <%= roomImages.length %></span>
                            </div>
                            <button type="button" class="carousel-btn carousel-next" aria-label="다음 사진">&#8250;</button>
                        </div>
                        <% } %>
                    </div>
                    <div class="room-right">
                        <div class="room-description">
                            <%= room.getRoom_grade_ui() %> <%= room.getRoom_type_name() %> · 1인 1박 <%= nf.format(room.getRoom_price()) %>원
                        </div>
                        <div class="room-pricing">
                            <div class="room-price-item">
                                <div class="room-type-label"><%= room.getRoom_type_name() %> · <%= room.getCapacity_label() %></div>
                                <div class="price-display">
                                    <span class="price-amount">₩<%= nf.format(total) %></span>
                                    <span class="price-unit">원</span>
                                </div>
                                <div class="remaining">잔여 <%= room.getRemain_count() %>개</div>
                                <form method="post" action="hotelreservation.jsp" style="margin:0;">
                                    <input type="hidden" name="company_no" value="<%= room.getCompany_no() %>">
                                    <input type="hidden" name="room_type" value="<%= room.getRoom_type() %>">
                                    <input type="hidden" name="room_grade" value="<%= room.getRoom_grade() %>">
                                    <input type="hidden" name="boot_checkin" value="<%= boot_checkin %>">
                                    <input type="hidden" name="boot_checkout" value="<%= boot_checkout %>">
                                    <input type="hidden" name="nights" value="<%= nights %>">
                                    <input type="hidden" name="boot_adult" value="<%= boot_adult %>">
                                    <input type="hidden" name="boot_child" value="<%= boot_child %>">
                                    <button type="submit" class="btn-book-room">예약하기</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%   }
               } %>
        </div>
    </div>
</div>
