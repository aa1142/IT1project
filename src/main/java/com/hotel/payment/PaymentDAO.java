package com.hotel.payment;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PaymentDAO {

    // 데이터베이스 연결 커넥션 획득 메소드
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "SCOTT",
            "tiger"
        );
    }

    /**
     * 1. [등록] 카카오페이 최종 승인 완료된 결제 영수증 내역을 PAYMENT 테이블에 적재합니다.
     */
    public int insertPayment(PaymentDTO dto) throws Exception {
        String sql = "INSERT INTO PAYMENT " +
                     "(PAYMENT_ID, BOOT_NO, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) " +
                     "VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, dto.getBootNo());
            pstmt.setString(2, dto.getTid());
            pstmt.setString(3, dto.getPartnerOrderId());
            pstmt.setString(4, dto.getPaymentMethod());
            pstmt.setInt(5, dto.getAmount());
            pstmt.setString(6, dto.getPaymentStatus());

            return pstmt.executeUpdate();
        }
    }

    /**
     * 2. [조회] 환불 처리를 위해 BOOT_NO(예약번호)를 기준으로 정상 결제('PAID')된 영수증 내역을 찾아옵니다.
     * KakaoRefundServlet의 findPaidPaymentByBootNo 빨간 줄을 없애주는 핵심 메서드입니다.
     */
    public PaymentDTO findPaidPaymentByBootNo(String bootNo) throws Exception {
        String sql = "SELECT PAYMENT_ID, BOOT_NO, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, CREATED_AT " +
                     "FROM PAYMENT " +
                     "WHERE BOOT_NO = ? AND PAYMENT_STATUS = 'PAID'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, bootNo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    PaymentDTO dto = new PaymentDTO();
                    dto.setPaymentId(rs.getInt("PAYMENT_ID"));
                    dto.setBootNo(rs.getString("BOOT_NO"));
                    dto.setTid(rs.getString("TID"));
                    dto.setPartnerOrderId(rs.getString("PARTNER_ORDER_ID"));
                    dto.setPaymentMethod(rs.getString("PAYMENT_METHOD"));
                    dto.setAmount(rs.getInt("AMOUNT"));
                    dto.setPaymentStatus(rs.getString("PAYMENT_STATUS"));
                    dto.setCreatedAt(String.valueOf(rs.getTimestamp("CREATED_AT")));
                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 3. [수정] 환불 성공 시 결제 내역의 상태를 전면 변경합니다. (ex: PAID -> REFUNDED)
     * KakaoRefundServlet의 updatePaymentStatus 빨간 줄을 없애주는 핵심 메서드입니다.
     */
    public int updatePaymentStatus(String bootNo, String status) throws Exception {
        String sql = "UPDATE PAYMENT SET PAYMENT_STATUS = ? WHERE BOOT_NO = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status); // 'REFUNDED' 등이 전달됨
            pstmt.setString(2, bootNo);

            return pstmt.executeUpdate();
        }
    }
}