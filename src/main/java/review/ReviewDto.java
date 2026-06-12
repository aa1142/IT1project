package review;

import java.util.Date;

public class ReviewDto {

    private int reviewNo;       // 리뷰 번호
    private String title;       // 제목
    private String content;     // 내용
    private int branch;      // 지점명
    private int roomType;    // 객실 유형
    private int rating;      // 평점
    private Date regDate;       // 작성일
    private String roomgrade;
    private String memberid;
    private int score_location;
    private int score_cleanliness;
    private int score_service;
    private int score_price;
    private int score_facilities;
   private int companyNo;

    public ReviewDto() {
    }

    public int getReviewNo() {
        return reviewNo;
    }

    public void setReviewNo(int reviewNo) {
        this.reviewNo = reviewNo;
    }

    public int getCompanyNo() {
		return companyNo;
	}

	public void setCompanyNo(int companyNo) {
		this.companyNo = companyNo;
	}

	public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getBranch() {
        return branch;
    }

    public void setBranch(int branch) {
        this.branch = branch;
    }

    public int getRoomType() {
        return roomType;
    }

    public void setRoomType(int roomType) {
        this.roomType = roomType;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public Date getRegDate() {
        return regDate;
    }

    public void setRegDate(Date regDate) {
        this.regDate = regDate;
    }

	public String getRoomgrade() {
		return roomgrade;
	}

	public void setRoomgrade(String roomgrade) {
		this.roomgrade = roomgrade;
	}

	public String getMemberid() {
		return memberid;
	}

	public void setMemberid(String memberid) {
		this.memberid = memberid;
	}

	public int getScore_location() {
		return score_location;
	}

	public void setScore_location(int score_location) {
		this.score_location = score_location;
	}

	public int getScore_cleanliness() {
		return score_cleanliness;
	}

	public void setScore_cleanliness(int score_cleanliness) {
		this.score_cleanliness = score_cleanliness;
	}

	public int getScore_service() {
		return score_service;
	}

	public void setScore_service(int score_service) {
		this.score_service = score_service;
	}

	public int getScore_price() {
		return score_price;
	}

	public void setScore_price(int score_price) {
		this.score_price = score_price;
	}

	public int getScore_facilities() {
		return score_facilities;
	}

	public void setScore_facilities(int score_facilities) {
		this.score_facilities = score_facilities;
	}

	
    
}