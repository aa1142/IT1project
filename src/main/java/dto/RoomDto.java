package dto;

	public class RoomDto {
	    
	    private int roomNo;        // room_no (NUMBER, PK) - 방 번호
	    private int companyNo;     // company_no (NUMBER, FK) - 회사(호텔) 번호
	    private String roomNow;    // room_now (VARCHAR2) - 현재 상태 ('사용가능', '청소 중', '점검 중') / 기본값: '사용가능'
	    private String roomGrade;  // room_grade (VARCHAR2) - 객실 등급 ('스탠다드', '디럭스', '스윗트')
	    private int roomType;      // room_type (NUMBER) - 객실 타입 (1=싱글, 2=트윈, 5=패밀리)
	    private int roomPrice;    // room_price (NUMBER(10)) - 객실 가격 (금액이 커질 수 있으므로 int 권장)



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
