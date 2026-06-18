<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="review.ReviewDao" %>
<%@ page import="review.ReviewDto" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル レビュー</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #fff; color: #333; font-family: 'Pretendard', sans-serif; padding: 40px; }
        .main-wrapper { max-width: 1200px; margin: 0 auto; display: flex; gap: 40px; }
        .left-sidebar { width: 35%; }
        .hotel-title { font-size: 1.5rem; font-weight: bold; margin-bottom: 25px; }
        .score-section { display: flex; align-items: center; gap: 15px; margin-bottom: 10px; }
        .stars-gold, .card-stars { color: #1f2d3d; }
        .score-big { font-size: 2.5rem; font-weight: bold; }
        .satisfy-count { font-size: 0.9rem; color: #555; margin-bottom: 25px; }
        .gauge-group { margin-bottom: 20px; }
        .gauge-label-row { display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 5px; font-weight: 500; }
        .progress { height: 10px; background-color: #eaeded; border-radius: 5px; }
        .progress-bar { background-color: #1f2d3d; }
        .right-content { width: 65%; }
        .list-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #1f2d3d; padding-bottom: 10px; margin-bottom: 20px; }
        .list-title { font-size: 1.2rem; font-weight: bold; }
        .sort-select { width: 150px; padding: 6px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.85rem; }
        .review-card { padding: 20px 0; border-bottom: 1px solid #eaeded; }
        .card-top-info { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .card-date { color: #888; font-size: 0.85rem; }
        .badge-info-custom { background-color: #eaeded; color: #495057; font-size: 0.75rem; font-weight: 500; padding: 4px 8px; border-radius: 4px; }
        .card-management { margin-left: auto; display: flex; align-items: center; gap: 10px; font-size: 0.85rem; }
        .btn-edit { color: #888; text-decoration: none; }
        .btn-delete { color: #dc3545; text-decoration: none; border: none; background: none; padding: 0; }
        .card-title-text { font-weight: bold; font-size: 1.05rem; margin-bottom: 6px; }
        .card-content-text { color: #555; font-size: 0.95rem; white-space: pre-wrap; }
        @media (max-width: 900px) {
            .main-wrapper { flex-direction: column; }
            .left-sidebar, .right-content { width: 100%; }
        }
    </style>
</head>
<body>
<div style="max-width:1200px; margin:0 auto 20px auto;">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>
<%
    ArrayList<ReviewDto> reviewList = (ArrayList<ReviewDto>) request.getAttribute("reviewList");
    if (reviewList == null) {
        ReviewDao reviewDao = new ReviewDao();
        reviewList = reviewDao.getReviewList();
    }
    int reviewCount = reviewList == null ? 0 : reviewList.size();
    double avgRating = 0;

    if (reviewCount > 0) {
        int totalRating = 0;
        for (ReviewDto review : reviewList) { totalRating += review.getRating(); }
        avgRating = (double) totalRating / reviewCount;
    }
%>
<div class="main-wrapper">
    <div class="left-sidebar">
        <div class="hotel-title">JYPホテル レビュー</div>

        <div class="score-section">
            <div class="stars-gold"><i class="fas fa-star"></i></div>
            <div class="score-big"><%= String.format("%.1f", avgRating) %></div>
        </div>
        <div class="satisfy-count"><i class="far fa-smile me-1"></i> 全 <%= reviewCount %> 件のレビュー</div>

        <div class="gauge-group mt-4">
            <div class="gauge-label-row"><span>立地・アクセス</span><span class="text-muted">10点満点</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>部屋의清潔さ</span><span class="text-muted">10点満点</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>サービス・接客</span><span class="text-muted">10点満点</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>コスパ（価格満足度）</span><span class="text-muted">10点満点</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
        <div class="gauge-group">
            <div class="gauge-label-row"><span>客室・館内施設</span><span class="text-muted">10点満点</span></div>
            <div class="progress"><div class="progress-bar" style="width: 50%"></div></div>
        </div>
    </div>

    <div class="right-content">
        <div class="list-header">
            <div class="list-title">レビュー一覧</div>
            <select class="sort-select" id="sortSelect">
                <option value="latest">新着順</option>
                <option value="high">評価の高い順</option>
                <option value="low">評価の低い順</option>
            </select>
        </div>

        <div id="reviewListArea">
        <%
            if (reviewList != null && !reviewList.isEmpty()) {
                for (ReviewDto review : reviewList) {
                    
                    // 객실 등급 데이터가 넘어왔을 때 영문(Standard, Deluxe, Suite) 치환 처리
                    String grade = review.getRoomgrade();
                    String displayGrade = (grade == null) ? "" : grade;
                    if (displayGrade.contains("스탠다드") || displayGrade.toUpperCase().contains("STANDARD") || displayGrade.contains("スタンダード")) {
                        displayGrade = "Standard";
                    } else if (displayGrade.contains("디럭스") || displayGrade.toUpperCase().contains("DELUXE") || displayGrade.contains("デラックス")) {
                        displayGrade = "Deluxe";
                    } else if (displayGrade.contains("스위트") || displayGrade.toUpperCase().contains("SUITE") || displayGrade.contains("スイート")) {
                        displayGrade = "Suite";
                    }
                    
                    // 객실 타입 숫자를 일본어 명칭으로 매핑
                    String typeName = String.valueOf(review.getRoomType());
                    if (review.getRoomType() == 1) typeName = "シングル";
                    else if (review.getRoomType() == 2) typeName = "ツイン";
                    else if (review.getRoomType() == 5) typeName = "ファミリー";
        %>
            <div class="review-card" data-review-no="<%= review.getReviewNo() %>" data-rating="<%= review.getRating() %>">
                <div class="card-top-info">
                    <div class="card-stars">
                        <% for (int i = 0; i < review.getRating(); i++) { %>
                            <i class="fas fa-star"></i>
                        <% } %>
                    </div>
                    <div class="card-date"><%= review.getRegDate() == null ? "" : review.getRegDate() %></div>
                    <span class="badge-info-custom"><i class="fas fa-bed me-1"></i><%= displayGrade %> / <%= typeName %></span>
                    <div class="card-management">
                        <a href="<%= request.getContextPath() %>/review/reviewEdit.jsp?reviewNo=<%= review.getReviewNo() %>" class="btn-edit">修正</a>
                        <form method="POST" action="<%= request.getContextPath() %>/review/reviewList" onsubmit="return confirm('本当に削除しますか？')" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="reviewNo" value="<%= review.getReviewNo() %>">
                            <button class="btn-delete" type="submit">削除</button>
                        </form>
                    </div>
                </div>
                <div class="card-title-text">レビュー #<%= review.getReviewNo() %></div>
                <div class="card-content-text"><%= review.getContent() == null ? "" : review.getContent() %></div>
            </div>
        <%
                }
            } else {
        %>
            <div class="text-center py-5 text-muted">投稿されたレビューはありません。</div>
        <%
            }
        %>
        </div>
    </div>
</div>

<script>
    const sortSelect = document.getElementById('sortSelect');
    const reviewListArea = document.getElementById('reviewListArea');

    if (sortSelect && reviewListArea) {
        sortSelect.addEventListener('change', function() {
            const cards = Array.from(reviewListArea.querySelectorAll('.review-card'));
            const sortType = this.value;

            cards.sort((a, b) => {
                const ratingA = Number(a.dataset.rating || 0);
                const ratingB = Number(b.dataset.rating || 0);
                const noA = Number(a.dataset.reviewNo || 0);
                const noB = Number(b.dataset.reviewNo || 0);

                if (sortType === 'high') {
                    return ratingB - ratingA || noB - noA;
                }
                if (sortType === 'low') {
                    return ratingA - ratingB || noB - noA;
                }
                return noB - noA;
            });

            cards.forEach(card => reviewListArea.appendChild(card));
        });
    }
</script>
</body>
</html>