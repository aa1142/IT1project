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
            "SCOTT",
            "tiger"
        );
    }

    public int insertPayment(PaymentDTO payment) throws Exception {
        String sql =
            "INSERT INTO PAYMENT " +
            "(payment_id, reservation_id, tid, partner_order_id, payment_method, amount, payment_status, created_at) " +
            "VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, payment.getReservationId());
            pstmt.setString(2, payment.getTid());
            pstmt.setString(3, payment.getPartnerOrderId());
            pstmt.setString(4, payment.getPaymentMethod());
            pstmt.setInt(5, payment.getAmount());
            pstmt.setString(6, payment.getPaymentStatus());

            return pstmt.executeUpdate();
        }
    }

    public PaymentDTO findPaidPaymentByReservationId(int reservationId) throws Exception {
        String sql =
            "SELECT reservation_id, tid, partner_order_id, payment_method, amount, payment_status " +
            "FROM PAYMENT " +
            "WHERE reservation_id = ? AND payment_status = 'PAID' " +
            "ORDER BY payment_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, reservationId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    PaymentDTO payment = new PaymentDTO();

                    payment.setReservationId(rs.getInt("reservation_id"));
                    payment.setTid(rs.getString("tid"));
                    payment.setPartnerOrderId(rs.getString("partner_order_id"));
                    payment.setPaymentMethod(rs.getString("payment_method"));
                    payment.setAmount(rs.getInt("amount"));
                    payment.setPaymentStatus(rs.getString("payment_status"));

                    return payment;
                }
            }
        }

        return null;
    }

    public int updatePaymentStatus(int reservationId, String status) throws Exception {
        String sql =
            "UPDATE PAYMENT " +
            "SET payment_status = ? " +
            "WHERE reservation_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, reservationId);

            return pstmt.executeUpdate();
        }
    }
}