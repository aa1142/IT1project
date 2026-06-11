package com.jyphotel;

import java.sql.Connection;
import java.sql.DriverManager; // 🚨 DriverManager 사용을 위해 임포트 추가
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;
import java.util.Vector;

public class HotelDAO {

    private static final String ROOM_OK =
            " AND (r.room_now IS NULL OR TRIM(r.room_now) IN ('사용 가능', '사용가능')) ";

    /**
     * [변경] 톰캣 서버 장부(context.xml)를 쓰지 않고, 오라클 DB로 직접 전화를 거는 직통 연결 메소드
     */
    private Connection dbDirectConnect() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return java.sql.DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl", // 팀원 공용 SID인 orcl 지정
            "scott",
            "tiger"
        );
    }

    /** 한글 지점명 → DB 검색어 변환기 */
    private String convertBranchKeyword(String keyword) {
        if (keyword == null) {
            return "";
        }
        String k = keyword.trim();
        if (k.contains("도쿄") || k.contains("東京") || "tokyo".equalsIgnoreCase(k)) {
            return "東京";
        }
        if (k.contains("신주쿠") || k.contains("新宿") || "shinjuku".equalsIgnoreCase(k)) {
            return "新宿";
        }
        if (k.contains("요코하마") || k.contains("横浜") || "yokohama".equalsIgnoreCase(k)) {
            return "横浜";
        }
        return k;
    }

    /**
     * [메소드명 변경] getCompanyList → selectActiveBranchList
     * 지점 목록 조회
     */
    public Vector<CompanyVO> selectActiveBranchList(String keyword) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CompanyVO> list = new Vector<CompanyVO>();

        try {
            con = dbDirectConnect(); // 직통 주소 키 가동
            String searchWord = convertBranchKeyword(keyword);
            String sql = "SELECT c.company_no, c.company_name, "
                    + "(SELECT COUNT(DISTINCT r.room_grade || '-' || r.room_type) "
                    + " FROM room r WHERE r.company_no = c.company_no) AS type_cnt "
                    + "FROM company c ";
            boolean hasKeyword = !searchWord.equals("");
            if (hasKeyword) {
                sql += "WHERE c.company_name LIKE ? ";
            }
            sql += "ORDER BY c.company_no";

            pstmt = con.prepareStatement(sql);
            if (hasKeyword) {
                pstmt.setString(1, "%" + searchWord + "%");
            }
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CompanyVO vo = new CompanyVO();
                vo.setCompany_no(rs.getInt("company_no"));
                vo.setCompany_name(rs.getString("company_name"));
                vo.setRoom_type_count(rs.getInt("type_cnt"));
                HotelDisplay.setCompanyInfo(vo);
                list.addElement(vo);
            }
        } catch (Exception e) { // throws Exception에 대응하기 위해 상위 Exception으로 포괄 처리
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return list;
    }

    /**
     * [메소드명 변경] getCompany → selectBranchDetail ByNo
     * 특정 지점 단건 정보 조회
     */
    public CompanyVO selectBranchDetailByNo(int company_no) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        CompanyVO vo = null;

        try {
            con = dbDirectConnect();
            String sql = "SELECT company_no, company_name FROM company WHERE company_no = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = new CompanyVO();
                vo.setCompany_no(rs.getInt("company_no"));
                vo.setCompany_name(rs.getString("company_name"));
                HotelDisplay.setCompanyInfo(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return vo;
    }

    /**
     * [메소드명 변경] getRoomList → selectAvailableRoomTypeList
     * 조건에 맞는 객실 타입 목록 인출
     */
    public Vector<RoomVO> selectAvailableRoomTypeList(int company_no, String ui_room_grade,
            String boot_checkin, String boot_checkout,
            int boot_adult, int boot_child, int rooms) {

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<RoomVO> list = new Vector<RoomVO>();
        String db_grade = RoomTypeUtil.toDbGrade(ui_room_grade);

        try {
            con = dbDirectConnect();
            String sql = "SELECT r.room_grade, r.room_type, MIN(r.room_price) AS room_price, COUNT(*) AS cnt "
                    + "FROM room r "
                    + "WHERE r.company_no = ? AND r.room_grade = ? "
                    + ROOM_OK
                    + " AND r.room_no NOT IN ( "
                    + "   SELECT b.room_no FROM boot b "
                    + "   WHERE b.room_no IS NOT NULL AND b.boot_confirm = 1 "
                    + "     AND b.boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
                    + "     AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
                    + " ) "
                    + "GROUP BY r.room_grade, r.room_type "
                    + "ORDER BY r.room_type";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            pstmt.setString(2, db_grade);
            pstmt.setString(3, boot_checkout);
            pstmt.setString(4, boot_checkin);
            rs = pstmt.executeQuery();

            boolean showSingle = RoomTypeUtil.canShowSingleRoom(boot_adult, boot_child, rooms);

            while (rs.next()) {
                int room_type = rs.getInt("room_type");
                if (room_type == RoomTypeUtil.ROOM_TYPE_SINGLE && !showSingle) {
                    continue;
                }
                RoomVO vo = new RoomVO();
                vo.setCompany_no(company_no);
                vo.setRoom_grade(rs.getString("room_grade"));
                vo.setRoom_type(room_type);
                vo.setRoom_price(rs.getInt("room_price"));
                vo.setRemain_count(rs.getInt("cnt"));
                list.addElement(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return list;
    }

    /**
     * [메소드명 변경] getOneRoom → selectSingleRoomTypePriceInfo
     * 최종 예약을 위한 단건 객실 요금 산출 검증기
     */
    public RoomVO selectSingleRoomTypePriceInfo(int company_no, String room_grade, int room_type,
            String boot_checkin, String boot_checkout) {

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        RoomVO vo = null;

        try {
            con = dbDirectConnect();
            String sql = "SELECT MIN(r.room_price) AS room_price, COUNT(*) AS cnt "
                    + "FROM room r "
                    + "WHERE r.company_no = ? AND r.room_grade = ? AND r.room_type = ? "
                    + ROOM_OK
                    + " AND r.room_no NOT IN ( "
                    + "   SELECT b.room_no FROM boot b "
                    + "   WHERE b.room_no IS NOT NULL AND b.boot_confirm = 1 "
                    + "     AND b.boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
                    + "     AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
                    + " )";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            pstmt.setString(2, room_grade);
            pstmt.setInt(3, room_type);
            pstmt.setString(4, boot_checkout);
            pstmt.setString(5, boot_checkin);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt("cnt") > 0) {
                vo = new RoomVO();
                vo.setCompany_no(company_no);
                vo.setRoom_grade(room_grade);
                vo.setRoom_type(room_type);
                vo.setRoom_price(rs.getInt("room_price"));
                vo.setRemain_count(rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return vo;
    }

    /**
     * [메소드명 변경] getEmptyRoomNo → assignEmptyRoomNumber
     * 매칭되는 빈 방 호수(Room_No)를 실시간으로 자동 배정
     */
    public int assignEmptyRoomNumber(int company_no, String room_grade, int room_type,
            String boot_checkin, String boot_checkout) {

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int room_no = 0;

        try {
            con = dbDirectConnect();
            String sql = "SELECT MIN(r.room_no) AS room_no "
                    + "FROM room r "
                    + "WHERE r.company_no = ? AND r.room_grade = ? AND r.room_type = ? "
                    + ROOM_OK
                    + " AND r.room_no NOT IN ( "
                    + "   SELECT b.room_no FROM boot b "
                    + "   WHERE b.room_no IS NOT NULL AND b.boot_confirm = 1 "
                    + "     AND b.boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
                    + "     AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
                    + " )";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            pstmt.setString(2, room_grade);
            pstmt.setInt(3, room_type);
            pstmt.setString(4, boot_checkout);
            pstmt.setString(5, boot_checkin);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                room_no = rs.getInt("room_no");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return room_no;
    }

    /**
     * [메소드명 변경] insertBoot → executeInsertReservation
     * 신규 예약 건수 오라클에 원자적 적재
     */
    public boolean executeInsertReservation(BootVO vo) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean flag = false;

        String boot_no = "B" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String reservation_code = "JYP" + (100000 + new Random().nextInt(900000));

        try {
            con = dbDirectConnect();
            con.setAutoCommit(false);

            String sql = "INSERT INTO boot ("
                    + "boot_no, room_grade, room_type, room_no, company_no, member_id, "
                    + "boot_phone, boot_name, boot_email, boot_checkin, boot_checkout, "
                    + "boot_adult, boot_child, boot_pay_check, boot_please, boot_confirm, RESERVATION_CODE"
                    + ") VALUES (?,?,?,?,?,?,?,?,?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?)";

            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, boot_no);
            pstmt.setString(2, vo.getRoom_grade());
            pstmt.setInt(3, vo.getRoom_type());
            pstmt.setInt(4, vo.getRoom_no());
            pstmt.setInt(5, vo.getCompany_no());

            if (vo.getMember_id() != null && !vo.getMember_id().trim().equals("")) {
                pstmt.setString(6, vo.getMember_id());
            } else {
                pstmt.setNull(6, java.sql.Types.VARCHAR);
            }

            pstmt.setString(7, vo.getBoot_phone());
            pstmt.setString(8, vo.getBoot_name());
            pstmt.setString(9, vo.getBoot_email());
            pstmt.setString(10, vo.getBoot_checkin());
            pstmt.setString(11, vo.getBoot_checkout());
            pstmt.setInt(12, vo.getBoot_adult());
            pstmt.setInt(13, vo.getBoot_child());
            pstmt.setInt(14, vo.getBoot_pay_check());
            pstmt.setString(15, vo.getBoot_please());
            pstmt.setInt(16, vo.getBoot_confirm());
            pstmt.setString(17, reservation_code);

            int count = pstmt.executeUpdate();
            if (count > 0) {
                if (vo.getRoom_no() > 0) {
                    PreparedStatement roomPstmt = con.prepareStatement(
                            "UPDATE room SET room_now = '예약 중' WHERE room_no = ? AND company_no = ?");
                    roomPstmt.setInt(1, vo.getRoom_no());
                    roomPstmt.setInt(2, vo.getCompany_no());
                    roomPstmt.executeUpdate();
                    roomPstmt.close();
                }
                con.commit();
                vo.setBoot_no(boot_no);
                vo.setReservation_code(reservation_code);
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return flag;
    }

    /**
     * [메소드명 변경] getBoot → selectReservationReceipt
     * 영수증 단건 정밀 인출
     */
    public BootVO selectReservationReceipt(String boot_no) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BootVO vo = null;

        try {
            con = dbDirectConnect();
            String sql = "SELECT b.*, c.company_name, "
                    + "TO_CHAR(b.boot_checkin, 'YYYY-MM-DD') AS ci, "
                    + "TO_CHAR(b.boot_checkout, 'YYYY-MM-DD') AS co "
                    + "FROM boot b LEFT JOIN company c ON c.company_no = b.company_no "
                    + "WHERE b.boot_no = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, boot_no);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = parseReceiptData(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return vo;
    }

    /**
     * [메소드명 변경] getBootListByMemberId → selectReservationHistoryByMember
     * 특정 회원의 과거 전체 투숙 이력 리스트업
     */
    public Vector<BootVO> selectReservationHistoryByMember(String member_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<BootVO> list = new Vector<BootVO>();

        try {
            con = dbDirectConnect();
            String sql = "SELECT b.*, c.company_name, "
                    + "TO_CHAR(b.boot_checkin, 'YYYY-MM-DD') AS ci, "
                    + "TO_CHAR(b.boot_checkout, 'YYYY-MM-DD') AS co "
                    + "FROM boot b LEFT JOIN company c ON c.company_no = b.company_no "
                    + "WHERE b.member_id = ? ORDER BY b.boot_checkin DESC";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, member_id);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                list.addElement(parseReceiptData(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return list;
    }

    /**
     * [메소드명 변경] getMember → selectClientProfile
     * 가입된 유저 프로필 인출기
     */
    public MemberVO selectClientProfile(String member_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        MemberVO vo = null;

        try {
            con = dbDirectConnect();
            String sql = "SELECT member_id, member_name, member_phone, member_email, member_address "
                    + "FROM member WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, member_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = parseClientData(rs);
            } else {
                rs.close();
                pstmt.close();
                sql = "SELECT member_id, name_ko AS member_name, phone AS member_phone, "
                        + "email AS member_email, address AS member_address "
                        + "FROM member WHERE member_id = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setString(1, member_id);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    vo = parseClientData(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return vo;
    }

    /** [메소드명 변경] mapBoot → parseReceiptData */
    private BootVO parseReceiptData(ResultSet rs) throws SQLException {
        BootVO vo = new BootVO();
        vo.setBoot_no(rs.getString("boot_no"));
        vo.setRoom_grade(rs.getString("room_grade"));
        vo.setRoom_type(rs.getInt("room_type"));
        vo.setRoom_no(rs.getInt("room_no"));
        vo.setCompany_no(rs.getInt("company_no"));
        vo.setCompany_name(rs.getString("company_name"));
        vo.setMember_id(rs.getString("member_id"));
        vo.setBoot_phone(rs.getString("boot_phone"));
        vo.setBoot_name(rs.getString("boot_name"));
        vo.setBoot_email(rs.getString("boot_email"));
        vo.setBoot_checkin(rs.getString("ci"));
        vo.setBoot_checkout(rs.getString("co"));
        vo.setBoot_adult(rs.getInt("boot_adult"));
        vo.setBoot_child(rs.getInt("boot_child"));
        vo.setBoot_pay_check(rs.getInt("boot_pay_check"));
        vo.setBoot_please(rs.getString("boot_please"));
        vo.setBoot_confirm(rs.getInt("boot_confirm"));
        vo.setReservation_code(rs.getString("RESERVATION_CODE"));
        return vo;
    }

    /** [메소드명 변경] mapMember → parseClientData */
    private MemberVO parseClientData(ResultSet rs) throws SQLException {
        MemberVO vo = new MemberVO();
        vo.setMember_id(rs.getString("member_id"));
        vo.setMember_name(rs.getString("member_name"));
        vo.setMember_phone(rs.getString("member_phone"));
        vo.setMember_email(rs.getString("member_email"));
        vo.setMember_address(rs.getString("member_address"));
        return vo;
    }
}