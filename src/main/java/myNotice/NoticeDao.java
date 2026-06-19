package myNotice;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class NoticeDao {

    private NoticeDto mapNotice(ResultSet rs) throws SQLException {
        NoticeDto noticeDto = new NoticeDto();
        noticeDto.setNoticeNo(rs.getInt("NOTICE_NO"));
        noticeDto.setTitle(rs.getString("NOTICE_TITLE"));
        noticeDto.setContent(rs.getString("NOTICE_CONTENT"));
        noticeDto.setHit(rs.getInt("HIT"));
        noticeDto.setRegDate(rs.getDate("REG_DATE"));
        noticeDto.setImageFile(rs.getString("IMAGE_FILE"));
        return noticeDto;
    }

    public ArrayList<NoticeDto> getNoticeList() {
        String sql = "SELECT * FROM NOTICE "
                + "ORDER BY CASE "
                + "WHEN NOTICE_TITLE LIKE '[\uC911\uC694\uACF5\uC9C0]%' OR NOTICE_TITLE LIKE '[重要]%' THEN 0 "
                + "ELSE 1 END, NOTICE_NO DESC";
        ArrayList<NoticeDto> noticeList = new ArrayList<>();

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                noticeList.add(mapNotice(rs));
            }
        } catch (SQLException e) {
            System.err.println("[NoticeDao] getNoticeList failed: " + e.getMessage());
            e.printStackTrace();
        }

        return noticeList;
    }

    public int insertNotice(NoticeDto dto) {
        String sql = "INSERT INTO NOTICE "
                + "(NOTICE_NO, NOTICE_TITLE, NOTICE_CONTENT, HIT, REG_DATE, IMAGE_FILE) "
                + "VALUES (NOTICE_SEQ.NEXTVAL, ?, ?, 0, SYSDATE, ?)";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getImageFile());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NoticeDao] insertNotice failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public int updateNotice(NoticeDto dto) {
        String sql = "UPDATE NOTICE "
                + "SET NOTICE_TITLE = ?, NOTICE_CONTENT = ?, IMAGE_FILE = ? "
                + "WHERE NOTICE_NO = ?";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getImageFile());
            pstmt.setInt(4, dto.getNoticeNo());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NoticeDao] updateNotice failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public int deleteNotice(int noticeNo) {
        String sql = "DELETE FROM NOTICE WHERE NOTICE_NO = ?";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, noticeNo);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NoticeDao] deleteNotice failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public NoticeDto getNoticeDetail(int noticeNo) {
        String sql = "SELECT * FROM NOTICE WHERE NOTICE_NO = ?";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, noticeNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapNotice(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[NoticeDao] getNoticeDetail failed: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    public int increaseHit(int noticeNo) {
        String sql = "UPDATE NOTICE SET HIT = HIT + 1 WHERE NOTICE_NO = ?";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, noticeNo);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[NoticeDao] increaseHit failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public int getLatestNoticeNo() {
        String sql = "SELECT MAX(NOTICE_NO) FROM NOTICE";

        try (Connection conn = NoticeDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[NoticeDao] getLatestNoticeNo failed: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }
}
