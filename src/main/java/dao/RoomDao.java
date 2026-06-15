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
    
    //방등급별 개수
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
    	
    //예약이 되어있는 방 개수
    public Map<String, Integer> countBootingRoom(String searchDate, int companyNo) {
        String sql = "SELECT r.room_grade, "
                + "       COUNT(CASE WHEN r.room_type = 1 AND b.boot_no IS NOT NULL THEN 1 END) AS reserved_single, "
                + "       COUNT(CASE WHEN r.room_type = 2 AND b.boot_no IS NOT NULL THEN 1 END) AS reserved_twin, "
                + "       COUNT(CASE WHEN r.room_type = 5 AND b.boot_no IS NOT NULL THEN 1 END) AS reserved_family "
                + "FROM room r "
                + "LEFT JOIN boot b ON r.room_no = b.room_no "
                + "                AND r.company_no = b.company_no"
                + "                AND b.boot_checkin <= TO_DATE(?, 'YYYY-MM-DD') " // 첫 번째 ?
                + "                AND b.boot_checkout > TO_DATE(?, 'YYYY-MM-DD') " // 두 번째 ?
                + "                AND b.boot_confirm = 1 "
                + "WHERE r.company_no = ? "                                         // 세 번째 ?
                + "  AND r.room_grade IN ('스탠다드', '디럭스', '스윗트')"
                + "  AND r.room_type IN (1, 2, 5) "
                + "GROUP BY r.room_grade";
                
        // ⚠️ SQL에 ?가 3개이므로 파라미터도 3개를 순서대로 넣어주어야 합니다.
        Object[] params = {searchDate, searchDate, companyNo};
        
        Map<String, Integer> list = new HashMap<>();
        
        db.selectTemplate(sql, params, rs -> {
            while (rs.next()) {  
                // 1. SELECT 절에 명시된 정확한 컬럼/별칭 명칭으로 가져옵니다.
                String roomGrade = rs.getString("room_grade");
                switch (roomGrade) {
				case "스탠다드":
					roomGrade = "standard";
					break;
				case "디럭스":
					roomGrade = "deluxe";
					break;
				case "스윗트":
					roomGrade = "suite";
					break;
				}
                int singleCount = rs.getInt("reserved_single");
                int twinCount = rs.getInt("reserved_twin");
                int familyCount = rs.getInt("reserved_family");
                
                // 2. Map에 데이터를 구별해서 저장합니다. (예시)
                list.put(roomGrade + "_single", singleCount);
                list.put(roomGrade + "_twin", twinCount);
                list.put(roomGrade + "_family", familyCount);
            }
            return list;
        });
        return list;
    }
    
    //종류별 방 개수
    public Map<String, Integer> countAllTypeRoom(int companyNo){
    	String sql = "SELECT room_grade, "
    			+ "       COUNT(CASE WHEN room_type = 1 THEN 1 END) AS reserved_single, "
    			+ "       COUNT(CASE WHEN room_type = 2 THEN 1 END) AS reserved_twin, "
    			+ "       COUNT(CASE WHEN room_type = 5 THEN 1 END) AS reserved_family "
    			+ "FROM room "
    			+ "WHERE company_no = ? "
    			+ "  AND room_grade IN ('스탠다드', '디럭스', '스윗트') "
    			+ "  AND room_type IN (1, 2, 5) "
    			+ "GROUP BY room_grade";
    	Object[] params = {companyNo};
    	Map<String, Integer> roomCountList = new HashMap<>();
    	db.selectTemplate(sql, params, rs -> {
            while (rs.next()) {  //반복문으로 출력
            	String roomGrade = rs.getString("room_grade");
                switch (roomGrade) {
				case "스탠다드":
					roomGrade = "standard";
					break;
				case "디럭스":
					roomGrade = "deluxe";
					break;
				case "스윗트":
					roomGrade = "suite";
					break;
				}
                int singleCount = rs.getInt("reserved_single");
                int twinCount = rs.getInt("reserved_twin");
                int familyCount = rs.getInt("reserved_family");
                
                // 2. Map에 데이터를 구별해서 저장합니다. (예시)
                roomCountList.put(roomGrade + "_singleAll", singleCount);
                roomCountList.put(roomGrade + "_twinAll", twinCount);
                roomCountList.put(roomGrade + "_familyAll", familyCount);

            }
            return roomCountList; // 반환
        });
    	return roomCountList;
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
    
    public List<RoomDto> selectRoomPrice(int companyNo){
    	String sql = "SELECT DISTINCT room_grade, room_type, room_price "
                + "FROM room "
                + "WHERE company_no = ? "
                + "  AND room_grade IN ('스탠다드', '디럭스', '스윗트') "
                + "ORDER BY "
                + "    CASE room_grade "
                + "        WHEN '스탠다드' THEN 1 "
                + "        WHEN '디럭스' THEN 2 "   // <- 1. 누락되었던 숫자 2 추가!
                + "        WHEN '스윗트' THEN 3 "
                + "        ELSE 4 "                 // <- 2. 뒤쪽 코드가 잘리는 위험한 주석(--) 제거!
                + "    END ASC, "
                + "    room_type ASC";
    	Object[] params = { companyNo };  //예시) 데이터 값 순서대로 잘 넣기 

    	List<RoomDto> resultList=db.selectTemplate(sql, params, rs -> {
    		List<RoomDto> list = new ArrayList<>();
        		while (rs.next()) {  //어차피 한개니까 if문 활용
        			RoomDto rootDto = new RoomDto();  // Dto 생성
        			rootDto.setCompanyNo(companyNo);
        			rootDto.setRoomGrade(rs.getString("room_grade"));
        			rootDto.setRoomType(rs.getInt("room_type"));
        			rootDto.setRoomPrice(rs.getInt("room_price"));
    	            list.add(rootDto);
    	        }
        		return list;//없으면 null로 반환
        	});
        	return resultList; //최종반환
    }
    
    public int changeRoomPrice(int priceSingle, int priceTwin, int priceFamily, String roomGrade, int companyNo) {
    	String sql = "UPDATE room "
    			+ "SET room_price = CASE room_type "
    			+ "                    WHEN 1 THEN ? "
    			+ "                    WHEN 2 THEN ? "
    			+ "                    WHEN 5 THEN ? "
    			+ "                 END "
    			+ "WHERE room_grade = ? "
    			+ "  AND company_no = ? "
    			+ "  AND room_type IN (1, 2, 5)";
    	int result = 0;
    	Object[] params = {priceSingle, priceTwin, priceFamily, roomGrade, companyNo};
    	
    	result = db.updateTemplate(sql, params);
    	
    	return result;
    }
    
}