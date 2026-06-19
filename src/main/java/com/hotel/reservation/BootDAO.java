package com.hotel.reservation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

public class BootDAO {
    
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "scott",
            "tiger"
        );
    }
    
    /**
     * 1. [조회 완결] 카카오페이 통신용 예약 코드 + 연락처 또는 이메일 검증 단건 조회 (마이페이지용)
     * 🎯 리팩토링 포인트: PAYMENT 테이블을 조인하여 진짜 결제 상태(PAYMENT_STATUS)를 함께 인출합니다.
     */
    public BootDTO findByReservationCodeAndPhoneOrEmail(String reservationCode, String keyword) throws Exception {
        String sql =
            "SELECT b.BOOT_NO, b.ROOM_GRADE, b.ROOM_TYPE, b.ROOM_NO, b.COMPANY_NO, b.MEMBER_ID, " +
            "b.BOOT_PHONE, b.BOOT_NAME, b.BOOT_EMAIL, b.BOOT_CHECKIN, b.BOOT_CHECKOUT, " +
            "b.BOOT_ADULT, b.BOOT_CHILD, b.BOOT_PAY_CHECK, b.BOOT_PLEASE, b.BOOT_CONFIRM, b.RESERVATION_CODE, " +
            "p.PAYMENT_STATUS, p.AMOUNT AS PAYMENT_AMOUNT " +
            "FROM BOOT b " +
            "LEFT OUTER JOIN PAYMENT p ON b.BOOT_NO = p.RESERVATION_ID " +
            "WHERE b.RESERVATION_CODE = ? " +
            "AND (b.BOOT_PHONE = ? OR LOWER(b.BOOT_EMAIL) = LOWER(?))";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, reservationCode);
            pstmt.setString(2, keyword);
            pstmt.setString(3, keyword);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BootDTO dto = new BootDTO();

                    dto.setBootNo(rs.getString("BOOT_NO"));
                    dto.setRoomGrade(rs.getString("ROOM_GRADE"));
                    dto.setRoomType(rs.getInt("ROOM_TYPE"));
                    dto.setRoomNo(rs.getInt("ROOM_NO"));
                    dto.setCompanyNo(rs.getInt("COMPANY_NO"));
                    dto.setMemberId(rs.getString("MEMBER_ID"));
                    dto.setBootPhone(rs.getString("BOOT_PHONE"));
                    dto.setBootName(rs.getString("BOOT_NAME"));
                    dto.setBootEmail(rs.getString("BOOT_EMAIL"));
                    dto.setBootCheckin(String.valueOf(rs.getDate("BOOT_CHECKIN")));
                    dto.setBootCheckout(String.valueOf(rs.getDate("BOOT_CHECKOUT")));
                    dto.setBootAdult(rs.getInt("BOOT_ADULT"));
                    dto.setBootChild(rs.getInt("BOOT_CHILD"));
                    dto.setBootPayCheck(rs.getInt("BOOT_PAY_CHECK"));
                    dto.setBootPlease(rs.getString("BOOT_PLEASE"));
                    dto.setBootConfirm(rs.getInt("BOOT_CONFIRM"));
                    dto.setReservationCode(rs.getString("RESERVATION_CODE"));
                    dto.setPaymentStatus(rs.getString("PAYMENT_STATUS"));
                    dto.setPaymentAmount(rs.getInt("PAYMENT_AMOUNT"));

                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 2. [조회 백업 완결] 카카오페이 통신용 예약 코드 + 연락처 기반 단건 검증 조회
     * 🎯 리팩토링 포인트: 백업용 조회 메서드 역시 PAYMENT 테이블 조인 규격을 동일하게 맞춥니다.
     */
    public BootDTO findByReservationCodeAndPhone(String reservationCode, String bookerPhone) throws Exception {
        String sql =
            "SELECT b.BOOT_NO, b.ROOM_GRADE, b.ROOM_TYPE, b.ROOM_NO, b.COMPANY_NO, b.MEMBER_ID, " +
            "b.BOOT_PHONE, b.BOOT_NAME, b.BOOT_EMAIL, b.BOOT_CHECKIN, b.BOOT_CHECKOUT, " +
            "b.BOOT_ADULT, b.BOOT_CHILD, b.BOOT_PAY_CHECK, b.BOOT_PLEASE, b.BOOT_CONFIRM, b.RESERVATION_CODE, " +
            "p.PAYMENT_STATUS, p.AMOUNT AS PAYMENT_AMOUNT " +
            "FROM BOOT b " +
            "LEFT OUTER JOIN PAYMENT p ON b.BOOT_NO = p.RESERVATION_ID " +
            "WHERE b.RESERVATION_CODE = ? AND b.BOOT_PHONE = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, reservationCode);
            pstmt.setString(2, bookerPhone);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BootDTO dto = new BootDTO();

                    dto.setBootNo(rs.getString("BOOT_NO"));
                    dto.setRoomGrade(rs.getString("ROOM_GRADE"));
                    dto.setRoomType(rs.getInt("ROOM_TYPE"));
                    dto.setRoomNo(rs.getInt("ROOM_NO"));
                    dto.setCompanyNo(rs.getInt("COMPANY_NO"));
                    dto.setMemberId(rs.getString("MEMBER_ID"));
                    dto.setBootPhone(rs.getString("BOOT_PHONE"));
                    dto.setBootName(rs.getString("BOOT_NAME"));
                    dto.setBootEmail(rs.getString("BOOT_EMAIL"));
                    dto.setBootCheckin(String.valueOf(rs.getDate("BOOT_CHECKIN")));
                    dto.setBootCheckout(String.valueOf(rs.getDate("BOOT_CHECKOUT")));
                    dto.setBootAdult(rs.getInt("BOOT_ADULT"));
                    dto.setBootChild(rs.getInt("BOOT_CHILD"));
                    dto.setBootPayCheck(rs.getInt("BOOT_PAY_CHECK"));
                    dto.setBootPlease(rs.getString("BOOT_PLEASE"));
                    dto.setBootConfirm(rs.getInt("BOOT_CONFIRM"));
                    dto.setReservationCode(rs.getString("RESERVATION_CODE"));
                    dto.setPaymentStatus(rs.getString("PAYMENT_STATUS"));
                    dto.setPaymentAmount(rs.getInt("PAYMENT_AMOUNT"));

                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 3. [등록] 초기 예약 데이터 적재 (초기 상태 BOOT_CONFIRM = 0 설정)
     * VARCHAR2(30) 규격의 BOOT_NO 고유 PK를 시퀀스와 결합하여 생성 후 저장합니다.
     */
    public String insertReservation(BootDTO dto) throws Exception {
        String timeStamp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String resCode = "ORD" + timeStamp;
        dto.setReservationCode(resCode);

        String seqSql = "SELECT RESERVATION_SEQ.NEXTVAL FROM DUAL";
        String insertSql =
            "INSERT INTO BOOT " +
            "(BOOT_NO, ROOM_GRADE, ROOM_TYPE, ROOM_NO, COMPANY_NO, MEMBER_ID, " +
            "BOOT_PHONE, BOOT_NAME, BOOT_EMAIL, BOOT_CHECKIN, BOOT_CHECKOUT, " +
            "BOOT_ADULT, BOOT_CHILD, BOOT_PAY_CHECK, BOOT_PLEASE, BOOT_CONFIRM, RESERVATION_CODE) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?, 0, ?)";

        try (Connection conn = getConnection();
             PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
             PreparedStatement pstmt = conn.prepareStatement(insertSql)) {

            long seqVal = 1;
            try (ResultSet rs = seqPstmt.executeQuery()) {
                if (rs.next()) {
                    seqVal = rs.getLong(1);
                }
            }
            
            String bootNoStr = "B" + timeStamp.substring(0, 8) + "-" + String.format("%06d", seqVal);
            dto.setBootNo(bootNoStr);

            pstmt.setString(1, dto.getBootNo());
            pstmt.setString(2, dto.getRoomGrade());
            pstmt.setInt(3, dto.getRoomType());
            
            if(dto.getRoomNo() == 0) pstmt.setNull(4, java.sql.Types.NUMERIC);
            else pstmt.setInt(4, dto.getRoomNo());

            if(dto.getCompanyNo() == 0) pstmt.setNull(5, java.sql.Types.NUMERIC);
            else pstmt.setInt(5, dto.getCompanyNo());

            pstmt.setString(6, dto.getMemberId());
            pstmt.setString(7, dto.getBootPhone());
            pstmt.setString(8, dto.getBootName());
            pstmt.setString(9, dto.getBootEmail());
            pstmt.setString(10, dto.getBootCheckin());
            pstmt.setString(11, dto.getBootCheckout());
            pstmt.setInt(12, dto.getBootAdult());

            if(dto.getBootChild() == 0) pstmt.setNull(13, java.sql.Types.NUMERIC);
            else pstmt.setInt(13, dto.getBootChild());
            
            pstmt.setInt(14, dto.getBootPayCheck());
            pstmt.setString(15, dto.getBootPlease());
            pstmt.setString(16, dto.getReservationCode());

            pstmt.executeUpdate();
            
            return dto.getBootNo();
        }
    }

    /**
     * 4. [수정] 결제 완료 시 상태 승인 처리 (0: 대기 -> 1: 완료)
     */
    public int updateReservationStatus(String bootNo, int status) throws Exception {
        String sql = "UPDATE BOOT SET BOOT_CONFIRM = ? WHERE BOOT_NO = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);
            pstmt.setString(2, bootNo);

            return pstmt.executeUpdate();
        }
    }
}