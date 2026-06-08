package dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import db.SqlSet;
import dto.RoomDto;

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
                   + "  AND room_now = '사용 가능' "
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
    
    public Map<String, Integer> selectCountRoomGrade(int companyNo) {
        // 1. 🎯 [중요] 쿼리 연결부 공백 누락 수정 (room 뒤, WHERE 뒤에 스페이스바 필수)
        String sql = "SELECT room_grade, COUNT(*) AS room_count "
                   + "FROM room "
                   + "WHERE company_no = ? "
                   + "GROUP BY room_grade";
        
        // 2. 등급명과 개수를 짝지어 저장하기 위해 Map을 생성합니다. (예: "스탠다드" -> 8)
        Map<String, Integer> roomCountMap = new HashMap<>();
        
        db.selectTemplate(sql, new Object[] {companyNo}, rs -> {
            // 3. while문을 돌며 오라클이 보내준 결과를 한 줄씩 읽습니다.
            while (rs.next()) {
                String roomGrade = rs.getString("room_grade");  // '스탠다드', '디럭스' 등
                int roomCount = rs.getInt("room_count");        // 개수
                
                // Map에 차곡차곡 집어넣기
                roomCountMap.put(roomGrade, roomCount);
            }
            
            return roomCountMap; 
        });
        
        return roomCountMap;
    }
    	
    
    
    
 // 특정 업체의 전체 객실 목록 조회 (방 번호 순)
    public List<RoomDto> selectAllRooms(int companyNo) {
        String sql = "SELECT room_no, room_now, room_grade, room_type, room_price "
                   + "FROM room "
                   + "WHERE company_no = ? "
                   + "ORDER BY room_no ASC";
        
        List<RoomDto> roomList = new ArrayList<>();
        
        db.selectTemplate(sql, new Object[] {companyNo}, rs -> {
            while (rs.next()) {
            	RoomDto roomDto = new RoomDto();
                int roomNo = rs.getInt("room_no");
                
                roomDto.setRoomNo(roomNo);
                roomDto.setCompanyNo(companyNo);
                roomDto.setRoomGrade(rs.getString("room_grade"));
                roomDto.setRoomNow(rs.getString("room_now"));
                roomDto.setRoomPrice(rs.getInt("room_price"));
                roomDto.setRoomType(rs.getInt("room_type"));
                
                // 💡 층수 계산 (예: 101호 / 100 = 1층, 205호 / 100 = 2층)
                
                roomList.add(roomDto);
            }
            return roomList;
        });
        
        return roomList;
    }
    
    public int updateRoomNow(String roomNow, int roomNo, int companyNo) {
    	String sql = "update room set room_now = ? where room_no=? and company_no= ?";
    	Object[] params = {roomNow, roomNo, companyNo};
    	int result= db.updateTemplate(sql, params);
    	System.out.println("상태 수정 결과= "+result);
    	return result;
    }
    
    
}