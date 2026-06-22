package com.jyphotel;

import java.sql.Connection;
import java.sql.DriverManager;
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
    /** 점검·청소·宿泊中 만 제외 — 날짜 충돌은 BOOT_ROOM_BUSY 로 판단 */
    private static final String ROOM_OK =
            " AND TRIM(r.room_now) NOT IN ('청소 중', '점검 중', '清掃중', '点検중', '宿泊중') ";

    /** 확정 예약만 객실 점유로 간주 */
    private static final String BOOT_ROOM_BUSY =
            " AND r.room_no NOT IN ( "
            + "   SELECT b.room_no FROM boot b "
            + "   WHERE b.room_no IS NOT NULL AND b.boot_confirm = 1 "
            + "     AND b.boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
            + "     AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
            + " ) ";

    /** context.xml() 기준 — SID/서비스명 환경 차이 대비 후보 URL */
    private static final String DB_USER = "scott";
    private static final String DB_PASS = "tiger";
    private static final String[] DB_URLS = {
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
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
    public int updateMemberCountUp(String memberId) throws Exception {
        String sql = "update member set member_count = member_count + 1 where member_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, memberId);

            return pstmt.executeUpdate();
        }
    }
    
    public int updateMemberCountDown(String memberId) throws Exception {
        String sql = "UPDATE MEMBER SET MEMBER_COUNT = NVL(MEMBER_COUNT, 0) - 1 WHERE MEMBER_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, memberId);

            return pstmt.executeUpdate();
        }
    }
    
    private Connection getConnection() {
		// TODO Auto-generated method stub
		return null;
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

    /** 메인(wls) dest 파라미터 → company_no (DB 조회 우선, 실패 시 1=東京/2=新宿/3=横浜) */
    public int resolveCompanyNoByDest(String dest) {
        if (dest == null || dest.trim().isEmpty()) {
            return 0;
        }
        String d = dest.trim();
        Vector<CompanyVO> list = selectActiveBranchList(convertBranchKeyword(d));
        if (list.size() > 0) {
            return list.elementAt(0).getCompany_no();
        }
        if (d.contains("도쿄") || d.contains("東京") || "tokyo".equalsIgnoreCase(d)) {
            return 1;
        }
        if (d.contains("신주쿠") || d.contains("新宿") || "shinjuku".equalsIgnoreCase(d)) {
            return 2;
        }
        if (d.contains("요코하마") || d.contains("横浜") || "yokohama".equalsIgnoreCase(d)) {
            return 3;
        }
        return 0;
    }

    /**
     * 지점 목록 조회 (등록된 객실 타입 수 — 날짜 미지정)
     */
    public Vector<CompanyVO> selectActiveBranchList(String keyword) {
        return selectActiveBranchList(keyword, "", "", 1, 0);
    }

    /**
     * 지점 목록 조회 — 체크인·인원이 있으면 예약 가능 (등급+타입) 수로 room_type_count 갱신
     */
    public Vector<CompanyVO> selectActiveBranchList(String keyword,
            String boot_checkin, String boot_checkout,
            int boot_adult, int boot_child) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CompanyVO> list = new Vector<CompanyVO>();

        try {
            con = dbDirectConnect();
            String searchWord = convertBranchKeyword(keyword);
            String sql = "SELECT c.company_no, c.company_name, "
                    + "(SELECT COUNT(DISTINCT r.room_grade || '-' || r.room_type) "
                    + " FROM room r WHERE r.company_no = c.company_no) AS type_cnt, "
                    + "NVL((SELECT ROUND(AVG(rv.rating), 1) FROM review rv "
                    + " WHERE rv.company_no = c.company_no), 0) AS avg_rating "
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
                vo.setRating(rs.getDouble("avg_rating"));
                HotelDisplay.setCompanyInfo(vo);
                list.addElement(vo);
            }

            boolean useAvailability = boot_checkin != null && !boot_checkin.trim().isEmpty();
            if (useAvailability) {
                String checkout = boot_checkout;
                if (checkout == null || checkout.trim().isEmpty()) {
                    checkout = HotelPriceUtil.calcCheckout(boot_checkin.trim(), 1);
                }
                for (int i = 0; i < list.size(); i++) {
                    CompanyVO vo = list.elementAt(i);
                    vo.setRoom_type_count(countAvailableRoomTypes(
                            vo.getCompany_no(), boot_checkin.trim(), checkout.trim(),
                            boot_adult, boot_child));
                }
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

    /** 지점별 예약 가능 (room_grade + room_type) 조합 수 — selectAvailableRoomTypeList 와 동일 조건, 전 등급 */
    public int countAvailableRoomTypes(int company_no, String boot_checkin, String boot_checkout,
            int boot_adult, int boot_child) {

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = dbDirectConnect();
            String sql = "SELECT r.room_type, COUNT(*) AS cnt "
                    + "FROM room r "
                    + "WHERE r.company_no = ? "
                    + ROOM_OK
                    + BOOT_ROOM_BUSY
                    + "GROUP BY r.room_grade, r.room_type ";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            pstmt.setString(2, boot_checkout);
            pstmt.setString(3, boot_checkin);
            rs = pstmt.executeQuery();

            boolean showSingle = RoomTypeUtil.canShowSingleRoom(boot_adult, boot_child);
            int guestCount = boot_adult + boot_child;

            while (rs.next()) {
                int room_type = rs.getInt("room_type");
                int cnt = rs.getInt("cnt");
                if (cnt <= 0) {
                    continue;
                }
                if (room_type == RoomTypeUtil.ROOM_TYPE_SINGLE && !showSingle) {
                    continue;
                }
                if (guestCount > RoomTypeUtil.getMaxGuests(room_type)) {
                    continue;
                }
                count++;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return count;
    }

    /** 특정 지점 단건 정보 조회 */
    public CompanyVO selectBranchDetailByNo(int company_no) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        CompanyVO vo = null;

        try {
            con = dbDirectConnect();
            String sql = "SELECT c.company_no, c.company_name, "
                    + "NVL((SELECT ROUND(AVG(rv.rating), 1) FROM review rv "
                    + " WHERE rv.company_no = c.company_no), 0) AS avg_rating "
                    + "FROM company c WHERE c.company_no = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, company_no);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vo = new CompanyVO();
                vo.setCompany_no(rs.getInt("company_no"));
                vo.setCompany_name(rs.getString("company_name"));
                vo.setRating(rs.getDouble("avg_rating"));
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

    /** 조건에 맞는 객실 타입 목록 */
    public Vector<RoomVO> selectAvailableRoomTypeList(int company_no, String ui_room_grade,
            String boot_checkin, String boot_checkout,
            int boot_adult, int boot_child) {

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

            boolean showSingle = RoomTypeUtil.canShowSingleRoom(boot_adult, boot_child);

            int guestCount = boot_adult + boot_child;

            while (rs.next()) {
                int room_type = rs.getInt("room_type");
                if (room_type == RoomTypeUtil.ROOM_TYPE_SINGLE && !showSingle) {
                    continue;
                }
                if (guestCount > RoomTypeUtil.getMaxGuests(room_type)) {
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

    /** 예약 단건 객실 요금·가용 수 조회 */
    public RoomVO selectSingleRoomTypePriceInfo(int company_no, String room_grade, int room_type,
            String boot_checkin, String boot_checkout) {

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        RoomVO vo = null;

        java.util.ArrayList<String> gradeParams = new java.util.ArrayList<String>();
        String gradeSql = RoomTypeUtil.buildGradeInSql(
                RoomTypeUtil.toUiGrade(room_grade), gradeParams);
        if (gradeParams.isEmpty()) {
            gradeParams.add(room_grade == null ? "STANDARD" : room_grade.trim());
            gradeSql = " AND TRIM(r.room_grade) IN (?) ";
        }

        try {
            con = dbDirectConnect();
            String sql = "SELECT MIN(r.room_price) AS room_price, COUNT(*) AS cnt "
                    + "FROM room r "
                    + "WHERE r.company_no = ? "
                    + gradeSql
                    + " AND r.room_type = ? "
                    + ROOM_OK
                    + BOOT_ROOM_BUSY
                    + " ";

            pstmt = con.prepareStatement(sql);
            int idx = 1;
            pstmt.setInt(idx++, company_no);
            for (String g : gradeParams) {
                pstmt.setString(idx++, g);
            }
            pstmt.setInt(idx++, room_type);
            pstmt.setString(idx++, boot_checkout);
            pstmt.setString(idx++, boot_checkin);
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
     * boot.member_id FK — member 테이블에 실제 존재하는 ID만 반환 (없으면 null)
     */
    public String resolveMemberIdForReservation(String member_id) {
        if (member_id == null || member_id.trim().isEmpty()) {
            return null;
        }
        MemberVO profile = selectClientProfile(member_id.trim());
        return profile != null ? profile.getMember_id() : null;
    }

    /** 신규 예약 boot INSERT */
    public boolean executeInsertReservation(BootVO vo) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean flag = false;

        boolean isOnsitePay = vo.getBoot_pay_check() == PAY_CHECK_ONSITE;
        String reservation_code = null;
        if (!isOnsitePay) {
            reservation_code = String.valueOf(100000 + new Random().nextInt(900000));
        }

        try {
            con = dbDirectConnect();
            con.setAutoCommit(false);

            int boot_no = allocateNextBootNo(con);
            String db_grade = vo.getRoom_grade();
            if (db_grade == null || db_grade.trim().isEmpty()) {
                db_grade = RoomTypeUtil.toDbGrade(null);
            } else {
                db_grade = db_grade.trim();
            }

            String sql = "INSERT INTO boot ("
                    + "boot_no, room_grade, room_type, room_no, company_no, member_id, "
                    + "boot_phone, boot_name, boot_email, boot_checkin, boot_checkout, "
                    + "boot_adult, boot_child, boot_pay_check, boot_please, boot_confirm, reservation_code"
                    + ") VALUES (?,?,?,?,?,?,?,?,?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, ?, ?)";

            pstmt = con.prepareStatement(sql);

            pstmt.setInt(1, boot_no);
            pstmt.setString(2, db_grade);
            pstmt.setInt(3, vo.getRoom_type());
            if (vo.getRoom_no() > 0) {
                pstmt.setInt(4, vo.getRoom_no());
            } else {
                pstmt.setNull(4, java.sql.Types.NUMERIC);
            }
            pstmt.setInt(5, vo.getCompany_no());

            String memberId = resolveMemberIdForReservation(vo.getMember_id());
            if (memberId != null) {
                pstmt.setString(6, memberId);
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
            if (reservation_code != null) {
                pstmt.setString(17, reservation_code);
            } else {
                pstmt.setNull(17, java.sql.Types.VARCHAR);
            }

            int count = pstmt.executeUpdate();
            if (count > 0) {
                con.commit();
                vo.setBoot_no(String.valueOf(boot_no));
                vo.setReservation_code(reservation_code);
                flag = true;
            }
        } catch (Exception e) {
            lastDbError = e.getMessage();
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
     * 결제 완료 메모만 boot_please 에 추가 (방 배정·boot_confirm 은 관리자 처리)
     */
    public boolean appendBootPaymentNote(String boot_no, String pleaseAppend) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean ok = false;

        try {
            con = dbDirectConnect();
            String sql = "UPDATE boot SET boot_please = boot_please || ? WHERE boot_no = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, pleaseAppend == null ? "" : pleaseAppend);
            bindBootNo(pstmt, 2, boot_no);
            ok = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[HotelDAO] appendBootPaymentNote failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return ok;
    }

    /** 🎯 [교정 완결] 예약 영수증 단건 조회 (PAYMENT_STATUS 컬럼 아웃조인 추가) */
    public BootVO selectReservationReceipt(String boot_no) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BootVO vo = null;

        try {
            con = dbDirectConnect();
            // 💡 장부 상태 확인을 위해 PAYMENT 테이블을 reservation_id 기준으로 LEFT OUTER JOIN 합니다.
            String sql = "SELECT b.*, c.company_name, p.PAYMENT_STATUS, "
                    + "TO_CHAR(b.boot_checkin, 'YYYY-MM-DD') AS ci, "
                    + "TO_CHAR(b.boot_checkout, 'YYYY-MM-DD') AS co "
                    + "FROM boot b "
                    + "LEFT JOIN company c ON c.company_no = b.company_no "
                    + "LEFT OUTER JOIN payment p ON b.boot_no = p.reservation_id "
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

    /** 🎯 [교정 완결] 회원별 예약 내역 (PAYMENT_STATUS 컬럼 아웃조인 추가) */
    public Vector<BootVO> selectReservationHistoryByMember(String member_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<BootVO> list = new Vector<BootVO>();

        try {
            con = dbDirectConnect();
            String sql = "SELECT b.*, c.company_name, p.PAYMENT_STATUS, "
                    + "TO_CHAR(b.boot_checkin, 'YYYY-MM-DD') AS ci, "
                    + "TO_CHAR(b.boot_checkout, 'YYYY-MM-DD') AS co "
                    + "FROM boot b "
                    + "LEFT JOIN company c ON c.company_no = b.company_no "
                    + "LEFT OUTER JOIN payment p ON b.boot_no = p.reservation_id "
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

    /** 회원 프로필 조회 */
    public MemberVO selectClientProfile(String member_id) {
        if (member_id == null || member_id.trim().isEmpty()) {
            return null;
        }
        String id = member_id.trim();
        Connection con = null;
        try {
            con = dbDirectConnect();
            return queryMemberProfile(con, id);
        } catch (Exception e) {
            System.err.println("[HotelDAO] selectClientProfile failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return null;
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
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException s) { s.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException s) { s.printStackTrace(); }
        }
        return null;
    }

    /** 🎯 [교정 완결] 가방(BootVO)에 오라클 결제 상태 문자열 바인딩 추가 */
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
        
        // 🎯 [추가 포인트] 조인으로 퍼 올린 PAYMENT_STATUS 문자열을 BootVO 객체에 주입!
        vo.setPaymentStatus(rs.getString("PAYMENT_STATUS"));

        String resCode = rs.getString("reservation_code");
        if (resCode == null) {
            resCode = rs.getString("RESERVATION_CODE");
        }
        vo.setReservation_code(resCode);
        return vo;
    }

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