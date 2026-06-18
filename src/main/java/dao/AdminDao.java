package dao;

import db.SqlSet;
import dto.AdminDto;

public class AdminDao {
    SqlSet sql = new SqlSet();
    
    public AdminDto selectAdmin(String adminId) {
        
//        // 1. 현재 DB 접속 유저 확인
//        String userSql = "SELECT USER FROM DUAL";
//        String dbUser = sql.selectTemplate(userSql, null, rs -> {
//            if (rs.next()) {
//                return rs.getString("USER");
//            }
//            return "알 수 없음";
//        });
//        
//        System.out.println("=========================================");
//        System.out.println(" 현재 DB 접속 유저 계정: " + dbUser);
//        System.out.println("=========================================");

        // 2. 관리자 조회 로직 수행
        String sqlQuery = "SELECT * FROM admin WHERE admin_id = ?";
        AdminDto resultDto = sql.selectTemplate(sqlQuery, new Object[]{ adminId }, rs -> {
            AdminDto adminDto = new AdminDto();
            // ★ 여기가 핵심입니다. DB에서 데이터를 한 행 읽어오는지 확인합니다.
            if (rs.next()) {
                adminDto.setAdminId(rs.getString(adminId));
                adminDto.setCompanyNo(rs.getInt("company_no"));
                adminDto.setAdminPw(rs.getString("admin_pw"));
                adminDto.setAdminName(rs.getString("admin_name"));
                
            }
            
            // 데이터를 못 찾으면 이쪽으로 내려옵니다.
            return adminDto; 
        });
        
        if (resultDto != null) {
            System.out.println("✅ DAO 최종 반환 성공: " + resultDto.getAdminName());
        } else {
            System.out.println("❌ DAO 최종 반환 실패: resultDto가 null입니다.");
        }
        
        return resultDto;
    }
    
    
    public void updateAdmin(String id, String param) {
    	SqlSet code = new SqlSet();
    	String sql = "update admin set admin_name = ? where admin_id=?";
    	System.out.println("id= "+id);
    	System.out.println("param= "+param);
    	Object[] params = {param, id};
    	code.updateTemplate(sql, params);
    }
    
    
    
    
    
    
    
    
}