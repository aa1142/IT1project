package dto; // 패키지 경로는 환경에 맞게 수정해서 사용하세요.

public class BootDto {
    
    // ========================================================
    // [1] 필드 변수 정의 (테이블 컬럼 매핑)
    // ========================================================
    private String bootNo;            // boot_no NUMBER(4)
    private String roomGrade;      // room_grade VARCHAR2(20)
    private int roomType;
    private int roomNo;            // room_no NUMBER
    private int companyNo;         // company_no NUMBER
    private String memberId;       // member_id VARCHAR2(50)
    private String bootPhone;      // boot_phone VARCHAR2(13)
    private String bootName;       // boot_name VARCHAR2(30)
	private String bootEmail;      // boot_email VARCHAR2(60)
    private String bootCheckin;    // boot_checkin DATE (웹 처리가 편하도록 String 세팅)
    private String bootCheckout;   // boot_checkout DATE
    private int bootAdult;         // boot_audlt NUMBER (오타 수정: audlt -> adult)
    private int bootChild;         // boot_child NUMBER
    private int bootPayCheck;      // boot_pay_check NUMBER
    private String bootPlease;     // boot_please VARCHAR2(400)
    private int bootConfirm;       // boot_confirm NUMBER

    // ========================================================
    // [2] 생성자 (Constructor)
    // ========================================================
    
    // 기본 생성자
    public BootDto() {
    }

    // 전체 필드 초기화 생성자 (선택적 사용)
//    public BootDto(int bootNo, String roomGrade, int roomNo, int companyNo, String memberId, String bootPhone,
//                   String bootName, String bootEmail, String bootCheckin, String bootCheckout, int bootAdult,
//                   int bootChild, int bootPayCheck, String bootPlease, int bootConfirm) {
//        this.bootNo = bootNo;
//        this.roomGrade = roomGrade;
//        this.roomNo = roomNo;
//        this.companyNo = companyNo;
//        this.memberId = memberId;
//        this.bootPhone = bootPhone;
//        this.bootName = bootName;
//        this.bootEmail = bootEmail;
//        this.bootCheckin = bootCheckin;
//        this.bootCheckout = bootCheckout;
//        this.bootAdult = bootAdult;
//        this.bootChild = bootChild;
//        this.bootPayCheck = bootPayCheck;
//        this.bootPlease = bootPlease;
//        this.bootConfirm = bootConfirm;
//    }

    // ========================================================
    // [3] Getter / Setter 메서드
    // ========================================================
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
    
    public int getRoomType() {
		return roomType;
	}

	public void setRoomType(int roomType) {
		this.roomType = roomType;
	}

    // ========================================================
    // [4] 데이터 확인용 toString() 메서드
    // ========================================================
    @Override
    public String toString() {
        return "BootDto [bootNo=" + bootNo + ", roomGrade=" + roomGrade + ", roomNo=" + roomNo + ", companyNo="
                + companyNo + ", memberId=" + memberId + ", bootPhone=" + bootPhone + ", bootName=" + bootName
                + ", bootEmail=" + bootEmail + ", bootCheckin=" + bootCheckin + ", bootCheckout=" + bootCheckout
                + ", bootAdult=" + bootAdult + ", bootChild=" + bootChild + ", bootPayCheck=" + bootPayCheck
                + ", bootPlease=" + bootPlease + ", bootConfirm=" + bootConfirm + "]";
    }
}