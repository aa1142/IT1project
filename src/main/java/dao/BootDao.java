package dao;

import java.util.ArrayList;
import java.util.List;

import db.RowMapper;
import db.SqlSet;
import dto.BootDto;

public class BootDao {
    SqlSet db = new SqlSet();
    BootDto bootDto = new BootDto();
    
    // 전체 개수 조회 (정상 작동)
    public int getTotalCount(int companyNo) {
        String sql = "SELECT COUNT(*) AS cnt FROM boot WHERE company_no = ?";
        
        Integer totalCount = db.selectTemplate(sql, new Object[] { companyNo }, rs -> {
            if (rs.next()) {
                return rs.getInt("cnt"); 
            }
            return 0; 
        });
        
        return (totalCount != null) ? totalCount : 0;
    }
            
    // 예약 목록 조회 (🚨 수정 완료)
 // 예약 목록 조회 (🎯 처음과 끝 데이터 잘림 방지 수정)
    public List<BootDto> selectAllBoot(int companyNo, int pageSize, int offset, String bootTime, int payCheck) {
        // 1. 쿼리문의 맨 바깥쪽 조건을 BETWEEN ? AND ? 로 수정합니다.
    	// bootTime 값에 따라 오늘 자정 기준 '이후(>=)' 인가, '이전(<)' 인가 조건을 동적으로 생성
    	String dateCondition = "past".equals(bootTime) ? " < TRUNC(SYSDATE) " : " >= TRUNC(SYSDATE) ";

    	String sql = "SELECT * FROM ("
    	        + "    SELECT rownum AS rnum, a.* FROM ("
    	        + "        SELECT * FROM boot WHERE company_no = ? AND boot_checkin " + dateCondition + " AND boot_pay_check = ? ORDER BY boot_no ASC"
    	        + "    ) a WHERE rownum <= ?" 
    	        + ") WHERE rnum BETWEEN ? AND ? ORDER BY rnum ASC";
        
        // 2. 🎯 오라클 행 번호(1번부터 시작)에 맞게 시작 행과 끝 행 수식을 교정합니다.
        int startRow = offset + 1;      // 1페이지면 0 + 1 = 1번째부터 / 2페이지면 5 + 1 = 6번째부터!
        int endRow = offset + pageSize; // 1페이지면 0 + 5 = 5번째까지 / 2페이지면 5 + 5 = 10번째까지!
        
        List<BootDto> bootList = new ArrayList<>();
        
        // 3. 🎯 파라미터가 4개가 되었으므로 순서대로 정확히 바인딩합니다.
        // 순서: company_no(?) -> rownum<=?(endRow) -> BETWEEN ?(startRow) AND ?(endRow)
        bootList = (List<BootDto>) db.selectTemplate(sql, new Object[] {companyNo, payCheck, endRow, startRow, endRow}, rs -> {
            List<BootDto> list = new ArrayList<>();
            while (rs.next()) {
                BootDto bootDto = new BootDto();
                
                bootDto.setBootNo(rs.getInt("boot_no"));
                bootDto.setRoomGrade(rs.getString("room_grade"));
                bootDto.setRoomType(rs.getInt("room_type"));
                bootDto.setRoomNo(rs.getInt("room_no"));
                bootDto.setCompanyNo(rs.getInt("company_no"));
                bootDto.setMemberId(rs.getString("member_id"));
                bootDto.setBootPhone(rs.getString("boot_phone"));
                bootDto.setBootName(rs.getString("boot_name"));
                bootDto.setBootEmail(rs.getString("boot_email"));
                bootDto.setBootCheckin(rs.getString("boot_checkin"));
                bootDto.setBootCheckout(rs.getString("boot_checkout"));
                bootDto.setBootAdult(rs.getInt("boot_adult"));
                bootDto.setBootChild(rs.getInt("boot_child"));
                bootDto.setBootPlease(rs.getString("boot_please"));
                bootDto.setBootConfirm(rs.getInt("boot_confirm"));
                
                list.add(bootDto);
            }
            return list; 
        });
        
        return (bootList != null) ? bootList : new ArrayList<>(); 
    }
    
    public int assignRoom(int bootNo, int roomNo, int companyNo) {
    	int result = 0;
    	String assignRoomSql = "update boot set room_no = ?, boot_confirm=1 where boot_no = ? and company_no = ?";
    	Object[] changRoomParams = {roomNo, bootNo, companyNo};
    	result = db.updateTemplate(assignRoomSql, changRoomParams);
    	

    	return result;
    }
    
    //룸번호로 예약정보 찾기
    public BootDto SelectOneBootInRoom(int roomNo, int company){
    	String sql = "select * from boot where room_no=? and company_no=? AND TRUNC(SYSDATE) BETWEEN TRUNC(boot_checkin) AND TRUNC(boot_checkout)";
		
    	BootDto resultDto=db.selectTemplate(sql, new Object[] {roomNo, company}, rs -> {
	        // 🚨 핵심: if가 아니라 while을 써서 DB에 있는 데이터 끝까지 반복문을 돕니다!
    		if (rs.next()) {
	            
		    //출력값저장
	        	bootDto.setBootNo(rs.getInt("boot_no"));
                bootDto.setRoomGrade(rs.getString("room_grade"));
                bootDto.setRoomType(rs.getInt("room_type"));
                bootDto.setBootPhone(rs.getString("boot_phone"));
                bootDto.setBootName(rs.getString("boot_name"));
                bootDto.setBootEmail(rs.getString("boot_email"));
                bootDto.setBootCheckin(rs.getString("boot_checkin"));
                bootDto.setBootCheckout(rs.getString("boot_checkout"));
                bootDto.setBootAdult(rs.getInt("boot_adult"));
                bootDto.setBootChild(rs.getInt("boot_child"));
                return bootDto;// 여기서 반환형태 생각해야함
	        }
    		return null;
    	});
    	return resultDto;
    }
    
    
    public String SelectOneFirstBootDate(int roomNo, int company) {
    	String sql = "SELECT * FROM ( "
    			+ "    SELECT TO_CHAR(boot_checkin, 'YYYY-MM-DD') AS boot_checkin "
    			+ "    FROM boot "
    			+ "    WHERE room_no = ? "
    			+ "      AND company_no = ? "
    			+ "      AND TRUNC(boot_checkin) >= TRUNC(SYSDATE) "
    			+ "    ORDER BY boot_checkin ASC "
    			+ ") "
    			+ "WHERE ROWNUM = 1";
    	
    	Object[] params = { roomNo, company };
    	String firstCheckIn = db.selectTemplate(sql, params, rs -> {
 	       
    		String checkIn="";  // Dto 생성
        		if (rs.next()) {  //어차피 한개니까 if문 활용
    	            
    		    //출력값저장
        			checkIn=(rs.getString("boot_checkin"));
                    
        			return checkIn;// 중간 반환
    	        }
        		return null;//없으면 null로 반환
        	});
        	return firstCheckIn; //최종반환
        }

    
    
    	
}