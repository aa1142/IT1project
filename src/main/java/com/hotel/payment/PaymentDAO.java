package com.hotel.payment;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PaymentDAO {

    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "scott",
            "tiger"
        );
    }

    /** PAYMENT.RESERVATION_ID = boot_no (NUMBER) */
    private void bindReservationId(PreparedStatement pstmt, int index, String bootNo) throws Exception {
        if (bootNo == null || bootNo.trim().isEmpty()) {
            pstmt.setNull(index, java.sql.Types.NUMERIC);
            return;
        }
        pstmt.setLong(index, Long.parseLong(bootNo.trim()));
    }

    /**
     * 예약 금액 조회
     */
    public int getRoomTotalAmountFromDB(String bootNo) throws Exception {
        String sql = "SELECT AMOUNT FROM PAYMENT WHERE RESERVATION_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("AMOUNT");
                }
            }
        }
        return 0;
    }

    /**
     * 결제 상태 조회
     */
    public String getPaymentStatus(String bootNo) throws Exception {
        String sql = "SELECT PAYMENT_STATUS FROM PAYMENT WHERE RESERVATION_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("PAYMENT_STATUS");
                }
            }
        }
        return null;
    }

    /**
     * 결제 INSERT (예약 생성 시 1회만 사용)
     */
    public int insertPayment(PaymentDTO dto) throws Exception {
        String sql =
            "INSERT INTO PAYMENT " +
            "(PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, APPROVED_AT) " +
            "VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, dto.getBootNo());
            pstmt.setString(2, dto.getTid());
            pstmt.setString(3, dto.getPartnerOrderId());
            pstmt.setString(4, dto.getPaymentMethod());
            pstmt.setInt(5, dto.getAmount());
            pstmt.setString(6, dto.getPaymentStatus());

            return pstmt.executeUpdate();
        }
    }

    /**
     * 예약 생성 시 결제 대기 INSERT
     */
    public int insertPendingPayment(String bootNo, int amount, String paymentMethod) throws Exception {
        String sql =
            "INSERT INTO PAYMENT " +
            "(PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) " +
            "VALUES (PAYMENT_SEQ.NEXTVAL, ?, NULL, ?, ?, ?, 'PENDING')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);
            pstmt.setString(2, bootNo);
            pstmt.setString(3, paymentMethod);
            pstmt.setInt(4, amount);

            return pstmt.executeUpdate();
        }
    }

    /**
     * 현장 결제 INSERT
     */
    public int insertOnsitePayment(String bootNo, int amount) throws Exception {
        String sql =
            "INSERT INTO PAYMENT " +
            "(PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) " +
            "VALUES (PAYMENT_SEQ.NEXTVAL, ?, NULL, ?, 'ONSITE', ?, 'AWAITING')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);
            pstmt.setString(2, bootNo);
            pstmt.setInt(3, amount);

            return pstmt.executeUpdate();
        }
    }

    /**
     * 🔥 카카오 결제 승인 (핵심 수정본)
     * → INSERT fallback 제거
     * → UPDATE 성공 여부만 사용
     */
    public int completeKakaoPayment(String bootNo, String tid, int amount) throws Exception {

        String sql =
            "UPDATE PAYMENT " +
            "SET TID = ?, PAYMENT_STATUS = 'PAID', APPROVED_AT = SYSDATE " +
            "WHERE RESERVATION_ID = ? " +
            "AND PAYMENT_STATUS <> 'PAID'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, tid);
            bindReservationId(pstmt, 2, bootNo);

            return pstmt.executeUpdate(); // 1 = 최초 결제 성공, 0 = 중복 호출
        }
    }

    /**
     * 환불용 PAID 조회
     */
    public PaymentDTO findPaidPaymentByBootNo(String bootNo) throws Exception {
        String sql =
            "SELECT PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, APPROVED_AT " +
            "FROM PAYMENT " +
            "WHERE RESERVATION_ID = ? AND PAYMENT_STATUS = 'PAID'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    PaymentDTO dto = new PaymentDTO();
                    dto.setPaymentId(rs.getInt("PAYMENT_ID"));
                    dto.setBootNo(rs.getString("RESERVATION_ID"));
                    dto.setTid(rs.getString("TID"));
                    dto.setPartnerOrderId(rs.getString("PARTNER_ORDER_ID"));
                    dto.setPaymentMethod(rs.getString("PAYMENT_METHOD"));
                    dto.setAmount(rs.getInt("AMOUNT"));
                    dto.setPaymentStatus(rs.getString("PAYMENT_STATUS"));
                    dto.setCreatedAt(String.valueOf(rs.getTimestamp("APPROVED_AT")));
                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 상태 변경 (범용)
     */
    public int updatePaymentStatus(String bootNo, String status) throws Exception {

        String sql =
            "UPDATE PAYMENT " +
            "SET PAYMENT_STATUS = ?, APPROVED_AT = SYSDATE " +
            "WHERE RESERVATION_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            bindReservationId(pstmt, 2, bootNo);

            return pstmt.executeUpdate();
        }
    }
}