package vo;

import java.util.Date;

public class HistoryMemoVo {
	private String memoPhone;   // memo_phone VARCHAR2(13) PRIMARY KEY
    private String memoContent; // memo_content VARCHAR2(1000)
    private String memoName;    // memo_name VARCHAR2(30) NOT NULL
    private Date memoDate;      // memo_date DATE DEFAULT sysdate NOT NULL
    
    
    public String getMemoPhone() {
		return memoPhone;
	}
	public void setMemoPhone(String memoPhone) {
		this.memoPhone = memoPhone;
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
	public String getAdminName() {
		return adminName;
	}
	public void setAdminName(String adminName) {
		this.adminName = adminName;
	}
	private String adminName;
}
