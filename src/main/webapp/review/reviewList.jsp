<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JYP 호텔 이용 후기</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #fff; color: #333; font-family: 'Pretendard', sans-serif; padding: 40px; }
        .main-wrapper { max-width: 1200px; margin: 0 auto; display: flex; gap: 40px; }
        
        /* 왼쪽 통계 및 작성 구역 */
        .left-sidebar { width: 35%; }
        .hotel-title { font-size: 1.5rem; font-weight: bold; margin-bottom: 25px; }
        .score-section { display: flex; align-items: center; gap: 15px; margin-bottom: 10px; }
        .stars-gold { color: #1f2d3d; font-size: 1.6rem; }
        .score-big { font-size: 2.5rem; font-weight: bold; }
        .satisfy-count { font-size: 0.9rem; color: #555; margin-bottom: 25px; }
        
        /* 만족도 게이지 바 스타일 */
        .gauge-group { margin-bottom: 20px; }
        .gauge-label-row { display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 5px; font-weight: 500; }
        .progress { height: 10px; background-color: #eaeded; border-radius: 5px; }
        .progress-bar { background-color: #1f2d3d; }
        
        /* 후기 작성하기 버튼 */
        .btn-write-review { background-color: #1f2d3d; color: #fff; width: 100%; padding: 14px; border: none; border-radius: 6px; font-weight: bold; font-size: 1rem; margin-top: 25px; }
        
        /* 오른쪽 후기 목록 구역 */
        .right-content { width: 65%; }
        .filter-row { display: flex; gap: 10px; margin-bottom: 25px; }
        .filter-select { flex: 1; padding: 10px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.9rem; color: #495057; }
        .list-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #1f2d3d; padding-bottom: 10px; margin-bottom: 20px; }
        .list-title { font-size: 1.2rem; font-weight: bold; }
        .sort-select { width: 120px; padding: 6px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.85rem; }
        
        /* 개별 리뷰 카드 스타일 */
        .review-card { padding: 20px 0; border-bottom: 1px solid #eaeded; }
        .card-top-info { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .card-stars { color: #1f2d3d; font-size: 1rem; }
        .card-date { color: #888; font-size: 0.85rem; }
        .badge-info-custom { background-color: #eaeded; color: #495057; font-size: 0.75rem; font-weight: 500; padding: 4px 8px; border-radius: 4px; }
        .card-management { margin-left: auto; font-size: 0.85rem; }
        .btn-edit { color: #888; text-decoration: none; margin-right: 10px; }
        .btn-delete { color: #dc3545; text-decoration: none; border: none; background: none; padding: 0; }
        .card-title-text { font-weight: bold; font-size: 1.05rem; margin-bottom: 6px; }
        .card-content-text { color: #555; font-size: 0.95rem; white-space: pre-wrap; }
    </style>
</head>
<body>

<div class="main-wrapper">
    
    <div class="left-sidebar">
        <div class="hotel-title">JYP 호텔 이용 후기</div>
        
        <div class="score-section">
            <div class="stars-gold">
                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i><i class="far fa-star"></i><i class="far fa-star"></i>
            </div>
            <div class="score-big">2.5</div>
        </div>
        <div class="satisfy-count"><i class="far fa-smile me-1"></i> 1명 이상 만족했어요</div>
        
        <div class="gauge-group mt-4">
            <div class="gauge-label-row"><span>📍 위치 만족도</span><span class="text-muted">접근성 아쉬움 (5.0)</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>✨ 숙소 청결도</span><span class="text-muted">청소 아쉬워요 (5.0)</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>💁 친절도 및 서비스</span><span class="text-muted">보통이에요 (5.0)</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>💵 가격 대비 만족도</span><span class="text-muted">비싼 편이에요 (5.0)</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>🛏️ 객실 크기 및 부대시설</span><span class="text-muted">다소 좁음 (5.0)</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        
        <button class="btn-write-review" onclick="openReviewWritePopup()">후기 작성하기</button>
    </div>
    
    <div class="right-content">
        <div class="filter-row">
            <select class="filter-select"><option>전체 이용후기 (지점전체)</option></select>
            <select class="filter-select"><option>객실 종류 (전체)</option></select>
            <select class="filter-select"><option>작성 언어 (전체)</option></select>
        </div>
        
        <div class="list-header">
            <div class="list-title">후기 목록</div>
            <select class="sort-select"><option>최신순</option></select>
        </div>
        
        <%
            String url = "jdbc:mysql://localhost:3306/IT1project?serverTimezone=UTC";
            String user = "scott";
            String pass = "tiger"; // 💡 팀 비밀번호로 체크해주세요!
            
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT * FROM review ORDER BY review_no DESC";
                try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
                    
                    boolean hasReview = false;
                    while(rs.next()) {
                        hasReview = true;
                        int reviewNo = rs.getInt("review_no");
                        String title = rs.getString("title");
                        String content = rs.getString("content");
                        String branch = rs.getString("branch");
                        String roomType = rs.getString("room_type");
                        double rating = rs.getDouble("rating");
                        
                        // 날짜 포맷 (YYYY. M. D. 형태로 변경)
                        String rawDate = rs.getTimestamp("reg_date").toString().substring(0, 10);
                        String[] dateParts = rawDate.split("-");
                        String formattedDate = dateParts[0] + ". " + Integer.parseInt(dateParts[1]) + ". " + Integer.parseInt(dateParts[2]) + ".";
                        
                        // 별점 개수에 맞춰서 별 아이콘 그리기 데이터 생성
                        StringBuilder starIcons = new StringBuilder();
                        int fullStars = (int) rating;
                        for(int i=0; i<5; i++) {
                            if(i < fullStars) {
                                starIcons.append("<i class='fas fa-star'></i>");
                            } else {
                                starIcons.append("<i class='far fa-star'></i>");
                            }
                        }
        %>
                        <div class="review-card">
                            <div class="card-top-info">
                                <div class="card-stars"><%= starIcons.toString() %></div>
                                <div class="card-date"><%= formattedDate %></div>
                                <% if(branch != null && !branch.isEmpty()) { %>
                                    <span class="badge-info-custom"><i class="fas fa-hotel me-1"></i><%= branch %></span>
                                <% } %>
                                <% if(roomType != null && !roomType.isEmpty()) { %>
                                    <span class="badge-info-custom"><i class="fas fa-bed me-1"></i><%= roomType %></span>
                                <% } %>
                                
                                <div class="card-management">
                                    <a href="#" class="btn-edit" onclick="openReviewEditPopup(<%= reviewNo %>)">수정</a>
                                    <button class="btn-delete" onclick="deleteReviewData(<%= reviewNo %>)">삭제</button>
                                </div>
                            </div>
                            <div class="card-title-text"><%= title.replace("<", "&lt;").replace(">", "&gt;") %></div>
                            <div class="card-content-text"><%= content.replace("<", "&lt;").replace(">", "&gt;") %></div>
                        </div>
        <%
                    }
                    if(!hasReview) {
                        out.print("<div class='text-center py-5 text-muted'>등록된 이용 후기가 없습니다. 첫 후기를 작성해 보세요!</div>");
                    }
                }
            } catch(Exception e) {
                out.print("<div class='text-danger p-3'>오류 발생: " + e.getMessage() + "</div>");
            }
        %>
    </div>
</div>

<script>
    // 팝업창 닫히고 돌아오면 목록 실시간 리로드
    window.onfocus = function() { window.location.reload(); };

    function openReviewWritePopup() {
        const w = 700; const h = 600;
        const left = (window.screen.width / 2) - (w / 2); const top = (window.screen.height / 2) - (h / 2);
        window.open('reviewWrite.jsp', 'reviewWritePopup', `width=${w},height=${h},left=${left},top=${top}`);
    }

    function openReviewEditPopup(reviewNo) {
        const w = 700; const h = 600;
        const left = (window.screen.width / 2) - (w / 2); const top = (window.screen.height / 2) - (h / 2);
        window.open(`reviewWrite.jsp?edit=${reviewNo}`, 'reviewEditPopup', `width=${w},height=${h},left=${left},top=${top}`);
    }

    function deleteReviewData(reviewNo) {
        if (confirm('이 후기를 정말로 삭제하시겠습니까?')) {
            const params = new URLSearchParams();
            params.append("action", "delete");
            params.append("reviewNo", reviewNo);

            // 공지사항 때처럼 만들어둘 서블릿(일꾼) 주소로 신호를 쏩니다.
            fetch('../api/myReviews', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert('후기가 삭제되었습니다.');
                    window.location.reload();
                } else { alert('삭제 실패'); }
            }).catch(err => alert('통신 에러: ' + err));
        }
    }
</script>
</body>
</html>