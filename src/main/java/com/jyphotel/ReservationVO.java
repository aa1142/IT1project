package com.jyphotel;

/**
 * =====================================================================
 * ReservationVO.java  —  호텔 예약 데이터 전송 객체 (Value Object)
 * =====================================================================
 * hotelreservation.jsp 의 폼 데이터 + 추가 옵션 + 결제 정보를
 * 하나의 객체로 묶어 DAO 계층으로 전달합니다.
 *
 * [매핑 출처]
 *   - 호텔/객실 정보 : hotelsearch.jsp → hotelreservation.jsp (POST 파라미터)
 *   - 숙박자/예약자  : hotelreservation.jsp 폼 입력
 *   - 추가 옵션/결제 : JS toggleOption() / selectPayment() 선택값
 * =====================================================================
 */
public class ReservationVO {

    /* ═══════════════════════════════════════════
       1. 예약 식별 정보
    ═══════════════════════════════════════════ */

    /** 예약 고유 번호 (DB 자동 생성 — INSERT 후 채워짐) */
    private int    reservationNo;

    /** 예약 상태 (PENDING / CONFIRMED / CANCELLED) */
    private String reservationStatus;

    /** 예약 생성 일시 (DB DEFAULT SYSDATE) */
    private java.sql.Timestamp createdAt;


    /* ═══════════════════════════════════════════
       2. 호텔 / 객실 정보
         출처: POST 파라미터 hotelName, roomGrade ...
    ═══════════════════════════════════════════ */

    /** 호텔 지점명  (예: JYP 호텔 서울) */
    private String hotelName;

    /** 객실 등급명  (예: 트윈 베드룸) */
    private String roomGrade;

    /** 객실 클래스  (스탠다드 / 디럭스 / 스위트) */
    private String roomClass;

    /** 최대 수용 인원 문자열  (예: 최대 2인) */
    private String capacity;


    /* ═══════════════════════════════════════════
       3. 체크인 / 체크아웃 날짜
    ═══════════════════════════════════════════ */

    /** 체크인 날짜  YYYY-MM-DD */
    private String checkin;

    /** 체크아웃 날짜 YYYY-MM-DD */
    private String checkout;

    /** 체크인 한국어 표시  (예: 2026년 6월 10일) */
    private String checkinLabel;

    /** 체크아웃 한국어 표시 */
    private String checkoutLabel;

    /** 숙박 일수 */
    private int nights;

    /** 방 수 */
    private int rooms;


    /* ═══════════════════════════════════════════
       4. 인원 / 요금
    ═══════════════════════════════════════════ */

    /** 성인 수 */
    private int adults;

    /** 어린이 수 */
    private int children;

    /** 1박 단가 (원) */
    private int basePrice;

    /** 객실 총 요금 = basePrice × nights (원) */
    private int totalPrice;


    /* ═══════════════════════════════════════════
       5. 숙박자 정보
         출처: id="guestLastName" / guestFirstName / guestPhone
    ═══════════════════════════════════════════ */

    /** 숙박자 성 */
    private String guestLastName;

    /** 숙박자 이름 */
    private String guestFirstName;

    /** 숙박자 전화번호 */
    private String guestPhone;


    /* ═══════════════════════════════════════════
       6. 예약자 정보
         출처: id="bookerLastName" / bookerFirstName / bookerPhone
               bookerEmail / postalCode / address
    ═══════════════════════════════════════════ */

    /** 예약자 성 */
    private String bookerLastName;

    /** 예약자 이름 */
    private String bookerFirstName;

    /** 예약자 전화번호 */
    private String bookerPhone;

    /** 예약자 이메일 */
    private String bookerEmail;

    /** 우편번호 */
    private String postalCode;

    /** 상세 주소 */
    private String address;


    /* ═══════════════════════════════════════════
       7. 추가 옵션
         출처: JS toggleOption('breakfast') / toggleOption('fastCheckin')
    ═══════════════════════════════════════════ */

    /** 조식 옵션 선택 여부 (Y / N) */
    private String breakfastYn;

    /** 조식 요금 = 총인원 × 25,000 × nights */
    private int breakfastPrice;

    /** 빠른 체크인 선택 여부 (Y / N) */
    private String fastCheckinYn;

    /** 빠른 체크인 요금 (고정 10,000원) */
    private int fastCheckinPrice;


    /* ═══════════════════════════════════════════
       8. 결제 정보
         출처: JS selectPayment('card' | 'onsite')
    ═══════════════════════════════════════════ */

    /** 결제 방법  (card: 온라인결제 / onsite: 현장결제) */
    private String paymentMethod;

    /** 최종 결제 금액 = totalPrice + breakfastPrice + fastCheckinPrice */
    private int finalPrice;


    /* ═══════════════════════════════════════════
       기본 생성자
    ═══════════════════════════════════════════ */
    public ReservationVO() {}


    /* ═══════════════════════════════════════════
       전체 필드 생성자 (필요 시 사용)
    ═══════════════════════════════════════════ */
    public ReservationVO(
            String hotelName,   String roomGrade,     String roomClass,
            String capacity,    String checkin,       String checkout,
            String checkinLabel,String checkoutLabel,
            int    nights,      int    rooms,
            int    adults,      int    children,
            int    basePrice,   int    totalPrice,
            String guestLastName,  String guestFirstName, String guestPhone,
            String bookerLastName, String bookerFirstName,String bookerPhone,
            String bookerEmail,    String postalCode,     String address,
            String breakfastYn,    int    breakfastPrice,
            String fastCheckinYn,  int    fastCheckinPrice,
            String paymentMethod,  int    finalPrice) {

        this.hotelName       = hotelName;
        this.roomGrade       = roomGrade;
        this.roomClass       = roomClass;
        this.capacity        = capacity;
        this.checkin         = checkin;
        this.checkout        = checkout;
        this.checkinLabel    = checkinLabel;
        this.checkoutLabel   = checkoutLabel;
        this.nights          = nights;
        this.rooms           = rooms;
        this.adults          = adults;
        this.children        = children;
        this.basePrice       = basePrice;
        this.totalPrice      = totalPrice;
        this.guestLastName   = guestLastName;
        this.guestFirstName  = guestFirstName;
        this.guestPhone      = guestPhone;
        this.bookerLastName  = bookerLastName;
        this.bookerFirstName = bookerFirstName;
        this.bookerPhone     = bookerPhone;
        this.bookerEmail     = bookerEmail;
        this.postalCode      = postalCode;
        this.address         = address;
        this.breakfastYn     = breakfastYn;
        this.breakfastPrice  = breakfastPrice;
        this.fastCheckinYn   = fastCheckinYn;
        this.fastCheckinPrice= fastCheckinPrice;
        this.paymentMethod   = paymentMethod;
        this.finalPrice      = finalPrice;
    }


    /* ═══════════════════════════════════════════
       Getters & Setters
    ═══════════════════════════════════════════ */

    public int getReservationNo()                    { return reservationNo; }
    public void setReservationNo(int v)              { this.reservationNo = v; }

    public String getReservationStatus()             { return reservationStatus; }
    public void setReservationStatus(String v)       { this.reservationStatus = v; }

    public java.sql.Timestamp getCreatedAt()         { return createdAt; }
    public void setCreatedAt(java.sql.Timestamp v)   { this.createdAt = v; }

    public String getHotelName()                     { return hotelName; }
    public void setHotelName(String v)               { this.hotelName = v; }

    public String getRoomGrade()                     { return roomGrade; }
    public void setRoomGrade(String v)               { this.roomGrade = v; }

    public String getRoomClass()                     { return roomClass; }
    public void setRoomClass(String v)               { this.roomClass = v; }

    public String getCapacity()                      { return capacity; }
    public void setCapacity(String v)                { this.capacity = v; }

    public String getCheckin()                       { return checkin; }
    public void setCheckin(String v)                 { this.checkin = v; }

    public String getCheckout()                      { return checkout; }
    public void setCheckout(String v)                { this.checkout = v; }

    public String getCheckinLabel()                  { return checkinLabel; }
    public void setCheckinLabel(String v)            { this.checkinLabel = v; }

    public String getCheckoutLabel()                 { return checkoutLabel; }
    public void setCheckoutLabel(String v)           { this.checkoutLabel = v; }

    public int getNights()                           { return nights; }
    public void setNights(int v)                     { this.nights = v; }

    public int getRooms()                            { return rooms; }
    public void setRooms(int v)                      { this.rooms = v; }

    public int getAdults()                           { return adults; }
    public void setAdults(int v)                     { this.adults = v; }

    public int getChildren()                         { return children; }
    public void setChildren(int v)                   { this.children = v; }

    public int getBasePrice()                        { return basePrice; }
    public void setBasePrice(int v)                  { this.basePrice = v; }

    public int getTotalPrice()                       { return totalPrice; }
    public void setTotalPrice(int v)                 { this.totalPrice = v; }

    public String getGuestLastName()                 { return guestLastName; }
    public void setGuestLastName(String v)           { this.guestLastName = v; }

    public String getGuestFirstName()                { return guestFirstName; }
    public void setGuestFirstName(String v)          { this.guestFirstName = v; }

    public String getGuestPhone()                    { return guestPhone; }
    public void setGuestPhone(String v)              { this.guestPhone = v; }

    public String getBookerLastName()                { return bookerLastName; }
    public void setBookerLastName(String v)          { this.bookerLastName = v; }

    public String getBookerFirstName()               { return bookerFirstName; }
    public void setBookerFirstName(String v)         { this.bookerFirstName = v; }

    public String getBookerPhone()                   { return bookerPhone; }
    public void setBookerPhone(String v)             { this.bookerPhone = v; }

    public String getBookerEmail()                   { return bookerEmail; }
    public void setBookerEmail(String v)             { this.bookerEmail = v; }

    public String getPostalCode()                    { return postalCode; }
    public void setPostalCode(String v)              { this.postalCode = v; }

    public String getAddress()                       { return address; }
    public void setAddress(String v)                 { this.address = v; }

    public String getBreakfastYn()                   { return breakfastYn; }
    public void setBreakfastYn(String v)             { this.breakfastYn = v; }

    public int getBreakfastPrice()                   { return breakfastPrice; }
    public void setBreakfastPrice(int v)             { this.breakfastPrice = v; }

    public String getFastCheckinYn()                 { return fastCheckinYn; }
    public void setFastCheckinYn(String v)           { this.fastCheckinYn = v; }

    public int getFastCheckinPrice()                 { return fastCheckinPrice; }
    public void setFastCheckinPrice(int v)           { this.fastCheckinPrice = v; }

    public String getPaymentMethod()                 { return paymentMethod; }
    public void setPaymentMethod(String v)           { this.paymentMethod = v; }

    public int getFinalPrice()                       { return finalPrice; }
    public void setFinalPrice(int v)                 { this.finalPrice = v; }


    /* ═══════════════════════════════════════════
       편의 메서드
    ═══════════════════════════════════════════ */

    /** 숙박자 전체 이름 (성 + 이름) */
    public String getGuestFullName() {
        return (guestLastName != null ? guestLastName : "")
             + (guestFirstName != null ? guestFirstName : "");
    }

    /** 예약자 전체 이름 (성 + 이름) */
    public String getBookerFullName() {
        return (bookerLastName != null ? bookerLastName : "")
             + (bookerFirstName != null ? bookerFirstName : "");
    }

    /**
     * 최종 결제 금액 자동 계산
     *   finalPrice = totalPrice + breakfastPrice + fastCheckinPrice
     */
    public void calcFinalPrice() {
        this.finalPrice = this.totalPrice + this.breakfastPrice + this.fastCheckinPrice;
    }

    @Override
    public String toString() {
        return "ReservationVO{" +
               "reservationNo="    + reservationNo    +
               ", hotelName='"     + hotelName        + '\'' +
               ", roomGrade='"     + roomGrade        + '\'' +
               ", checkin='"       + checkin          + '\'' +
               ", checkout='"      + checkout         + '\'' +
               ", nights="         + nights           +
               ", adults="         + adults           +
               ", children="       + children         +
               ", basePrice="      + basePrice        +
               ", finalPrice="     + finalPrice       +
               ", guestFullName='" + getGuestFullName()+ '\'' +
               ", bookerEmail='"   + bookerEmail      + '\'' +
               ", paymentMethod='" + paymentMethod    + '\'' +
               ", status='"        + reservationStatus+ '\'' +
               '}';
    }
}