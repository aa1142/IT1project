package com.hotel.payment;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PaymentDAO {

    // 데이터베이스 연결 커넥션 획득 메소드 (SCOTT / tiger 정품 엔진 탑재)
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");
        return DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "SCOTT",
            "tiger"
        );
    }

    /**
     * [사용자 전용 정품 메서드]
     * 앞단 흐름 상관없이 오직 오라클 테이블에서 예약번호 하나로 진짜 적재된 AMOUNT 금액을 직접 긁어옵니다.
     */
    public int getRoomTotalAmountFromDB(String bootNo) throws Exception {
        // 컬럼명 모순을 해결하기 위해 실제 오라클 컬럼명인 RESERVATION_ID로 타격합니다.
        String sql = "SELECT AMOUNT FROM PAYMENT WHERE RESERVATION_ID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, bootNo);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("AMOUNT"); // 정품 AMOUNT 추출 완료!
                }
            }
        }
        return 0;
    }

    /**
     * 1. [등록] 카카오페이 최종 승인 완료된 결제 영수증 내역을 PAYMENT 테이블에 적재합니다.
     */
    public int insertPayment(PaymentDTO dto) throws Exception {
        String sql = "INSERT INTO PAYMENT (PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?)";

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
     * 2. [조회] 환불 처리를 위해 RESERVATION_ID를 기준으로 정상 결제('PAID')된 영수증 내역을 찾아옵니다.
     */
    public PaymentDTO findPaidPaymentByBootNo(String bootNo) throws Exception {
        // 부적합한 식별자 에러 방지를 위해 BOOT_NO 컬럼명을 RESERVATION_ID로 전면 수정 고정
        String sql = "SELECT PAYMENT_ID, RESERVATION_ID, TID, PARTNER_ORDER_ID, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS, CREATED_AT " +
                     "FROM PAYMENT " +
                     "WHERE RESERVATION_ID = ? AND PAYMENT_STATUS = 'PAID'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, bootNo);

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
                    dto.setCreatedAt(String.valueOf(rs.getTimestamp("CREATED_AT")));
                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * 3. [수정] 환불 성공 시 결제 내역의 상태를 전면 변경합니다. (ex: PAID -> REFUNDED)
     */
    /**
     * 3. [수정] 결제 성공 시 상태를 'PAID'로 바꾸고, 빈칸이던 APPROVED_AT에 오라클 현재 시각(SYSDATE)을 쾅 박아버립니다.
     */
    public int updatePaymentStatus(String bootNo, String status) throws Exception {
        // 🎯 STATUS뿐만 아니라 APPROVED_AT 컬럼까지 실시간 동기화 처리
        String sql = "UPDATE PAYMENT SET PAYMENT_STATUS = ?, APPROVED_AT = SYSDATE WHERE RESERVATION_ID = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status); 
            pstmt.setString(2, bootNo);

            return pstmt.executeUpdate();
        }
    }}