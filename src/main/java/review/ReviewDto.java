package review;

public class ReviewDto {

    private int reviewNo;
    private String title;
    private String content;
    private int branch;
    private int rating;
    private String bootNo;
    private String memberid;
    private int companyNo;
    private int boot_no;
    private String roomGrade;
    private int roomType;
    private String bootCheckin;
    private String bootCheckout;

    public ReviewDto() {
    }

    public int getReviewNo() {
        return reviewNo;
    }

    public void setReviewNo(int reviewNo) {
        this.reviewNo = reviewNo;
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

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getBootNo() {
        return bootNo;
    }

    public void setBootNo(String bootNo) {
        this.bootNo = bootNo;
    }

    public String getMemberid() {
        return memberid;
    }

    public void setMemberid(String memberid) {
        this.memberid = memberid;
    }

    public int getCompanyNo() {
        return companyNo;
    }

    public void setCompanyNo(int companyNo) {
        this.companyNo = companyNo;
    }

    public int getBoot_no() {
        return boot_no;
    }

    public void setBoot_no(int boot_no) {
        this.boot_no = boot_no;
    }

    public String getRoomGrade() {
        return roomGrade;
    }

    public void setRoomGrade(String roomGrade) {
        this.roomGrade = roomGrade;
    }

    public String getRoomgrade() {
        return roomGrade;
    }

    public void setRoomgrade(String roomGrade) {
        this.roomGrade = roomGrade;
    }

    public int getRoomType() {
        return roomType;
    }

    public void setRoomType(int roomType) {
        this.roomType = roomType;
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
}
