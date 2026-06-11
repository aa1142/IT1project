package review;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ReviewDao {

    // 💡 DB 연결 정보 (본인 환경에 맞게 고쳐주세요!)
	private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String URL    = "jdbc:oracle:thin:@localhost:1521:ORCL";  // SID 방식
    // 서비스명 방식: "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
    private static final String USER   = "proid";   // DB 계정
    private static final String PASS   = "3431";   // DB 비밀번호

    // 💡 연결을 가져오는 헬퍼 메서드 (예외처리 내장)
    private Connection getConnection() {
        Connection conn = null;
        try {
            // 오라클이면 OracleDriver, MySQL이면 아래 드라이버를 씁니다.
            
            conn = DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            System.out.println("--- DB 연결 실패! 주소나 비밀번호를 확인하세요 ---");
            e.printStackTrace();
        }
        return conn;
    }

    // 1. 리뷰 등록
    public int insertReview(ReviewDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        // 💡 오라클 시퀀스(REVIEW_SEQ.NEXTVAL) 대신 MySQL 규격(NOW())이나 컬럼에 맞게 SQL을 조정하시는 게 좋습니다.
        String sql = "INSERT INTO REVIEW (TITLE, CONTENT, BRANCH, ROOM_TYPE, RATING, REG_DATE) " +
                     "VALUES (?, ?, ?, ?, ?, NOW())";

        try {
            conn = this.getConnection(); // 1. 먼저 연결을 안전하게 맺고
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getBranch());
            pstmt.setString(4, dto.getRoomType());
            pstmt.setDouble(5, dto.getRating());

            result = pstmt.executeUpdate(); // 2. 실행

        } catch (SQLException e) {
            System.out.println("❌ insertReview 실행 중 DB 에러 발생!");
            e.printStackTrace(); // 콘솔에 상세 에러 출력
        } catch (Exception e) {
            System.out.println("❌ 알 수 없는 에러 발생!");
            e.printStackTrace();
        } finally {
            // 3. 🔥 핵심: 에러가 나든 안 나든 무조건 실행되어 자원을 닫아주는 구역
            closeResources(null, pstmt, conn);
        }

        return result; // 에러가 나면 0이 리턴되므로, 서블릿에서 실패 처리를 할 수 있어요!
    }

    // 2. 리뷰 목록 조회 (매개변수 문법 오류 수정)
    public ArrayList<ReviewDto> getReviewList() {
        ArrayList<ReviewDto> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String sql = "SELECT * FROM REVIEW ORDER BY REVIEW_NO DESC";

        try {
            conn = this.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                ReviewDto dto = new ReviewDto();
                dto.setReviewNo(rs.getInt("REVIEW_NO"));
                dto.setTitle(rs.getString("TITLE"));
                dto.setContent(rs.getString("CONTENT"));
                dto.setBranch(rs.getString("BRANCH"));
                dto.setRoomType(rs.getString("ROOM_TYPE"));
                dto.setRating(rs.getDouble("RATING"));
                dto.setRegDate(rs.getDate("REG_DATE"));

                list.add(dto);
            }

        } catch (SQLException e) {
            System.out.println("❌ getReviewList 실행 중 DB 에러 발생!");
            e.printStackTrace();
        } finally {
            // 3. 🔥 사용한 자원 역순으로 다 닫기
            closeResources(rs, pstmt, conn);
        }

        return list;
    }
    
    // 💡 코드가 지저분해지는 걸 막기 위한 자원 반납 전용 메서드
    private void closeResources(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}