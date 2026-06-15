package review;

import java.util.ArrayList;

import db.SqlSet;

public class ReviewDao {
    SqlSet db = new SqlSet();

    public int insertReview(ReviewDto dto) {
        String sql = "INSERT INTO REVIEW "
                + "(review_no, member_id, company_no, room_grade, room_type, rating, "
                + "score_location, score_cleanliness, score_service, score_price, score_facilities, review_content) "
                + "VALUES (review_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Object[] params = {
                dto.getMemberid(),
                dto.getCompanyNo(),
                dto.getRoomgrade(),
                dto.getRoomType(),
                dto.getRating(),
                dto.getScore_location(),
                dto.getScore_cleanliness(),
                dto.getScore_service(),
                dto.getScore_price(),
                dto.getScore_facilities(),
                dto.getContent()
        };

        return db.updateTemplate(sql, params);
    }

    public ArrayList<ReviewDto> getReviewList() {
        String sql = "SELECT * FROM review ORDER BY review_no DESC";
        Object[] params = {};

        ArrayList<ReviewDto> reviewList = new ArrayList<>();

        db.selectTemplate(sql, params, rs -> {
            while (rs.next()) {
                ReviewDto reviewDto = new ReviewDto();
                reviewDto.setReviewNo(rs.getInt("review_no"));
                reviewDto.setMemberid(rs.getString("member_id"));
                reviewDto.setCompanyNo(rs.getInt("company_no"));
                reviewDto.setRoomgrade(rs.getString("room_grade"));
                reviewDto.setRoomType(rs.getInt("room_type"));
                reviewDto.setRating(rs.getInt("rating"));
                reviewDto.setScore_location(rs.getInt("score_location"));
                reviewDto.setScore_cleanliness(rs.getInt("score_cleanliness"));
                reviewDto.setScore_service(rs.getInt("score_service"));
                reviewDto.setScore_price(rs.getInt("score_price"));
                reviewDto.setScore_facilities(rs.getInt("score_facilities"));
                reviewDto.setContent(rs.getString("review_content"));

                reviewList.add(reviewDto);
            }
            return reviewList;
        });

        return reviewList;
    }

    public ReviewDto getReviewDetail(int reviewNo) {
        String sql = "SELECT * FROM review WHERE review_no = ?";
        Object[] params = { reviewNo };

        return db.selectTemplate(sql, params, rs -> {
            if (rs.next()) {
                ReviewDto reviewDto = new ReviewDto();
                reviewDto.setReviewNo(rs.getInt("review_no"));
                reviewDto.setMemberid(rs.getString("member_id"));
                reviewDto.setCompanyNo(rs.getInt("company_no"));
                reviewDto.setBranch(rs.getInt("company_no"));
                reviewDto.setRoomgrade(rs.getString("room_grade"));
                reviewDto.setRoomType(rs.getInt("room_type"));
                reviewDto.setRating(rs.getInt("rating"));
                reviewDto.setScore_location(rs.getInt("score_location"));
                reviewDto.setScore_cleanliness(rs.getInt("score_cleanliness"));
                reviewDto.setScore_service(rs.getInt("score_service"));
                reviewDto.setScore_price(rs.getInt("score_price"));
                reviewDto.setScore_facilities(rs.getInt("score_facilities"));
                reviewDto.setContent(rs.getString("review_content"));
                return reviewDto;
            }
            return null;
        });
    }

    public int updateReview(ReviewDto dto) {
        String sql = "UPDATE review "
                + "SET company_no = ?, room_grade = ?, room_type = ?, rating = ?, "
                + "score_location = ?, score_cleanliness = ?, score_service = ?, "
                + "score_price = ?, score_facilities = ?, review_content = ? "
                + "WHERE review_no = ?";

        Object[] params = {
                dto.getCompanyNo(),
                dto.getRoomgrade(),
                dto.getRoomType(),
                dto.getRating(),
                dto.getScore_location(),
                dto.getScore_cleanliness(),
                dto.getScore_service(),
                dto.getScore_price(),
                dto.getScore_facilities(),
                dto.getContent(),
                dto.getReviewNo()
        };

        return db.updateTemplate(sql, params);
    }

    public int deleteReview(int reviewNo) {
        String sql = "DELETE FROM review WHERE review_no = ?";
        Object[] params = { reviewNo };

        return db.updateTemplate(sql, params);
    }
}
