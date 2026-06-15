package com.jyphotel;

import com.jyphotel.ReservationVO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * =====================================================================
 * ReservationDAO.java  —  호텔 예약 데이터 접근 객체 (Data Access Object)
 * =====================================================================
 * Oracle DB 의 RESERVATION 테이블과 JDBC 로 통신합니다.
 *
 * [사전 준비]
 *   1. Oracle JDBC 드라이버(ojdbc8.jar)를 WEB-INF/lib 에 추가
 *   2. 아래 DB 접속 정보를 실제 환경에 맞게 수정
 *   3. 아래 CREATE TABLE 문으로 테이블을 미리 생성
 *
 * [테이블 DDL]  — Oracle SQL
 * ──────────────────────────────────────────────────────────────────
 * CREATE SEQUENCE SEQ_RESERVATION_NO START WITH 1 INCREMENT BY 1;
 *
 * CREATE TABLE RESERVATION (
 *   RESERVATION_NO      NUMBER         PRIMARY KEY,          -- 예약번호
 *   RESERVATION_STATUS  VARCHAR2(20)   DEFAULT 'PENDING',    -- 상태
 *   CREATED_AT          TIMESTAMP      DEFAULT SYSTIMESTAMP, -- 생성일시
 *
 *   HOTEL_NAME          VARCHAR2(100),  -- 호텔명
 *   ROOM_GRADE          VARCHAR2(100),  -- 객실 등급
 *   ROOM_CLASS          VARCHAR2(50),   -- 스탠다드/디럭스/스위트
 *   CAPACITY            VARCHAR2(50),   -- 최대 수용 인원
 *
 *   CHECKIN             VARCHAR2(20),   -- 체크인  YYYY-MM-DD
 *   CHECKOUT            VARCHAR2(20),   -- 체크아웃 YYYY-MM-DD
 *   CHECKIN_LABEL       VARCHAR2(100),  -- 체크인 한국어 표시
 *   CHECKOUT_LABEL      VARCHAR2(100),  -- 체크아웃 한국어 표시
 *   NIGHTS              NUMBER(3),      -- 숙박 일수
 *   ROOMS               NUMBER(3),      -- 방 수
 *
 *   ADULTS              NUMBER(3),      -- 성인 수
 *   CHILDREN            NUMBER(3),      -- 어린이 수
 *   BASE_PRICE          NUMBER(10),     -- 1박 단가
 *   TOTAL_PRICE         NUMBER(10),     -- 객실 합계
 *
 *   GUEST_LAST_NAME     VARCHAR2(50),   -- 숙박자 성
 *   GUEST_FIRST_NAME    VARCHAR2(50),   -- 숙박자 이름
 *   GUEST_PHONE         VARCHAR2(30),   -- 숙박자 전화
 *
 *   BOOKER_LAST_NAME    VARCHAR2(50),   -- 예약자 성
 *   BOOKER_FIRST_NAME   VARCHAR2(50),   -- 예약자 이름
 *   BOOKER_PHONE        VARCHAR2(30),   -- 예약자 전화
 *   BOOKER_EMAIL        VARCHAR2(100),  -- 예약자 이메일
 *   POSTAL_CODE         VARCHAR2(20),   -- 우편번호
 *   ADDRESS             VARCHAR2(300),  -- 주소
 *
 *   BREAKFAST_YN        CHAR(1)        DEFAULT 'N', -- 조식 선택 여부
 *   BREAKFAST_PRICE     NUMBER(10)     DEFAULT 0,   -- 조식 요금
 *   FAST_CHECKIN_YN     CHAR(1)        DEFAULT 'N', -- 빠른체크인 여부
 *   FAST_CHECKIN_PRICE  NUMBER(10)     DEFAULT 0,   -- 빠른체크인 요금
 *
 *   PAYMENT_METHOD      VARCHAR2(20),   -- card / onsite
 *   FINAL_PRICE         NUMBER(10)      -- 최종 결제 금액
 * );
 * ──────────────────────────────────────────────────────────────────
 */
public class ReservationDAO {

    /* ═══════════════════════════════════════════
       DB 접속 정보  ← 실제 환경에 맞게 수정
    ═══════════════════════════════════════════ */
    private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String URL    = "jdbc:oracle:thin:@localhost:1521:ORCL";  // SID 방식
    // 서비스명 방식: "jdbc:oracle:thin:@//localhost:1521/XEPDB1"
    private static final String USER   = "scott";   // DB 계정
    private static final String PASS   = "tiger";   // DB 비밀번호

    /* ═══════════════════════════════════════════
       SQL 상수
    ═══════════════════════════════════════════ */

    /** 예약 INSERT — 시퀀스로 기본키 자동 생성 */
    private static final String SQL_INSERT =
        "INSERT INTO RESERVATION ( " +
        "  RESERVATION_NO, RESERVATION_STATUS, " +
        "  HOTEL_NAME, ROOM_GRADE, ROOM_CLASS, CAPACITY, " +
        "  CHECKIN, CHECKOUT, CHECKIN_LABEL, CHECKOUT_LABEL, " +
        "  NIGHTS, ROOMS, ADULTS, CHILDREN, BASE_PRICE, TOTAL_PRICE, " +
        "  GUEST_LAST_NAME, GUEST_FIRST_NAME, GUEST_PHONE, " +
        "  BOOKER_LAST_NAME, BOOKER_FIRST_NAME, BOOKER_PHONE, " +
        "  BOOKER_EMAIL, POSTAL_CODE, ADDRESS, " +
        "  BREAKFAST_YN, BREAKFAST_PRICE, " +
        "  FAST_CHECKIN_YN, FAST_CHECKIN_PRICE, " +
        "  PAYMENT_METHOD, FINAL_PRICE " +
        ") VALUES ( " +
        "  SEQ_RESERVATION_NO.NEXTVAL, 'PENDING', " +
        "  ?, ?, ?, ?, " +
        "  ?, ?, ?, ?, " +
        "  ?, ?, ?, ?, ?, ?, " +
        "  ?, ?, ?, " +
        "  ?, ?, ?, " +
        "  ?, ?, ?, " +
        "  ?, ?, " +
        "  ?, ?, " +
        "  ?, ? " +
        ")";

    /** 방금 INSERT 된 예약번호 조회 */
    private static final String SQL_LAST_NO =
        "SELECT SEQ_RESERVATION_NO.CURRVAL FROM DUAL";

    /** 예약번호로 단건 조회 */
    private static final String SQL_SELECT_BY_NO =
        "SELECT * FROM RESERVATION WHERE RESERVATION_NO = ?";

    /** 예약자 이메일로 목록 조회 */
    private static final String SQL_SELECT_BY_EMAIL =
        "SELECT * FROM RESERVATION WHERE BOOKER_EMAIL = ? ORDER BY CREATED_AT DESC";

    /** 예약 상태 변경 (CONFIRMED / CANCELLED) */
    private static final String SQL_UPDATE_STATUS =
        "UPDATE RESERVATION SET RESERVATION_STATUS = ? WHERE RESERVATION_NO = ?";

    /** 전체 예약 목록 (관리자용) */
    private static final String SQL_SELECT_ALL =
        "SELECT * FROM RESERVATION ORDER BY CREATED_AT DESC";

    /** 예약 삭제 */
    private static final String SQL_DELETE =
        "DELETE FROM RESERVATION WHERE RESERVATION_NO = ?";


    /* ═══════════════════════════════════════════
       드라이버 로딩 (클래스 로드 시 1회 실행)
    ═══════════════════════════════════════════ */
    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Oracle JDBC 드라이버 로딩 실패: " + e.getMessage(), e);
        }
    }


    /* ═══════════════════════════════════════════
       공통 유틸: DB 연결
    ═══════════════════════════════════════════ */
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }


    /* ═══════════════════════════════════════════
       공통 유틸: 자원 해제
    ═══════════════════════════════════════════ */
    private void close(Connection con, PreparedStatement pst) {
        try { if (pst != null) pst.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    private void close(Connection con, PreparedStatement pst, ResultSet rs) {
        try { if (rs  != null) rs.close();  } catch (SQLException e) { e.printStackTrace(); }
        close(con, pst);
    }


    /* ═══════════════════════════════════════════
       INSERT: 예약 저장
         hotelreservation.jsp 의 handleReserve() 호출 시 사용
         반환값: 생성된 RESERVATION_NO (실패 시 -1)
    ═══════════════════════════════════════════ */
    public int insertReservation(ReservationVO vo) {
        Connection        con = null;
        PreparedStatement pst = null;
        ResultSet         rs  = null;
        int               reservationNo = -1;

        try {
            con = getConnection();
            con.setAutoCommit(false);   // 트랜잭션 시작

            pst = con.prepareStatement(SQL_INSERT);

            // ── 호텔 / 객실 정보
            pst.setString(1,  vo.getHotelName());
            pst.setString(2,  vo.getRoomGrade());
            pst.setString(3,  vo.getRoomClass());
            pst.setString(4,  vo.getCapacity());

            // ── 날짜
            pst.setString(5,  vo.getCheckin());
            pst.setString(6,  vo.getCheckout());
            pst.setString(7,  vo.getCheckinLabel());
            pst.setString(8,  vo.getCheckoutLabel());

            // ── 박수 / 인원 / 요금
            pst.setInt   (9,  vo.getNights());
            pst.setInt   (10, vo.getRooms());
            pst.setInt   (11, vo.getAdults());
            pst.setInt   (12, vo.getChildren());
            pst.setInt   (13, vo.getBasePrice());
            pst.setInt   (14, vo.getTotalPrice());

            // ── 숙박자 정보
            pst.setString(15, vo.getGuestLastName());
            pst.setString(16, vo.getGuestFirstName());
            pst.setString(17, vo.getGuestPhone());

            // ── 예약자 정보
            pst.setString(18, vo.getBookerLastName());
            pst.setString(19, vo.getBookerFirstName());
            pst.setString(20, vo.getBookerPhone());
            pst.setString(21, vo.getBookerEmail());
            pst.setString(22, vo.getPostalCode());
            pst.setString(23, vo.getAddress());

            // ── 추가 옵션
            pst.setString(24, vo.getBreakfastYn()    != null ? vo.getBreakfastYn()    : "N");
            pst.setInt   (25, vo.getBreakfastPrice());
            pst.setString(26, vo.getFastCheckinYn()  != null ? vo.getFastCheckinYn()  : "N");
            pst.setInt   (27, vo.getFastCheckinPrice());

            // ── 결제
            pst.setString(28, vo.getPaymentMethod());
            pst.setInt   (29, vo.getFinalPrice());

            pst.executeUpdate();

            // INSERT 된 시퀀스 번호 조회
            pst.close();
            pst = con.prepareStatement(SQL_LAST_NO);
            rs  = pst.executeQuery();
            if (rs.next()) {
                reservationNo = rs.getInt(1);
                vo.setReservationNo(reservationNo);
            }

            con.commit();   // 트랜잭션 커밋

        } catch (SQLException e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            close(con, pst, rs);
        }

        return reservationNo;
    }


    /* ═══════════════════════════════════════════
       SELECT: 예약번호로 단건 조회
    ═══════════════════════════════════════════ */
    public ReservationVO selectByNo(int reservationNo) {
        Connection        con = null;
        PreparedStatement pst = null;
        ResultSet         rs  = null;
        ReservationVO     vo  = null;

        try {
            con = getConnection();
            pst = con.prepareStatement(SQL_SELECT_BY_NO);
            pst.setInt(1, reservationNo);
            rs  = pst.executeQuery();

            if (rs.next()) {
                vo = mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(con, pst, rs);
        }

        return vo;
    }


    /* ═══════════════════════════════════════════
       SELECT: 이메일로 예약 목록 조회 (마이페이지용)
    ═══════════════════════════════════════════ */
    public List<ReservationVO> selectByEmail(String email) {
        Connection        con  = null;
        PreparedStatement pst  = null;
        ResultSet         rs   = null;
        List<ReservationVO> list = new ArrayList<>();

        try {
            con = getConnection();
            pst = con.prepareStatement(SQL_SELECT_BY_EMAIL);
            pst.setString(1, email);
            rs  = pst.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(con, pst, rs);
        }

        return list;
    }


    /* ═══════════════════════════════════════════
       SELECT: 전체 예약 목록 (관리자 페이지용)
    ═══════════════════════════════════════════ */
    public List<ReservationVO> selectAll() {
        Connection        con  = null;
        PreparedStatement pst  = null;
        ResultSet         rs   = null;
        List<ReservationVO> list = new ArrayList<>();

        try {
            con = getConnection();
            pst = con.prepareStatement(SQL_SELECT_ALL);
            rs  = pst.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(con, pst, rs);
        }

        return list;
    }


    /* ═══════════════════════════════════════════
       UPDATE: 예약 상태 변경
         status: "CONFIRMED" | "CANCELLED"
         반환값: 업데이트된 행 수 (1이면 성공)
    ═══════════════════════════════════════════ */
    public int updateStatus(int reservationNo, String status) {
        Connection        con    = null;
        PreparedStatement pst    = null;
        int               result = 0;

        try {
            con = getConnection();
            pst = con.prepareStatement(SQL_UPDATE_STATUS);
            pst.setString(1, status);
            pst.setInt   (2, reservationNo);
            result = pst.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(con, pst);
        }

        return result;
    }


    /* ═══════════════════════════════════════════
       DELETE: 예약 삭제
         반환값: 삭제된 행 수 (1이면 성공)
    ═══════════════════════════════════════════ */
    public int deleteReservation(int reservationNo) {
        Connection        con    = null;
        PreparedStatement pst    = null;
        int               result = 0;

        try {
            con = getConnection();
            pst = con.prepareStatement(SQL_DELETE);
            pst.setInt(1, reservationNo);
            result = pst.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(con, pst);
        }

        return result;
    }


    /* ═══════════════════════════════════════════
       공통 유틸: ResultSet → ReservationVO 변환
    ═══════════════════════════════════════════ */
    private ReservationVO mapRow(ResultSet rs) throws SQLException {
        ReservationVO vo = new ReservationVO();

        vo.setReservationNo     (rs.getInt      ("RESERVATION_NO"));
        vo.setReservationStatus (rs.getString   ("RESERVATION_STATUS"));
        vo.setCreatedAt         (rs.getTimestamp("CREATED_AT"));

        vo.setHotelName         (rs.getString("HOTEL_NAME"));
        vo.setRoomGrade         (rs.getString("ROOM_GRADE"));
        vo.setRoomClass         (rs.getString("ROOM_CLASS"));
        vo.setCapacity          (rs.getString("CAPACITY"));

        vo.setCheckin           (rs.getString("CHECKIN"));
        vo.setCheckout          (rs.getString("CHECKOUT"));
        vo.setCheckinLabel      (rs.getString("CHECKIN_LABEL"));
        vo.setCheckoutLabel     (rs.getString("CHECKOUT_LABEL"));
        vo.setNights            (rs.getInt   ("NIGHTS"));
        vo.setRooms             (rs.getInt   ("ROOMS"));

        vo.setAdults            (rs.getInt   ("ADULTS"));
        vo.setChildren          (rs.getInt   ("CHILDREN"));
        vo.setBasePrice         (rs.getInt   ("BASE_PRICE"));
        vo.setTotalPrice        (rs.getInt   ("TOTAL_PRICE"));

        vo.setGuestLastName     (rs.getString("GUEST_LAST_NAME"));
        vo.setGuestFirstName    (rs.getString("GUEST_FIRST_NAME"));
        vo.setGuestPhone        (rs.getString("GUEST_PHONE"));

        vo.setBookerLastName    (rs.getString("BOOKER_LAST_NAME"));
        vo.setBookerFirstName   (rs.getString("BOOKER_FIRST_NAME"));
        vo.setBookerPhone       (rs.getString("BOOKER_PHONE"));
        vo.setBookerEmail       (rs.getString("BOOKER_EMAIL"));
        vo.setPostalCode        (rs.getString("POSTAL_CODE"));
        vo.setAddress           (rs.getString("ADDRESS"));

        vo.setBreakfastYn       (rs.getString("BREAKFAST_YN"));
        vo.setBreakfastPrice    (rs.getInt   ("BREAKFAST_PRICE"));
        vo.setFastCheckinYn     (rs.getString("FAST_CHECKIN_YN"));
        vo.setFastCheckinPrice  (rs.getInt   ("FAST_CHECKIN_PRICE"));

        vo.setPaymentMethod     (rs.getString("PAYMENT_METHOD"));
        vo.setFinalPrice        (rs.getInt   ("FINAL_PRICE"));

        return vo;
    }
}