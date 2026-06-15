package dto;

	public class RoomDto {
	    
	    private int roomNo;        // room_no (NUMBER, PK) - 방 번호
	    private int companyNo;     // company_no (NUMBER, FK) - 회사(호텔) 번호
	    private String roomNow;    // room_now (VARCHAR2) - 현재 상태 ('사용가능', '청소 중', '점검 중') / 기본값: '사용가능'
	    private String roomGrade;  // room_grade (VARCHAR2) - 객실 등급 ('스탠다드', '디럭스', '스윗트')
	    private int roomType;      // room_type (NUMBER) - 객실 타입 (1=싱글, 2=트윈, 5=패밀리)
	    private int roomPrice;    // room_price (NUMBER(10)) - 객실 가격 (금액이 커질 수 있으므로 int 권장)

	    // 기본 생성자 (상태 기본값 세팅)
	    public RoomDto() {
	        this.roomNow = "사용가능"; // DB DEFAULT '사용가능' 반영
	    }

	    // 모든 필드를 포함하는 생성자
	    public RoomDto(int roomNo, int companyNo, String roomNow, String roomGrade, int roomType, int roomPrice) {
	        this.roomNo = roomNo;
	        this.companyNo = companyNo;
	        this.roomNow = roomNow;
	        this.roomGrade = roomGrade;
	        this.roomType = roomType;
	        this.roomPrice = roomPrice;
	    }

	    // ⭐ 요청하신 느낌의 복사 생성자 (오류 수정 버전)
	    public RoomDto(RoomDto roomDto) {
	        if (roomDto != null) { // NullPointerException 방지를 위한 안전장치
	            this.roomNo = roomDto.getRoomNo();
	            this.companyNo = roomDto.getCompanyNo();
	            this.roomNow = roomDto.getRoomNow();
	            this.roomGrade = roomDto.getRoomGrade();
	            this.roomType = roomDto.getRoomType();
	            this.roomPrice = roomDto.getRoomPrice();
	        }
	    }

	    // Getter / Setter 메서드
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

	    public String getRoomNow() {
	        return roomNow;
	    }

	    public void setRoomNow(String roomNow) {
	        this.roomNow = roomNow;
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

	    public int getRoomPrice() {
	        return roomPrice;
	    }

	    public void setRoomPrice(int roomPrice) {
	        this.roomPrice = roomPrice;
	    }

	    // 데이터 확인 및 디버깅용 toString() 오버라이딩
	    @Override
	    public String toString() {
	        return "RoomDto [roomNo=" + roomNo + ", companyNo=" + companyNo + ", roomNow=" + roomNow + ", roomGrade="
	                + roomGrade + ", roomType=" + roomType + ", roomPrice=" + roomPrice + "]";
	    }
	}
