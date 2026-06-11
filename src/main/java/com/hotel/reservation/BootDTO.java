package com.hotel.reservation;

public class BootDTO {
	// 1. 새 BOOT 테이블 컬럼 매핑 멤버 변수 (CamelCase 적용)
	private String bootNo; // BOOT_NO (VARCHAR2, PK)
	private String roomGrade; // ROOM_GRADE (VARCHAR2)
	private int roomType; // ROOM_TYPE (NUMBER)
	private int roomNo; // ROOM_NO (NUMBER)
	private int companyNo; // COMPANY_NO (NUMBER)
	private String memberId; // MEMBER_ID (VARCHAR2)
	private String bootPhone; // BOOT_PHONE (VARCHAR2)
	private String bootName; // BOOT_NAME (VARCHAR2)
	private String bootEmail; // BOOT_EMAIL (VARCHAR2)
	private String bootCheckin; // BOOT_CHECKIN (DATE/String)
	private String bootCheckout; // BOOT_CHECKOUT (DATE/String)
	private int bootAdult; // BOOT_ADULT (NUMBER)
	private int bootChild; // BOOT_CHILD (NUMBER)
	private int bootPayCheck; // BOOT_PAY_CHECK (NUMBER, 기존 totalAmount 역할)
	private String bootPlease; // BOOT_PLEASE (VARCHAR2)
	private int bootConfirm; // BOOT_CONFIRM (NUMBER, 기존 reservationStatus 역할 / 0:대기, 1:완료)
	private String reservationCode; // RESERVATION_CODE (VARCHAR2, 카카오페이 통신용)

	// 기본 생성자
	public BootDTO() {
	}

	// 2. Getter / Setter 메소드 정의
	public String getBootNo() {
		return bootNo;
	}

	public void setBootNo(String bootNo) {
		this.bootNo = bootNo;
	}

	public String getRoomGrade() {
		return roomGrade;
	}

	public void setRoomGrade(String roomGrade) {
		this.roomGrade = roomGrade;
	}

	public int getRoomType() {
		return roomType;
	}

	public void setRoomType(int roomType) {
		this.roomType = roomType;
	}

	public int getRoomNo() {
		return roomNo;
	}

	public void setRoomNo(int roomNo) {
		this.roomNo = roomNo;
	}

	public int getCompanyNo() {
		return companyNo;
	}

	public void setCompanyNo(int companyNo) {
		this.companyNo = companyNo;
	}

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public String getBootPhone() {
		return bootPhone;
	}

	public void setBootPhone(String bootPhone) {
		this.bootPhone = bootPhone;
	}

	public String getBootName() {
		return bootName;
	}

	public void setBootName(String bootName) {
		this.bootName = bootName;
	}

	public String getBootEmail() {
		return bootEmail;
	}

	public void setBootEmail(String bootEmail) {
		this.bootEmail = bootEmail;
	}

	public String getBootCheckin() {
		return bootCheckin;
	}

	public void setBootCheckin(String bootCheckin) {
		this.bootCheckin = bootCheckin;
	}

	public String getBootCheckout() {
		return bootCheckout;
	}

	public void setBootCheckout(String bootCheckout) {

	
		this.bootCheckout = bootCheckout;
	}

	public int getBootAdult() {
		return bootAdult;
	}

	public void setBootAdult(int bootAdult) {
		this.bootAdult = bootAdult;
	}

	public int getBootChild() {
		return bootChild;
	}

	public void setBootChild(int bootChild) {
		this.bootChild = bootChild;
	}

	public int getBootPayCheck() {
		return bootPayCheck;
	}

	public void setBootPayCheck(int bootPayCheck) {
		this.bootPayCheck = bootPayCheck;
	}

	public String getBootPlease() {
		return bootPlease;
	}

	public void setBootPlease(String bootPlease) {
		this.bootPlease = bootPlease;
	}

	public int getBootConfirm() {
		return bootConfirm;
	}

	public void setBootConfirm(int bootConfirm) {
		this.bootConfirm = bootConfirm;
	}

	public String getReservationCode() {
		return reservationCode;
	}

	public void setReservationCode(String reservationCode) {
		this.reservationCode = reservationCode;
	}
}