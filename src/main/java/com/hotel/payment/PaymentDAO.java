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
     * [사용자 전용 정품 메서드]
     * 오라클 테이블에서 예약번호 하나로 진짜 적재된 AMOUNT 금액을 직접 긁어옵니다.
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
     * 1. [등록] 카카오페이 최종 승인 완료된 결제 영수증 내역을 PAYMENT 테이블에 적재합니다.
     */
    public int insertPayment(PaymentDTO dto) throws Exception {
        String sql = "INSERT INTO PAYMENT (PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, APPROVED_AT) "
                   + "VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";

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
     * 예약 직후 결제 대기 건 등록 (온라인 결제 — 카카오페이 승인 전)
     */
    public int insertPendingPayment(String bootNo, int amount, String paymentMethod) throws Exception {
        // 기존 쿼리(RESERVATION_ID 타격)로 완벽 복구
        String sql = "INSERT INTO PAYMENT (PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) "
                + "VALUES (PAYMENT_SEQ.NEXTVAL, ?, NULL, ?, ?, ?, 'PENDING')";

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
     * 현장 결제 예약 — 결제 완료 전 현장 수납 예정 건
     */
    public int insertOnsitePayment(String bootNo, int amount) throws Exception {
        String sql = "INSERT INTO PAYMENT (PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) "
                + "VALUES (PAYMENT_SEQ.NEXTVAL, ?, NULL, ?, 'ONSITE', ?, 'AWAITING')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            bindReservationId(pstmt, 1, bootNo);
            pstmt.setString(2, bootNo);
            pstmt.setInt(3, amount);
            return pstmt.executeUpdate();
        }
    }

    /**
     * 카카오페이 승인 완료 — PENDING 건을 PAID 로 갱신 (없으면 신규 INSERT)
     */
    public int completeKakaoPayment(String bootNo, String tid, int amount) throws Exception {
        // 🎯 원래 RESERVATION_ID 조건절 유지하되, 카카오페이 승인 시각(APPROVED_AT = SYSDATE)을 확실하게 동기화해 줍니다.
        String updateSql = "UPDATE PAYMENT SET TID = ?, PAYMENT_STATUS = 'PAID', APPROVED_AT = SYSDATE "
                + "WHERE RESERVATION_ID = ? AND PAYMENT_STATUS IN ('PENDING', 'AWAITING')";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(updateSql)) {

            pstmt.setString(1, tid);
            bindReservationId(pstmt, 2, bootNo);
            int updated = pstmt.executeUpdate();
            if (updated > 0) {
                return updated;
            }
        }

        PaymentDTO dto = new PaymentDTO();
        dto.setBootNo(bootNo);
        dto.setTid(tid);
        dto.setPartnerOrderId(bootNo);
        dto.setPaymentMethod("KAKAOPAY");
        dto.setAmount(amount);
        dto.setPaymentStatus("PAID");
        return insertPayment(dto);
    }

    /**
     * 2. [조회] 환불 처리를 위해 RESERVATION_ID를 기준으로 정상 결제('PAID')된 영수증 내역을 찾아옵니다.
     */
    public PaymentDTO findPaidPaymentByBootNo(String bootNo) throws Exception {
        String sql = "SELECT PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, APPROVED_AT " +
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
     * 3. [수정] 결제 성공 시 상태를 'PAID'로 바꾸고, APPROVED_AT에 오라클 현재 시각(SYSDATE)을 채웁니다.
     */
    public int updatePaymentStatus(String bootNo, String status) throws Exception {
        String sql = "UPDATE PAYMENT SET PAYMENT_STATUS = ?, APPROVED_AT = SYSDATE WHERE RESERVATION_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            bindReservationId(pstmt, 2, bootNo);

            return pstmt.executeUpdate();
        }
    }
}