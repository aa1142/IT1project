package review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;

public class ReviewDao {

    private static final String REVIEW_WITH_BOOT_SELECT =
            "SELECT r.*, "
            + "b.ROOM_GRADE AS BOOT_ROOM_GRADE, "
            + "b.ROOM_TYPE AS BOOT_ROOM_TYPE, "
            + "TO_CHAR(b.BOOT_CHECKIN, 'YYYY-MM-DD') AS BOOT_CHECKIN_TEXT, "
            + "TO_CHAR(b.BOOT_CHECKOUT, 'YYYY-MM-DD') AS BOOT_CHECKOUT_TEXT "
            + "FROM REVIEW r "
            + "LEFT JOIN BOOT b ON r.BOOT_NO = TO_CHAR(b.BOOT_NO) ";

    private ReviewDto mapReview(ResultSet rs) throws SQLException {
        ReviewDto reviewDto = new ReviewDto();
        reviewDto.setReviewNo(rs.getInt("REVIEW_NO"));
        reviewDto.setBootNo(rs.getString("BOOT_NO"));
        reviewDto.setMemberid(rs.getString("MEMBER_ID"));
        reviewDto.setCompanyNo(rs.getInt("COMPANY_NO"));
        reviewDto.setBranch(rs.getInt("COMPANY_NO"));
        reviewDto.setRating(rs.getInt("RATING"));
        reviewDto.setScore_location(rs.getInt("SCORE_LOCATION"));
        reviewDto.setScore_cleanliness(rs.getInt("SCORE_CLEANLINESS"));
        reviewDto.setScore_service(rs.getInt("SCORE_SERVICE"));
        reviewDto.setScore_price(rs.getInt("SCORE_PRICE"));
        reviewDto.setScore_facilities(rs.getInt("SCORE_FACILITIES"));
        reviewDto.setContent(rs.getString("REVIEW_CONTENT"));
        reviewDto.setRoomGrade(getStringIfExists(rs, "BOOT_ROOM_GRADE"));
        reviewDto.setRoomType(getIntIfExists(rs, "BOOT_ROOM_TYPE"));
        reviewDto.setBootCheckin(getStringIfExists(rs, "BOOT_CHECKIN_TEXT"));
        reviewDto.setBootCheckout(getStringIfExists(rs, "BOOT_CHECKOUT_TEXT"));
        return reviewDto;
    }

    private String getStringIfExists(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException e) {
            return null;
        }
    }

    private int getIntIfExists(ResultSet rs, String columnName) {
        try {
            return rs.getInt(columnName);
        } catch (SQLException e) {
            return 0;
        }
    }

    public int insertReview(ReviewDto dto) {
        String sql = "INSERT INTO REVIEW "
                + "(REVIEW_NO, BOOT_NO, MEMBER_ID, COMPANY_NO, RATING, "
                + "SCORE_LOCATION, SCORE_CLEANLINESS, SCORE_SERVICE, SCORE_PRICE, SCORE_FACILITIES, REVIEW_CONTENT) "
                + "VALUES (REVIEW_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            if (dto.getBootNo() == null || dto.getBootNo().trim().isEmpty()) {
                pstmt.setNull(1, Types.VARCHAR);
            } else {
                pstmt.setString(1, dto.getBootNo().trim());
            }
            pstmt.setString(2, dto.getMemberid());
            pstmt.setInt(3, dto.getCompanyNo());
            pstmt.setInt(4, dto.getRating());
            pstmt.setInt(5, dto.getScore_location());
            pstmt.setInt(6, dto.getScore_cleanliness());
            pstmt.setInt(7, dto.getScore_service());
            pstmt.setInt(8, dto.getScore_price());
            pstmt.setInt(9, dto.getScore_facilities());
            pstmt.setString(10, dto.getContent());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ReviewDao] insertReview failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public ArrayList<ReviewDto> getReviewList() {
        String sql = REVIEW_WITH_BOOT_SELECT + "ORDER BY r.REVIEW_NO DESC";
        ArrayList<ReviewDto> reviewList = new ArrayList<>();

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                reviewList.add(mapReview(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ReviewDao] getReviewList failed: " + e.getMessage());
            e.printStackTrace();
        }

        return reviewList;
    }

    public ReviewDto getReviewDetail(int reviewNo) {
        String sql = REVIEW_WITH_BOOT_SELECT + "WHERE r.REVIEW_NO = ?";

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, reviewNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapReview(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReviewDao] getReviewDetail failed: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    public int updateReview(ReviewDto dto) {
        String sql = "UPDATE REVIEW "
                + "SET COMPANY_NO = ?, RATING = ?, "
                + "SCORE_LOCATION = ?, SCORE_CLEANLINESS = ?, SCORE_SERVICE = ?, "
                + "SCORE_PRICE = ?, SCORE_FACILITIES = ?, REVIEW_CONTENT = ? "
                + "WHERE REVIEW_NO = ?";

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, dto.getCompanyNo());
            pstmt.setInt(2, dto.getRating());
            pstmt.setInt(3, dto.getScore_location());
            pstmt.setInt(4, dto.getScore_cleanliness());
            pstmt.setInt(5, dto.getScore_service());
            pstmt.setInt(6, dto.getScore_price());
            pstmt.setInt(7, dto.getScore_facilities());
            pstmt.setString(8, dto.getContent());
            pstmt.setInt(9, dto.getReviewNo());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ReviewDao] updateReview failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public int deleteReview(int reviewNo) {
        String sql = "DELETE FROM REVIEW WHERE REVIEW_NO = ?";

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, reviewNo);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ReviewDao] deleteReview failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
}
