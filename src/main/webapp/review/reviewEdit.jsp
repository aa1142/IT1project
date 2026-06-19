<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="review.ReviewDao" %>
<%@ page import="review.ReviewDto" %>
<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();
    String reviewNoParam = request.getParameter("reviewNo");
    if (reviewNoParam == null || reviewNoParam.trim().isEmpty()) {
%>
        <script>
            alert("レビュー番号がありません。");
            location.href = "<%= ctx %>/review/reviewList";
        </script>
<%
        return;
    }

    int reviewNo = Integer.parseInt(reviewNoParam);
    ReviewDao reviewDao = new ReviewDao();
    ReviewDto review = reviewDao.getReviewDetail(reviewNo);

    if (review == null) {
%>
        <script>
            alert("修正するレビューが見つかりません。");
            location.href = "<%= ctx %>/review/reviewList";
        </script>
<%
        return;
    }

    String branchName = "東京店";
    if (review.getCompanyNo() == 2) branchName = "新宿店";
    else if (review.getCompanyNo() == 3) branchName = "横浜店";

    String roomTypeName = String.valueOf(review.getRoomType());
    if (review.getRoomType() == 1) roomTypeName = "シングル";
    else if (review.getRoomType() == 2) roomTypeName = "ツイン";
    else if (review.getRoomType() == 5) roomTypeName = "ファミリー";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル レビュー修正</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; color: #333; font-family: 'Pretendard', sans-serif; padding: 50px 0; }
        .write-container { max-width: 680px; margin: 0 auto; background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .page-title { font-size: 1.5rem; font-weight: bold; text-align: center; margin-bottom: 30px; }
        .form-section { background: #fff; border: 1px solid #eaeded; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
        .section-label { font-size: 0.95rem; font-weight: bold; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
        .reservation-grid { display: grid; grid-template-columns: 110px 1fr; row-gap: 8px; font-size: 0.95rem; }
        .reservation-grid .label { color: #6c757d; }
        .form-textarea-custom { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.95rem; background-color: #fff; }
        .star-rating-box { text-align: center; padding: 10px 0; }
        .star-input-group { display: inline-flex; gap: 4px; font-size: 2rem; color: #ced4da; cursor: pointer; }
        .star-input-group .fas { color: #1f2d3d; }
        .rating-display { font-size: 1.1rem; font-weight: bold; margin-top: 8px; color: #212529; }
        .btn-group-row { display: flex; gap: 12px; margin-top: 35px; }
        .btn-submit-custom { background-color: #1f2d3d; color: #fff; flex: 1; padding: 14px; border: none; border-radius: 6px; font-weight: bold; }
        .btn-cancel-custom { background-color: #fff; color: #495057; border: 1px solid #ced4da; flex: 1; padding: 14px; border-radius: 6px; font-weight: bold; text-align: center; text-decoration: none; }
    </style>
</head>
<body>
<div style="max-width:680px; margin:0 auto 20px auto;">
    <a href="<%= ctx %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>

<div class="write-container">
    <div class="page-title">レビュー修正</div>

    <form method="POST" action="<%= ctx %>/review/reviewUpdate" onsubmit="return validateRating()">
        <input type="hidden" name="reviewNo" value="<%= review.getReviewNo() %>">
        <input type="hidden" name="branch" value="<%= review.getCompanyNo() %>">

        <div class="form-section">
            <div class="section-label"><i class="fas fa-receipt text-danger"></i> 予約情報</div>
            <div class="reservation-grid">
                <div class="label">予約番号</div><div><%= review.getBootNo() == null ? "" : review.getBootNo() %></div>
                <div class="label">店舗</div><div><%= branchName %></div>
                <div class="label">客室</div><div><%= review.getRoomGrade() == null ? "" : review.getRoomGrade() %> / <%= review.getRoomType() > 0 ? roomTypeName : "" %></div>
                <div class="label">宿泊日</div><div><%= review.getBootCheckin() == null ? "" : review.getBootCheckin() %> ~ <%= review.getBootCheckout() == null ? "" : review.getBootCheckout() %></div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label justify-content-center" style="font-size: 0.9rem; color: #555;">評価</div>
            <div class="star-rating-box">
                <div class="star-input-group" id="starGroup">
                    <i class="<%= review.getRating() >= 1 ? "fas" : "far" %> fa-star" data-value="1"></i>
                    <i class="<%= review.getRating() >= 2 ? "fas" : "far" %> fa-star" data-value="2"></i>
                    <i class="<%= review.getRating() >= 3 ? "fas" : "far" %> fa-star" data-value="3"></i>
                    <i class="<%= review.getRating() >= 4 ? "fas" : "far" %> fa-star" data-value="4"></i>
                    <i class="<%= review.getRating() >= 5 ? "fas" : "far" %> fa-star" data-value="5"></i>
                </div>
                <div class="rating-display"><span id="ratingVal"><%= review.getRating() %>.0</span> / 5.0</div>
                <input type="hidden" name="rating" id="hiddenRating" value="<%= review.getRating() %>">
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">レビュー内容</div>
            <textarea class="form-textarea-custom" name="content" rows="7" required><%= review.getContent() == null ? "" : review.getContent() %></textarea>
        </div>

        <div class="btn-group-row">
            <button type="submit" class="btn-submit-custom">修正する</button>
            <a href="<%= ctx %>/review/reviewList" class="btn-cancel-custom">キャンセル</a>
        </div>
    </form>
</div>

<script>
    const stars = document.querySelectorAll('#starGroup i');
    const ratingValText = document.getElementById('ratingVal');
    const hiddenRatingInput = document.getElementById('hiddenRating');

    stars.forEach(star => {
        star.addEventListener('click', function() {
            const clickValue = parseInt(this.getAttribute('data-value'));
            ratingValText.innerText = clickValue + ".0";
            hiddenRatingInput.value = clickValue;

            stars.forEach((s, idx) => {
                if (idx < clickValue) {
                    s.classList.remove('far');
                    s.classList.add('fas');
                } else {
                    s.classList.remove('fas');
                    s.classList.add('far');
                }
            });
        });
    });

    function validateRating() {
        if (!hiddenRatingInput || hiddenRatingInput.value === "0") {
            alert("評価を1点以上選択してください。");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
