package adminDao;

import java.util.ArrayList;
import java.util.List;

import adminDto.BootDto;
import db.SqlSet;

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
    public List<BootDto> selectAllBoot(int companyNo, int pageSize, int offset) {
        // 1. 쿼리문의 맨 바깥쪽 조건을 BETWEEN ? AND ? 로 수정합니다.
        String sql = "SELECT * FROM ("
                + "    SELECT rownum AS rnum, a.* FROM ("
                + "        SELECT * FROM boot WHERE company_no = ? ORDER BY boot_no ASC"
                + "    ) a WHERE rownum <= ?" 
                + ") WHERE rnum BETWEEN ? AND ? ORDER BY rnum ASC"; // 👈 BETWEEN으로 명확하게 변경
        
        // 2. 🎯 오라클 행 번호(1번부터 시작)에 맞게 시작 행과 끝 행 수식을 교정합니다.
        int startRow = offset + 1;      // 1페이지면 0 + 1 = 1번째부터 / 2페이지면 5 + 1 = 6번째부터!
        int endRow = offset + pageSize; // 1페이지면 0 + 5 = 5번째까지 / 2페이지면 5 + 5 = 10번째까지!
        
        List<BootDto> bootList = new ArrayList<>();
        
        // 3. 🎯 파라미터가 4개가 되었으므로 순서대로 정확히 바인딩합니다.
        // 순서: company_no(?) -> rownum<=?(endRow) -> BETWEEN ?(startRow) AND ?(endRow)
        bootList = (List<BootDto>) db.selectTemplate(sql, new Object[] {companyNo, endRow, startRow, endRow}, rs -> {
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
    	String assignRoomSql = "update boot set room_no = ? where boot_no = ? and company_no = ?";
    	Object[] changRoomParams = {roomNo, bootNo, companyNo};
    	result = db.updateTemplate(assignRoomSql, changRoomParams);
    	
    	if(result>0) {
        	String changeConfirm = "update boot set boot_confirm=1 where boot_no=? and company_no = ?";
        	Object[] bootNoParam = {bootNo, companyNo};
        	result=db.updateTemplate(changeConfirm, bootNoParam);
    	}

    	if(result>0) {
		System.out.println("roomNo= "+roomNo);
		System.out.println("companyNo= "+companyNo);
    	String changeRoomNow = "update room set room_now = '예약중' where room_no = ? and company_no = ?";
    	Object[] roonNoParam = {roomNo, companyNo};
    	result=db.updateTemplate(changeRoomNow, roonNoParam);
    	System.out.println(result);
    	}
    	return result;
    }
}