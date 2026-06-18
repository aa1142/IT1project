<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="review.ReviewDao" %>
<%@ page import="review.ReviewDto" %>
<%
    String reviewNoParam = request.getParameter("reviewNo");
    if (reviewNoParam == null || reviewNoParam.trim().isEmpty()) {
%>
        <script>
            alert("レビュー番号（reviewNo） 누락되었습니다.");
            location.href = "<%= request.getContextPath() %>/review/reviewList";
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
            alert("該当するレビューが見つかりません。");
            location.href = "<%= request.getContextPath() %>/review/reviewList";
        </script>
<%
        return;
    }

    String roomGrade = review.getRoomgrade() == null ? "" : review.getRoomgrade();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル レビュー編集</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; color: #333; font-family: 'Pretendard', sans-serif; padding: 50px 0; }
        .write-container { max-width: 680px; margin: 0 auto; background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .page-title { font-size: 1.5rem; font-weight: bold; text-align: center; margin-bottom: 35px; }
        .form-section { background: #fff; border: 1px solid #eaeded; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
        .section-label { font-size: 0.95rem; font-weight: bold; margin-bottom: 12px; }
        .form-select-custom, .form-textarea-custom { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.95rem; background-color: #fff; }
        .slider-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; gap: 12px; }
        .slider-label { width: 30%; font-size: 0.9rem; }
        .slider-wrapper { width: 60%; }
        .slider-value { width: 8%; text-align: right; font-weight: bold; }
        .form-range-custom { width: 100%; accent-color: #1f2d3d; }
        .btn-group-row { display: flex; gap: 12px; margin-top: 35px; }
        .btn-submit-custom { background-color: #1f2d3d; color: #fff; flex: 1; padding: 14px; border: none; border-radius: 6px; font-weight: bold; }
        .btn-cancel-custom { background-color: #fff; color: #495057; border: 1px solid #ced4da; flex: 1; padding: 14px; border-radius: 6px; font-weight: bold; text-align: center; text-decoration: none; }
    </style>
</head>
<body>
<div style="max-width:680px; margin:0 auto 20px auto;">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>
<div class="write-container">
    <div class="page-title">レビュー編集</div>

    <form method="POST" action="<%= request.getContextPath() %>/review/reviewList">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="reviewNo" value="<%= review.getReviewNo() %>">

        <div class="form-section">
            <div class="section-label">ご宿泊店舗</div>
            <select class="form-select-custom" name="branch" required>
                <option value="1" <%= review.getCompanyNo() == 1 ? "selected" : "" %>>JYPホテル東京</option>
                <option value="2" <%= review.getCompanyNo() == 2 ? "selected" : "" %>>JYPホテル新宿</option>
                <option value="3" <%= review.getCompanyNo() == 3 ? "selected" : "" %>>JYPホテル横浜</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label">客室ランク</div>
            <select class="form-select-custom" name="roomgrade" required>
                <option value="standard" <%= "standard".equalsIgnoreCase(roomGrade) ? "selected" : "" %>>Standard</option>
                <option value="deluxe" <%= "deluxe".equalsIgnoreCase(roomGrade) ? "selected" : "" %>>Deluxe</option>
                <option value="suite" <%= "suite".equalsIgnoreCase(roomGrade) ? "selected" : "" %>>Suite</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label">客室タイプ</div>
            <select class="form-select-custom" name="roomtype" required>
                <option value="1" <%= review.getRoomType() == 1 ? "selected" : "" %>>シングル</option>
                <option value="2" <%= review.getRoomType() == 2 ? "selected" : "" %>>ダブル</option>
                <option value="3" <%= review.getRoomType() == 3 ? "selected" : "" %>>ツイン</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label">総合満足度</div>
            <select class="form-select-custom" name="rating" required>
                <option value="1" <%= review.getRating() == 1 ? "selected" : "" %>>1点</option>
                <option value="2" <%= review.getRating() == 2 ? "selected" : "" %>>2点</option>
                <option value="3" <%= review.getRating() == 3 ? "selected" : "" %>>3点</option>
                <option value="4" <%= review.getRating() == 4 ? "selected" : "" %>>4点</option>
                <option value="5" <%= review.getRating() == 5 ? "selected" : "" %>>5点</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label">評価項目の詳細</div>

            <div class="slider-row">
                <div class="slider-label">立地・アクセス</div>
                <div class="slider-wrapper"><input type="range" class="form-range-custom" name="score_location" min="0" max="10" value="<%= review.getScore_location() %>" oninput="updateSliderValue(this, 'val1')"></div>
                <div class="slider-value" id="val1"><%= review.getScore_location() %></div>
            </div>

            <div class="slider-row">
                <div class="slider-label">部屋の清潔さ</div>
                <div class="slider-wrapper"><input type="range" class="form-range-custom" name="score_cleanliness" min="0" max="10" value="<%= review.getScore_cleanliness() %>" oninput="updateSliderValue(this, 'val2')"></div>
                <div class="slider-value" id="val2"><%= review.getScore_cleanliness() %></div>
            </div>

            <div class="slider-row">
                <div class="slider-label">サービス・接客</div>
                <div class="slider-wrapper"><input type="range" class="form-range-custom" name="score_service" min="0" max="10" value="<%= review.getScore_service() %>" oninput="updateSliderValue(this, 'val3')"></div>
                <div class="slider-value" id="val3"><%= review.getScore_service() %></div>
            </div>

            <div class="slider-row">
                <div class="slider-label">コスパ（価格満足度）</div>
                <div class="slider-wrapper"><input type="range" class="form-range-custom" name="score_price" min="0" max="10" value="<%= review.getScore_price() %>" oninput="updateSliderValue(this, 'val4')"></div>
                <div class="slider-value" id="val4"><%= review.getScore_price() %></div>
            </div>

            <div class="slider-row">
                <div class="slider-label">客室・館内施設</div>
                <div class="slider-wrapper"><input type="range" class="form-range-custom" name="score_facilities" min="0" max="10" value="<%= review.getScore_facilities() %>" oninput="updateSliderValue(this, 'val5')"></div>
                <div class="slider-value" id="val5"><%= review.getScore_facilities() %></div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">レビュー内容</div>
            <textarea class="form-textarea-custom" name="content" rows="6" required><%= review.getContent() == null ? "" : review.getContent() %></textarea>
        </div>

        <div class="btn-group-row">
            <button type="submit" class="btn-submit-custom">修正 완료</button>
            <a href="<%= request.getContextPath() %>/review/reviewList" class="btn-cancel-custom">キャンセル</a>
        </div>
    </form>
</div>

<script>
    function updateSliderValue(slider, targetId) {
        document.getElementById(targetId).innerText = slider.value;
    }
</script>
</body>
</html>