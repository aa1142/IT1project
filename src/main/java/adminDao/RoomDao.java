package adminDao;

import java.util.ArrayList;
import java.util.List;
import adminDto.RoomDto;
import db.SqlSet;

public class RoomDao {
    // SqlSet은 공유해도 안전합니다.
    private SqlSet db = new SqlSet();
    
    // 1. void 대신 List<RoomDto>를 반환하도록 변경
 // 기존 메서드는 유지하고, 아래 메서드를 추가하세요
    public List<RoomDto> selectAvailableRooms(String grade, int roomType, String checkIn, String checkOut, int companyNo) {
        List<RoomDto> roomList = new ArrayList<>();
        String sql = "SELECT * FROM room "
                   + "WHERE room_grade = ? "
                   + "  AND room_type = ? "
                   + "  AND room_now = '사용가능' "
                   + "  AND company_no = ? "
                   + "  AND room_no NOT IN ("
                   + "      SELECT room_no FROM boot "
                   + "      WHERE boot_checkin < TO_DATE(?, 'YYYY-MM-DD') "
                   + "        AND boot_checkout > TO_DATE(?, 'YYYY-MM-DD') "
                   + "        AND boot_confirm = 1"
                   + "  ) "
        		   + "order by room_no asc";
        
        // 물음표가 4개(grade, roomType, checkOut, checkIn)로 늘어났으니 순서 주의!
        db.selectTemplate(sql, new Object[] {grade, roomType, companyNo, checkIn, checkOut}, rs -> {
        	int count = 0;
        	while (rs.next()) {
                RoomDto roomDto = new RoomDto();
                roomDto.setRoomNo(rs.getInt("room_no"));
                roomDto.setRoomGrade(rs.getString("room_grade"));
                roomDto.setRoomType(rs.getInt("room_type"));
                roomList.add(roomDto);
            }
            return roomList;
        });
        return roomList;
    }
}