package adminDto;

import java.util.Date;

public class MemoDto {
    // 1. 필드 선언 (테이블 컬럼과 1:1 매핑)
    private String memoPhone;   // memo_phone VARCHAR2(13) PRIMARY KEY
    private String adminId;     // admin_id VARCHAR2(20) REFERENCES admin
    private String memoContent; // memo_content VARCHAR2(1000)
    private String memoName;    // memo_name VARCHAR2(30) NOT NULL
    private Date memoDate;      // memo_date DATE DEFAULT sysdate NOT NULL

    // 2. 기본 생성자 (No-Args Constructor)
    public MemoDto() {
    }

    // 3. 전체 필드 생성자 (All-Args Constructor)
    public MemoDto(String memoPhone, String adminId, String memoContent, String memoName, Date memoDate) {
        this.memoPhone = memoPhone;
        this.adminId = adminId;
        this.memoContent = memoContent;
        this.memoName = memoName;
        this.memoDate = memoDate;
    }

    // 4. Getter / Setter 메소드
    public String getMemoPhone() {
        return memoPhone;
    }

    public void setMemoPhone(String memoPhone) {
        this.memoPhone = memoPhone;
    }

    public String getAdminId() {
        return adminId;
    }

    public void setAdminId(String adminId) {
        this.adminId = adminId;
    }

    public String getMemoContent() {
        return memoContent;
    }

    public void setMemoContent(String memoContent) {
        this.memoContent = memoContent;
    }

    public String getMemoName() {
        return memoName;
    }

    public void setMemoName(String memoName) {
        this.memoName = memoName;
    }

    public Date getMemoDate() {
        return memoDate;
    }

    public void setMemoDate(Date memoDate) {
        this.memoDate = memoDate;
    }

    // 5. 디버깅 및 데이터 확인용 toString() 오버라이딩
    @Override
    public String toString() {
        return "MemoDto ["
                + "memoPhone=" + memoPhone 
                + ", adminId=" + adminId 
                + ", memoContent=" + memoContent
                + ", memoName=" + memoName 
                + ", memoDate=" + memoDate 
                + "]";
    }
}