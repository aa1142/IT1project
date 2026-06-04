package db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SqlSet {

    // [최종 진화형 템플릿] 성공 시에만 자동 커밋, 실패 시 자동 롤백
    public int updateTemplate(String sql, Object[] params) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            conn = DbContact.getConnection();
            
            // ⭐ 핵심: 수동 커밋 모드로 전환 (자바가 트랜잭션을 직접 제어하겠다고 선언)
            conn.setAutoCommit(false); 
            
            pstmt = conn.prepareStatement(sql);

            // 파라미터 배열이 비어있지 않다면, 자동으로 반복문을 돌며 ?를 채웁니다.
            if (params != null) {
                for (int i = 0; i < params.length; i++) {
                    pstmt.setObject(i + 1, params[i]); 
                }
            }

            result = pstmt.executeUpdate();
            
            // 🎯 성공(1개 이상의 행이 반영됨)했을 때만 자동으로 완전히 저장(Commit)
            if (result > 0) {
                conn.commit(); 
                System.out.println("🎯 [트랜잭션] SQL 실행 성공! DB에 완전히 저장(Commit)되었습니다. (반영된 행: " + result + ")");
            } else {
                // 반영된 행이 0개라면 실행 전 상태로 되돌리기
                conn.rollback();
                System.out.println("❌ [트랜잭션] 반영된 행이 없어 취소(Rollback)되었습니다.");
            }

        } catch (Exception e) {
            // 🚨 SQL 실행 도중 예외(에러)가 터지면 안전하게 롤백
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("⚠️ [트랜잭션] 에러가 발생하여 안전하게 롤백(Rollback) 조치했습니다.");
                }
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
            System.out.println("자동 매핑 템플릿 실행 중 에러 발생!");
            e.printStackTrace();
        } finally {
            // 자원을 반납하기 전에 커밋 모드를 다시 원상복구 시켜주는 것이 안전합니다.
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        return result; 
    }
    
    
    public <T> T selectTemplate(String sql, Object[] params, RowMapper<T> mapper) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        T result = null;

        try {
            conn = DbContact.getConnection();
            pstmt = conn.prepareStatement(sql);

            if (params != null) {
                for (int i = 0; i < params.length; i++) {
                    System.out.println("param= " + params[i]);
                    pstmt.setObject(i + 1, params[i]);
                }
            }

            rs = pstmt.executeQuery();
            if (mapper != null) {
                result = mapper.mapRow(rs);
                System.out.println("mapper= " + result);   
            }

        } catch (Exception e) {
            System.out.println("조회 템플릿 실행 중 에러 발생!");
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        
        return result; 
    }
    
}