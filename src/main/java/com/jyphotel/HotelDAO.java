package com.jyphotel;

import java.sql.Connection;
import java.sql.DriverManager; // 🚨 DriverManager 사용을 위해 임포트 추가
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Random;
import java.util.Vector;

public class HotelDAO {

    /** Admin bootmng 조회용 — 일반/온라인 예약 */
    public static final int PAY_CHECK_ONLINE = 0;
    /** Admin onsitePayment 조회용 — 현장 결제 예약 */
    public static final int PAY_CHECK_ONSITE = 1;

    /** boot_confirm: 결제·확정 대기 */
    public static final int CONFIRM_PENDING = 0;
    /** boot_confirm: 예약 확정 */
    public static final int CONFIRM_DONE = 1;

    /** DB room.room_now CHECK: '사용 가능' 만 예약 가능 */
    private static final String ROOM_OK =
            " AND TRIM(r.room_now) = '사용 가능' ";

    /** 확정 예약만 객실 점유로 간주 */
    private static final String BOOT_ROOM_BUSY =
            " AND r.room_no NOT IN ( "
            + "   SELECT b.room_no FROM boot b "
            + "   WHERE b.room_no IS NOT NULL AND b.boot_confirm = 1 "
            + "     AND b.boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
            + "     AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
            + " ) ";

    /** context.xml(proid) 기준 — SID/서비스명 환경 차이 대비 후보 URL */
    private static final String DB_USER = "scott";
    private static final String DB_PASS = "tiger";
    private static final String[] DB_URLS = {
            //"jdbc:oracle:thin:@localhost:1521:xe",
            "jdbc:oracle:thin:@localhost:1521:orcl",
//            "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
    };

    private static String lastDbError = "";

    public String getLastDbError() {
        return lastDbError;
    }

    private Connection dbDirectConnect() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        Exception last = null;
        for (int i = 0; i < DB_URLS.length; i++) {
            try {
                Connection con = DriverManager.getConnection(DB_URLS[i], DB_USER, DB_PASS);
                lastDbError = "";
                return con;
            } catch (Exception e) {
                last = e;
                lastDbError = DB_URLS[i] + " → " + e.getMessage();
                System.err.println("[HotelDAO] DB connect failed: " + lastDbError);
            }
        }
        if (last != null) {
            throw last;
        }
        throw new SQLException("DB connection failed");
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

    /** 메인(wls) dest 파라미터 → company_no (DB 조회 우선) */
    public int resolveCompanyNoByDest(String dest) {
        if (dest == null || dest.trim().isEmpty()) {
            return 0;
        }
        String d = dest.trim();
        Vector<CompanyVO> list = selectActiveBranchList(convertBranchKeyword(d));
        if (list.size() > 0) {
            return list.elementAt(0).getCompany_no();
        }
        if ("tokyo".equalsIgnoreCase(d)) {
            return 1;
        }
        if ("shinjuku".equalsIgnoreCase(d)) {
            return 2;
        }
        if ("yokohama".equalsIgnoreCase(d)) {
            return 3;
        }
        return 0;
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
        } catch (Exception e) {
            if (lastDbError == null || lastDbError.isEmpty()) {
                lastDbError = e.getMessage();
            }
            System.err.println("[HotelDAO] selectActiveBranchList failed: " + e.getMessage());
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
        ui_room_grade = RoomTypeUtil.normalizeUiGrade(ui_room_grade);
        java.util.ArrayList<String> gradeParams = new java.util.ArrayList<String>();
        String gradeSql = RoomTypeUtil.buildGradeInSql(ui_room_grade, gradeParams);

        try {
            con = dbDirectConnect();
            String sql = "SELECT r.room_grade, r.room_type, MIN(r.room_price) AS room_price, COUNT(*) AS cnt "
                    + "FROM room r "
                    + "WHERE r.company_no = ? "
                    + gradeSql
                    + ROOM_OK
                    + BOOT_ROOM_BUSY
                    + "GROUP BY r.room_grade, r.room_type "
                    + "ORDER BY r.room_grade, r.room_type";

            pstmt = con.prepareStatement(sql);
            int idx = 1;
            pstmt.setInt(idx++, company_no);
            for (String g : gradeParams) {
                pstmt.setString(idx++, g);
            }
            pstmt.setString(idx++, boot_checkout);
            pstmt.setString(idx++, boot_checkin);
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
                    + "WHERE r.company_no = ? AND TRIM(r.room_grade) = TRIM(?) AND r.room_type = ? "
                    + ROOM_OK
                    + BOOT_ROOM_BUSY
                    + " ";

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
                    + "WHERE r.company_no = ? AND TRIM(r.room_grade) = TRIM(?) AND r.room_type = ? "
                    + ROOM_OK
                    + BOOT_ROOM_BUSY;

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

    /** DB boot_seq 시퀀스로 boot_no 채번 */
    private int allocateNextBootNo(Connection con) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = con.prepareStatement("SELECT boot_seq.NEXTVAL AS next_no FROM DUAL");
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("next_no");
            }
            return 1;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (ps != null) try { ps.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
    }

    private void bindBootNo(PreparedStatement pstmt, int index, String boot_no) throws SQLException {
        if (boot_no == null || boot_no.trim().isEmpty()) {
            pstmt.setNull(index, java.sql.Types.NUMERIC);
            return;
        }
        try {
            pstmt.setLong(index, Long.parseLong(boot_no.trim()));
        } catch (NumberFormatException e) {
            pstmt.setString(index, boot_no.trim());
        }
    }

    /**
     * [메소드명 변경] insertBoot → executeInsertReservation
     * 신규 예약 건수 오라클에 원자적 적재
     */
    public boolean executeInsertReservation(BootVO vo) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean flag = false;

        String reservation_code = String.valueOf(100000 + new Random().nextInt(900000));

        try {
            con = dbDirectConnect();
            con.setAutoCommit(false);

            int boot_no = allocateNextBootNo(con);
            String db_grade = RoomTypeUtil.toDbGrade(vo.getRoom_grade());

            String sql = "INSERT INTO boot ("
                    + "boot_no, room_grade, room_type, room_no, company_no, member_id, "
                    + "boot_phone, boot_name, boot_email, boot_checkin, boot_checkout, "
                    + "boot_adult, boot_child, boot_pay_check, boot_please, boot_confirm, reservation_code"
                    + ") VALUES (?,?,?,?,?,?,?,?,?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?)";

            pstmt = con.prepareStatement(sql);
            // 안될때 확인용으로 사용
            //System.out.println("[디버깅] 넘어온 회원ID: " + vo.getMember_id());
            //System.out.println("[디버깅] 넘어온 방번호: " + vo.getRoom_no());
            //System.out.println("[디버깅] 넘어온 회사번호: " + vo.getCompany_no());

            pstmt.setInt(1, boot_no);
            pstmt.setString(2, db_grade);
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
                if (vo.getRoom_no() > 0 && vo.getBoot_confirm() == CONFIRM_DONE) {
                    PreparedStatement roomPstmt = con.prepareStatement(
                            "UPDATE room SET room_now = '예약 중' WHERE room_no = ? AND company_no = ?");
                    roomPstmt.setInt(1, vo.getRoom_no());
                    roomPstmt.setInt(2, vo.getCompany_no());
                    roomPstmt.executeUpdate();
                    roomPstmt.close();
                }
                con.commit();
                vo.setBoot_no(String.valueOf(boot_no));
                vo.setReservation_code(reservation_code);
                flag = true;
            }
        } catch (Exception e) {
            System.err.println("[HotelDAO] executeInsertReservation failed: " + e.getMessage());
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
            bindBootNo(pstmt, 1, boot_no);
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

    /** wls 로그인(회원가입) 계정 — proid에 없을 때 member 조회 폴백 */
    private Connection scottFallbackConnect() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:orcl",
                "scott",
                "tiger");
    }

    private MemberVO queryMemberProfile(Connection con, String member_id) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT member_id, member_name, member_phone, member_email, member_address "
                    + "FROM member WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, member_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return parseClientData(rs);
            }
            if (rs != null) {
                rs.close();
                rs = null;
            }
            if (pstmt != null) {
                pstmt.close();
                pstmt = null;
            }
            sql = "SELECT member_id, member_name AS member_name, member_phone AS member_phone, "
                    + "member_email AS member_email, member_address AS member_address "
                    + "FROM member WHERE member_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, member_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return parseClientData(rs);
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return null;
    }

    /**
     * [메소드명 변경] getMember → selectClientProfile
     * 가입된 유저 프로필 인출기 (proid 우선, wls/scott 폴백)
     */
    public MemberVO selectClientProfile(String member_id) {
        if (member_id == null || member_id.trim().isEmpty()) {
            return null;
        }
        String id = member_id.trim();
        Connection con = null;
        Connection scottCon = null;
        try {
            con = dbDirectConnect();
            MemberVO vo = queryMemberProfile(con, id);
            if (vo != null) {
                return vo;
            }
        } catch (Exception e) {
            System.err.println("[HotelDAO] selectClientProfile(proid) failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        try {
            scottCon = scottFallbackConnect();
            return queryMemberProfile(scottCon, id);
        } catch (Exception e) {
            System.err.println("[HotelDAO] selectClientProfile(scott) failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (scottCon != null) try { scottCon.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return null;
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
        String resCode = rs.getString("reservation_code");
        if (resCode == null) {
            resCode = rs.getString("RESERVATION_CODE");
        }
        vo.setReservation_code(resCode);
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

    /* ═══ JSP 호환 alias (testex2) ═══ */

    public Vector<CompanyVO> getCompanyList(String keyword) {
        return selectActiveBranchList(keyword);
    }

    public CompanyVO getCompany(int company_no) {
        return selectBranchDetailByNo(company_no);
    }

    public Vector<RoomVO> getRoomList(int company_no, String ui_room_grade,
            String boot_checkin, String boot_checkout,
            int boot_adult, int boot_child, int rooms) {
        return selectAvailableRoomTypeList(company_no, ui_room_grade, boot_checkin, boot_checkout,
                boot_adult, boot_child, rooms);
    }

    public RoomVO getOneRoom(int company_no, String room_grade, int room_type,
            String boot_checkin, String boot_checkout) {
        return selectSingleRoomTypePriceInfo(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    }

    public int getEmptyRoomNo(int company_no, String room_grade, int room_type,
            String boot_checkin, String boot_checkout) {
        return assignEmptyRoomNumber(company_no, room_grade, room_type, boot_checkin, boot_checkout);
    }

    public boolean insertBoot(BootVO vo) {
        return executeInsertReservation(vo);
    }

    public BootVO getBoot(String boot_no) {
        return selectReservationReceipt(boot_no);
    }

    public Vector<BootVO> getBootListByMemberId(String member_id) {
        return selectReservationHistoryByMember(member_id);
    }

    public MemberVO getMember(String member_id) {
        return selectClientProfile(member_id);
    }
}