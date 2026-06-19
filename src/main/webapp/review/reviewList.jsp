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
        .page-wrap { max-width: 1200px; margin: 0 auto; }
        .top-actions { margin-bottom: 20px; }
        .page-title-area { margin-bottom: 26px; }
        .hotel-title { font-size: 1.8rem; font-weight: bold; margin-bottom: 8px; }
        .satisfy-count { font-size: 0.95rem; color: #555; }
        .list-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #1f2d3d; padding-bottom: 10px; margin-bottom: 20px; gap: 16px; }
        .list-title { font-size: 1.2rem; font-weight: bold; white-space: nowrap; }
        .header-controls { display: flex; gap: 10px; align-items: center; }
        .branch-filter, .sort-select { width: 150px; padding: 6px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.85rem; color: #495057; }
        .review-card { padding: 20px 0; border-bottom: 1px solid #eaeded; }
        .card-top-info { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
        .card-stars { color: #1f2d3d; }
        .badge-info-custom { background-color: #eaeded; color: #495057; font-size: 0.75rem; font-weight: 500; padding: 4px 8px; border-radius: 4px; }
        .reservation-line { color: #6c757d; font-size: 0.9rem; margin-bottom: 8px; }
        .card-management { margin-left: auto; display: flex; align-items: center; gap: 10px; font-size: 0.85rem; }
        .btn-edit { color: #888; text-decoration: none; }
        .btn-delete { color: #dc3545; text-decoration: none; border: none; background: none; padding: 0; }
        .card-content-text { color: #555; font-size: 0.95rem; white-space: pre-wrap; }
        @media (max-width: 700px) {
            body { padding: 24px; }
            .list-header { align-items: flex-start; flex-direction: column; }
            .header-controls { width: 100%; }
            .branch-filter, .sort-select { width: 50%; }
            .card-management { margin-left: 0; width: 100%; justify-content: flex-end; }
        }
    </style>
</head>
<body>
<div class="page-wrap">
    <div class="top-actions">
        <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
    </div>
<%
    ArrayList<ReviewDto> reviewList = (ArrayList<ReviewDto>) request.getAttribute("reviewList");
    if (reviewList == null) {
        ReviewDao reviewDao = new ReviewDao();
        reviewList = reviewDao.getReviewList();
    }
    int reviewCount = reviewList == null ? 0 : reviewList.size();
%>
    <div class="page-title-area">
        <div class="hotel-title">JYPホテル レビュー</div>
        <div class="satisfy-count"><i class="far fa-smile me-1"></i> 全 <span id="visibleCount"><%= reviewCount %></span> 件のレビュー</div>
    </div>

    <div class="list-header">
        <div class="list-title">レビュー一覧</div>
        <div class="header-controls">
            <select class="branch-filter" id="branchFilter">
                <option value="all">全店舗</option>
                <option value="1">東京店</option>
                <option value="2">新宿店</option>
                <option value="3">横浜店</option>
            </select>
            <select class="sort-select" id="sortSelect">
                <option value="latest">新着順</option>
                <option value="high">評価の高い順</option>
                <option value="low">評価の低い順</option>
            </select>
        </div>
    </div>

    <div id="reviewListArea">
    <%
        if (reviewList != null && !reviewList.isEmpty()) {
            for (ReviewDto review : reviewList) {
                String branchName = "東京店";
                if (review.getCompanyNo() == 2) branchName = "新宿店";
                else if (review.getCompanyNo() == 3) branchName = "横浜店";

                String roomTypeName = String.valueOf(review.getRoomType());
                if (review.getRoomType() == 1) roomTypeName = "シングル";
                else if (review.getRoomType() == 2) roomTypeName = "ツイン";
                else if (review.getRoomType() == 5) roomTypeName = "ファミリー";

                String roomGrade = review.getRoomGrade() == null ? "" : review.getRoomGrade();
                String stayPeriod = "";
                if (review.getBootCheckin() != null && review.getBootCheckout() != null) {
                    stayPeriod = " / " + review.getBootCheckin() + " ~ " + review.getBootCheckout();
                }
    %>
        <div class="review-card" data-review-no="<%= review.getReviewNo() %>" data-rating="<%= review.getRating() %>" data-branch="<%= review.getCompanyNo() %>">
            <div class="card-top-info">
                <div class="card-stars">
                    <% for (int i = 0; i < review.getRating(); i++) { %>
                        <i class="fas fa-star"></i>
                    <% } %>
                </div>
                <span class="badge-info-custom"><i class="fas fa-hotel me-1"></i><%= branchName %></span>
                <% if (review.getBootNo() != null && !review.getBootNo().trim().isEmpty()) { %>
                    <span class="badge-info-custom">予約番号 <%= review.getBootNo() %></span>
                <% } %>
                <div class="card-management">
                    <a href="<%= request.getContextPath() %>/review/reviewEdit.jsp?reviewNo=<%= review.getReviewNo() %>" class="btn-edit">修正</a>
                    <form method="POST" action="<%= request.getContextPath() %>/review/reviewList" onsubmit="return confirm('本当に削除しますか？')" style="display:inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="reviewNo" value="<%= review.getReviewNo() %>">
                        <button class="btn-delete" type="submit">削除</button>
                    </form>
                </div>
            </div>
            <div class="reservation-line">
                <%= roomGrade %><%= roomGrade.length() > 0 && review.getRoomType() > 0 ? " / " : "" %><%= review.getRoomType() > 0 ? roomTypeName : "" %><%= stayPeriod %>
            </div>
            <div class="card-content-text"><%= review.getContent() == null ? "" : review.getContent() %></div>
        </div>
    <%
            }
        } else {
    %>
        <div class="text-center py-5 text-muted" id="emptyMessage">投稿されたレビューはありません。</div>
    <%
        }
    %>
    </div>
    <div class="text-center py-5 text-muted" id="filterEmptyMessage" style="display:none;">選択した店舗のレビューはありません。</div>
</div>

<script>
    const sortSelect = document.getElementById('sortSelect');
    const branchFilter = document.getElementById('branchFilter');
    const reviewListArea = document.getElementById('reviewListArea');
    const visibleCount = document.getElementById('visibleCount');
    const filterEmptyMessage = document.getElementById('filterEmptyMessage');

    function applyReviewControls() {
        if (!reviewListArea) return;

        const selectedBranch = branchFilter ? branchFilter.value : 'all';
        const sortType = sortSelect ? sortSelect.value : 'latest';
        const cards = Array.from(reviewListArea.querySelectorAll('.review-card'));

        cards.forEach(card => {
            const visible = selectedBranch === 'all' || card.dataset.branch === selectedBranch;
            card.style.display = visible ? '' : 'none';
        });

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

        const shownCount = cards.filter(card => card.style.display !== 'none').length;
        if (visibleCount) visibleCount.innerText = shownCount;
        if (filterEmptyMessage) filterEmptyMessage.style.display = cards.length > 0 && shownCount === 0 ? '' : 'none';
    }

    if (sortSelect) sortSelect.addEventListener('change', applyReviewControls);
    if (branchFilter) branchFilter.addEventListener('change', applyReviewControls);
</script>
</body>
</html>
