package myNotice;

import java.sql.Date;

public class NoticeDto {
    private int noticeNo;       // 공지사항 고유 번호 (기본키)
    private String title;       // 공지 제목
    private String content;     // 공지 내용
    private int hit;            // 조회수
    private Date regDate;       // 등록일
    private String imageFile;   // 서버 컴퓨터 폴더에 저장된 이미지 파일 이름

    // 기본 생성자
    public NoticeDto() {}

    // Getter & Setter 메서드들
    public int getNoticeNo() { 
        return noticeNo; 
    }
    
    public void setNoticeNo(int noticeNo) { 
        this.noticeNo = noticeNo; 
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

    public int getHit() { 
        return hit; 
    }

    public void setHit(int hit) { 
        this.hit = hit; 
    }

    public Date getRegDate() { 
        return regDate; 
    }

    public void setRegDate(Date regDate) { 
        this.regDate = regDate; 
    }
  
    public String getImageFile() { 
        return imageFile; 
    }

    public void setImageFile(String imageFile) { 
        this.imageFile = imageFile; 
    }
}