package myNotice;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class NoticeDao {

    private final String url = "jdbc:mysql://localhost:3306/IT1project?serverTimezone=UTC";
    private final String user = "proid";
    private final String pass = "3431";

    public NoticeDao() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL 드라이버 로드 실패! WebContent/WEB-INF/lib 폴더를 확인하세요.");
            e.printStackTrace();
        }
    }

    // [1] 전체 공지사항 목록 조회
    public ArrayList<NoticeDto> getNoticeList() {
        ArrayList<NoticeDto> list = new ArrayList<>();
        String sql = "SELECT * FROM NOTICE ORDER BY NOTICE_NO DESC";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                NoticeDto dto = new NoticeDto();
                dto.setNoticeNo(rs.getInt("NOTICE_NO"));
                dto.setTitle(rs.getString("TITLE"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setHit(rs.getInt("HIT"));
                dto.setRegDate(rs.getDate("REG_DATE"));
                dto.setImageFile(rs.getString("IMAGE_FILE"));
                list.add(dto);
            }
        } catch (SQLException e) {
            System.out.println("❌ getNoticeList 실행 중 DB 에러 발생!");
            e.printStackTrace();
        }
        return list;
    }

    // [2] 새 공지사항 등록
    public int insertNotice(NoticeDto dto) {
        String sql = "INSERT INTO NOTICE (TITLE, CONTENT, HIT, REG_DATE, IMAGE_FILE) VALUES (?, ?, 0, NOW(), ?)";
        int result = 0;

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getImageFile());
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("❌ insertNotice 실행 중 DB 에러 발생!");
            e.printStackTrace();
        }
        return result;
    }

    // [3] 공지사항 수정 처리
    public int updateNotice(NoticeDto dto) {
        String sql = "UPDATE NOTICE SET TITLE = ?, CONTENT = ?, IMAGE_FILE = ? WHERE NOTICE_NO = ?";
        int result = 0;

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getImageFile());
            pstmt.setInt(4, dto.getNoticeNo());
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("❌ updateNotice 실행 중 DB 에러 발생!");
            e.printStackTrace();
        }
        return result;
    }

    // [4] 🌟 잃어버렸던 공지사항 삭제 처리 (다시 추가 완료!)
    public int deleteNotice(int noticeNo) {
        String sql = "DELETE FROM NOTICE WHERE NOTICE_NO = ?";
        int result = 0;

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, noticeNo);
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            System.out.println("❌ deleteNotice 실행 중 DB 에러 발생!");
            e.printStackTrace();
        }
        return result;
    }

    // [5] 특정 공지사항 한 건 상세 조회
    public NoticeDto getNoticeDetail(int noticeNo) {
        NoticeDto dto = null;
        String sql = "SELECT * FROM NOTICE WHERE NOTICE_NO = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, noticeNo);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    dto = new NoticeDto();
                    dto.setNoticeNo(rs.getInt("NOTICE_NO"));
                    dto.setTitle(rs.getString("TITLE"));
                    dto.setContent(rs.getString("CONTENT"));
                    dto.setHit(rs.getInt("HIT"));
                    dto.setRegDate(rs.getDate("REG_DATE"));
                    dto.setImageFile(rs.getString("IMAGE_FILE"));
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ getNoticeDetail 실행 중 DB 에러 발생!");
            e.printStackTrace();
        }
        return dto;
    }
}