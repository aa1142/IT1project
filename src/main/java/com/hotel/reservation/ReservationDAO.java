package com.hotel.reservation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ReservationDAO {
    private Connection getConnection() throws Exception {
        Class.forName("oracle.jdbc.OracleDriver");

        return DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:orcl",
            "SCOTT",
            "tiger"
        );
    }
    
    public ReservationDTO findByReservationCodeAndPhoneOrEmail(String reservationCode, String keyword) throws Exception {
        String sql =
            "SELECT reservation_id, reservation_code, room_id, guest_name, guest_phone, booker_name, booker_phone, booker_email, " +
            "check_in_date, check_out_date, people_count, total_amount, reservation_status, created_at " +
            "FROM RESERVATION " +
            "WHERE reservation_code = ? " +
            "AND (booker_phone = ? OR LOWER(booker_email) = LOWER(?))";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, reservationCode);
            pstmt.setString(2, keyword);
            pstmt.setString(3, keyword);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ReservationDTO reservation = new ReservationDTO();

                    reservation.setReservationId(rs.getInt("reservation_id"));
                    reservation.setReservationCode(rs.getString("reservation_code"));
                    reservation.setRoomId(rs.getInt("room_id"));
                    reservation.setGuestName(rs.getString("guest_name"));
                    reservation.setGuestPhone(rs.getString("guest_phone"));
                    reservation.setBookerName(rs.getString("booker_name"));
                    reservation.setBookerPhone(rs.getString("booker_phone"));
                    reservation.setBookerEmail(rs.getString("booker_email"));
                    reservation.setCheckInDate(String.valueOf(rs.getDate("check_in_date")));
                    reservation.setCheckOutDate(String.valueOf(rs.getDate("check_out_date")));
                    reservation.setPeopleCount(rs.getInt("people_count"));
                    reservation.setTotalAmount(rs.getInt("total_amount"));
                    reservation.setReservationStatus(rs.getString("reservation_status"));

                    return reservation;
                }
            }
        }

        return null;
    }
    public ReservationDTO findByReservationCodeAndPhone(String reservationCode, String bookerPhone) throws Exception {
        String sql =
            "SELECT reservation_id, reservation_code, room_id, guest_name, guest_phone, booker_name, booker_phone, booker_email, " +
            "check_in_date, check_out_date, people_count, total_amount, reservation_status, created_at " +
            "FROM RESERVATION " +
            "WHERE reservation_code = ? AND booker_phone = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, reservationCode);
            pstmt.setString(2, bookerPhone);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ReservationDTO reservation = new ReservationDTO();

                    reservation.setReservationId(rs.getInt("reservation_id"));
                    reservation.setReservationCode(rs.getString("reservation_code"));
                    reservation.setRoomId(rs.getInt("room_id"));
                    reservation.setGuestName(rs.getString("guest_name"));
                    reservation.setGuestPhone(rs.getString("guest_phone"));
                    reservation.setBookerName(rs.getString("booker_name"));
                    reservation.setBookerPhone(rs.getString("booker_phone"));
                    reservation.setBookerEmail(rs.getString("booker_email"));
                    reservation.setCheckInDate(String.valueOf(rs.getDate("check_in_date")));
                    reservation.setCheckOutDate(String.valueOf(rs.getDate("check_out_date")));
                    reservation.setPeopleCount(rs.getInt("people_count"));
                    reservation.setTotalAmount(rs.getInt("total_amount"));
                    reservation.setReservationStatus(rs.getString("reservation_status"));

                    return reservation;
                }
            }
        }

        return null;
    }

    public int insertReservation(ReservationDTO reservation) throws Exception {
        String sql =
            "INSERT INTO RESERVATION " +
            "(reservation_id, reservation_code, room_id, guest_name, guest_phone, booker_name, booker_phone, booker_email, " +
            "check_in_date, check_out_date, people_count, total_amount, reservation_status, created_at) " +
            "VALUES (RESERVATION_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, SYSDATE)";

        String idSql = "SELECT RESERVATION_SEQ.CURRVAL FROM DUAL";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             PreparedStatement idPstmt = conn.prepareStatement(idSql)) {

            pstmt.setString(1, reservation.getReservationCode());
            pstmt.setInt(2, reservation.getRoomId());
            pstmt.setString(3, reservation.getGuestName());
            pstmt.setString(4, reservation.getGuestPhone());
            pstmt.setString(5, reservation.getBookerName());
            pstmt.setString(6, reservation.getBookerPhone());
            pstmt.setString(7, reservation.getBookerEmail());
            pstmt.setString(8, reservation.getCheckInDate());
            pstmt.setString(9, reservation.getCheckOutDate());
            pstmt.setInt(10, reservation.getPeopleCount());
            pstmt.setInt(11, reservation.getTotalAmount());
            pstmt.setString(12, reservation.getReservationStatus());

            pstmt.executeUpdate();

            try (ResultSet rs = idPstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    public int updateReservationStatus(int reservationId, String status) throws Exception {
        String sql = "UPDATE RESERVATION SET reservation_status = ? WHERE reservation_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, reservationId);

            return pstmt.executeUpdate();
        }
    }
}