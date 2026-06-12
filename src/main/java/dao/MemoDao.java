package dao;

import java.util.ArrayList;

import adminVo.HistoryMemoVo;
import db.SqlSet;
import dto.MemoDto;

public class MemoDao {
    // 💡 MemoDto 인스턴스 변수는 메소드 내부에서 매번 새로 생성하므로 클래스 레벨 필드에서는 지워주는 것이 좋습니다.
    private SqlSet db = new SqlSet();
    
    public int insertMemo(String phone, String adminId, String content, String name) {
        // 1. INSERT 쿼리문 작성 (? 개수와 순서 확인)
        String sql = "INSERT INTO memo (memo_phone, admin_id, memo_content, memo_name, memo_date) "
                   + "VALUES (?, ?, ?, ?, SYSDATE)";
        
        System.out.println("phone"+phone);
        System.out.println("adminId"+adminId);
        System.out.println("content"+content);
        System.out.println("name"+name);
        
        
        // 2. ? 순서에 맞게 파라미터 배열 생성 (Object[])
        Object[] params = { phone, adminId, content, name };
        
        // 3. updateTemplate 호출로 실행 및 자동 커밋
        return db.updateTemplate(sql, params);
    }
    
    public ArrayList<HistoryMemoVo> selectAllMemo(String phone, String adminId) {
        // 🎯 쿼리 뒤에 최신등록순(DESC) 정렬을 붙여주면 모달 창에 이쁘게 나옵니다.
        String sql = "SELECT m.memo_phone, a.admin_name, m.memo_content, m.memo_name, m.memo_date FROM memo m, admin a WHERE m.memo_phone = ? and a.admin_id=? ORDER BY memo_date DESC";
        ArrayList<HistoryMemoVo> list = new ArrayList<HistoryMemoVo>();
        
        db.selectTemplate(sql, new Object[] {phone, adminId}, rs -> {
            // while을 써서 DB에 있는 데이터 끝까지 반복문을 돕니다!
            while (rs.next()) {
                // DTO 객체 생성
            	HistoryMemoVo memoDto = new HistoryMemoVo();
                
                // ⭕ 수정 1: meme_phone -> memo_phone (오타 수정)
                memoDto.setMemoPhone(rs.getString("memo_phone"));
                memoDto.setMemoContent(rs.getString("memo_content"));
                memoDto.setMemoName(rs.getString("memo_name"));
                memoDto.setAdminName(rs.getString("admin_name"));
                // ⭕ 수정 2: rs.getDate -> rs.getTimestamp (시/분/초 유실 방지)
                memoDto.setMemoDate(rs.getDate("memo_date"));
                
                // 완성된 바구니를 큰 리스트 통에 추가
                list.add(memoDto);
            }
            
            return list; 
        });
        
        return list;
    }
}