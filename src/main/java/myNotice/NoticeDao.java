package myNotice;

import java.util.ArrayList;

import db.SqlSet;

public class NoticeDao {
    SqlSet db = new SqlSet();

    public ArrayList<NoticeDto> getNoticeList() {
        String sql = "SELECT * FROM NOTICE ORDER BY NOTICE_NO DESC";
        Object[] params = {};
        ArrayList<NoticeDto> noticeList = new ArrayList<>();

        db.selectTemplate(sql, params, rs -> {
            while (rs.next()) {
                NoticeDto noticeDto = new NoticeDto();
                noticeDto.setNoticeNo(rs.getInt("notice_no"));
                noticeDto.setTitle(rs.getString("notice_title"));
                noticeDto.setContent(rs.getString("notice_content"));
                noticeDto.setHit(rs.getInt("hit"));
                noticeDto.setRegDate(rs.getDate("reg_date"));
                noticeDto.setImageFile(rs.getString("image_file"));
                noticeList.add(noticeDto);
            }
            return noticeList;
        });

        return noticeList;
    }

    public int insertNotice(NoticeDto dto) {
        String sql = "INSERT INTO NOTICE "
                + "(NOTICE_NO, NOTICE_TITLE, NOTICE_CONTENT, HIT, REG_DATE, IMAGE_FILE) "
                + "VALUES (NOTICE_SEQ.NEXTVAL, ?, ?, 0, SYSDATE, ?)";
        Object[] params = {
                dto.getTitle(),
                dto.getContent(),
                dto.getImageFile()
        };

        return db.updateTemplate(sql, params);
    }

    public int updateNotice(NoticeDto dto) {
        String sql = "UPDATE NOTICE "
                + "SET NOTICE_TITLE = ?, NOTICE_CONTENT = ?, IMAGE_FILE = ? "
                + "WHERE NOTICE_NO = ?";
        Object[] params = {
                dto.getTitle(),
                dto.getContent(),
                dto.getImageFile(),
                dto.getNoticeNo()
        };

        return db.updateTemplate(sql, params);
    }

    public int deleteNotice(int noticeNo) {
        String sql = "DELETE FROM NOTICE WHERE NOTICE_NO = ?";
        Object[] params = { noticeNo };

        return db.updateTemplate(sql, params);
    }

    public NoticeDto getNoticeDetail(int noticeNo) {
        String sql = "SELECT * FROM NOTICE WHERE NOTICE_NO = ?";
        Object[] params = { noticeNo };

        return db.selectTemplate(sql, params, rs -> {
            if (rs.next()) {
                NoticeDto noticeDto = new NoticeDto();
                noticeDto.setNoticeNo(rs.getInt("notice_no"));
                noticeDto.setTitle(rs.getString("notice_title"));
                noticeDto.setContent(rs.getString("notice_content"));
                noticeDto.setHit(rs.getInt("hit"));
                noticeDto.setRegDate(rs.getDate("reg_date"));
                noticeDto.setImageFile(rs.getString("image_file"));
                return noticeDto;
            }
            return null;
        });
    }

    public int increaseHit(int noticeNo) {
        String sql = "UPDATE NOTICE SET HIT = HIT + 1 WHERE NOTICE_NO = ?";
        Object[] params = { noticeNo };

        return db.updateTemplate(sql, params);
    }

    public int getLatestNoticeNo() {
        String sql = "SELECT MAX(NOTICE_NO) FROM NOTICE";
        Object[] params = {};

        Integer latestNo = db.selectTemplate(sql, params, rs -> {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        });

        return latestNo == null ? 0 : latestNo;
    }
}
