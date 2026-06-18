<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String selectedBootNo = request.getParameter("bootNo");
    String selectedBranch = request.getParameter("branch");
    String selectedRoomGrade = request.getParameter("roomgrade");
    String selectedRoomType = request.getParameter("roomtype");
    boolean hasReservationInfo = selectedBootNo != null && !selectedBootNo.trim().isEmpty();

    if (selectedBranch == null) selectedBranch = "";
    if (selectedRoomGrade == null) selectedRoomGrade = "";
    if (selectedRoomType == null) selectedRoomType = "";

    String selectedBranchName = selectedBranch;
    if ("1".equals(selectedBranch)) selectedBranchName = "JYPホテル東京";
    else if ("2".equals(selectedBranch)) selectedBranchName = "JYPホテル新宿";
    else if ("3".equals(selectedBranch)) selectedBranchName = "JYPホテル横浜";

    // 등급 출력을 위해 영문 규격 변환 로직 추가
    String displayGrade = selectedRoomGrade;
    if (displayGrade.equalsIgnoreCase("standard") || displayGrade.contains("스탠다드")) displayGrade = "Standard";
    else if (displayGrade.equalsIgnoreCase("deluxe") || displayGrade.contains("디럭스")) displayGrade = "Deluxe";
    else if (displayGrade.equalsIgnoreCase("suite") || displayGrade.contains("스위트")) displayGrade = "Suite";

    String selectedRoomTypeName = selectedRoomType;
    if ("1".equals(selectedRoomType)) selectedRoomTypeName = "シングル";
    else if ("2".equals(selectedRoomType)) selectedRoomTypeName = "ツイン";
    else if ("5".equals(selectedRoomType)) selectedRoomTypeName = "ファミリー";
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル レビュー作成</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; color: #333; font-family: 'Pretendard', sans-serif; padding: 50px 0; }
        .write-container { max-width: 680px; margin: 0 auto; background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .page-title { font-size: 1.5rem; font-weight: bold; text-align: center; margin-bottom: 35px; }
        .form-section { background: #fff; border: 1px solid #eaeded; border-radius: 8px; padding: 20px; margin-bottom: 20px; }
        .section-label { font-size: 0.95rem; font-weight: bold; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
        .form-select-custom, .form-input-custom, .form-textarea-custom { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 0.95rem; background-color: #fff; }
        .star-rating-box { text-align: center; padding: 10px 0; }
        .star-input-group { display: inline-flex; gap: 4px; font-size: 2rem; color: #ced4da; cursor: pointer; }
        .star-input-group .fas { color: #1f2d3d; }
        .rating-display { font-size: 1.1rem; font-weight: bold; margin-top: 8px; color: #212529; }
        .slider-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
        .slider-label { font-size: 0.9rem; display: flex; align-items: center; gap: 6px; width: 30%; }
        .slider-wrapper { width: 60%; display: flex; align-items: center; }
        .form-range-custom { width: 100%; accent-color: #1f2d3d; cursor: pointer; }
        .slider-value { width: 8%; text-align: right; font-weight: bold; font-size: 1rem; color: #212529; }
        .btn-group-row { display: flex; gap: 12px; margin-top: 35px; }
        .btn-submit-custom { background-color: #1f2d3d; color: #fff; flex: 1; padding: 14px; border: none; border-radius: 6px; font-weight: bold; font-size: 1rem; }
        .btn-cancel-custom { background-color: #fff; color: #495057; border: 1px solid #ced4da; flex: 1; padding: 14px; border-radius: 6px; font-weight: bold; font-size: 1rem; text-align: center; text-decoration: none; }
        .reservation-summary { background: #eef3f8; border: 1px solid #d8e2ec; color: #1f2d3d; border-radius: 8px; padding: 16px; margin-bottom: 20px; }
        .reservation-summary-title { font-weight: bold; margin-bottom: 8px; }
        .reservation-summary-detail { color: #495057; line-height: 1.7; }
    </style>
</head>
<body>

<div class="write-container">
    <div class="page-title">JYPホテル レビュー作成</div>

    <form id="reviewForm" method="POST" action="<%= request.getContextPath() %>/review/reviewInsert">
        <% if (hasReservationInfo) { %>
            <div class="reservation-summary">
                <div class="reservation-summary-title">選択された予約情報</div>
                <div class="reservation-summary-detail">
                    予約番号: <%= selectedBootNo %><br>
                    店舗: <%= selectedBranchName %><br>
                    客室: <%= displayGrade %> / <%= selectedRoomTypeName %>
                </div>
            </div>
            <input type="hidden" name="bootNo" value="<%= selectedBootNo %>">
            <input type="hidden" name="branch" value="<%= selectedBranch %>">
            <input type="hidden" name="roomgrade" value="<%= selectedRoomGrade %>">
            <input type="hidden" name="roomtype" value="<%= selectedRoomType %>">
        <% } else { %>
        <div class="form-section">
            <div class="section-label"><i class="fas fa-map-marker-alt text-danger"></i> ご宿泊店舗の選択</div>
            <select class="form-select-custom" name="branch" required>
                <option value="" disabled <%= selectedBranch.isEmpty() ? "selected" : "" %>>店舗を選択してください</option>
                <option value="1" <%= "1".equals(selectedBranch) ? "selected" : "" %>>JYPホテル東京</option>
                <option value="2" <%= "2".equals(selectedBranch) ? "selected" : "" %>>JYPホテル新宿</option>
                <option value="3" <%= "3".equals(selectedBranch) ? "selected" : "" %>>JYPホテル横浜</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label"><i class="fas fa-bed"></i> ご利用客室ランクの選択</div>
            <select class="form-select-custom" name="roomgrade" required>
                <option value="" disabled <%= selectedRoomGrade.isEmpty() ? "selected" : "" %>>ご利用された客室ランクを選択してください</option>
                <option value="standard" <%= "standard".equalsIgnoreCase(selectedRoomGrade) ? "selected" : "" %>>Standard</option>
                <option value="deluxe" <%= "deluxe".equalsIgnoreCase(selectedRoomGrade) ? "selected" : "" %>>Deluxe</option>
                <option value="suite" <%= "suite".equalsIgnoreCase(selectedRoomGrade) ? "selected" : "" %>>Suite</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label"><i class="fas fa-door-open"></i> 客室タイプの選択</div>
            <select class="form-select-custom" name="roomtype" required>
                <option value="" disabled <%= selectedRoomType.isEmpty() ? "selected" : "" %>>客室タイプを選択してください</option>
                <option value="1" <%= "1".equals(selectedRoomType) ? "selected" : "" %>>シングル</option>
                <option value="2" <%= "2".equals(selectedRoomType) ? "selected" : "" %>>ツイン</option>
                <option value="5" <%= "5".equals(selectedRoomType) ? "selected" : "" %>>ファミリー</option>
            </select>
        </div>
        <% } %>

        <div class="form-section">
            <div class="section-label justify-content-center" style="font-size: 0.9rem; color: #555;">満足度評価（星）</div>
            <div class="star-rating-box">
                <div class="star-input-group" id="starGroup">
                    <i class="far fa-star" data-value="1"></i>
                    <i class="far fa-star" data-value="2"></i>
                    <i class="far fa-star" data-value="3"></i>
                    <i class="far fa-star" data-value="4"></i>
                    <i class="far fa-star" data-value="5"></i>
                </div>
                <div class="rating-display"><span id="ratingVal">0.0</span> / 5.0</div>
                <input type="hidden" name="rating" id="hiddenRating" value="0">
            </div>
        </div>

        <div class="form-section">
            <div class="section-label" style="border-bottom: 1px solid #eaeded; padding-bottom: 8px; margin-bottom: 15px;">
                <i class="fas fa-sliders-h"></i> 評価項目の詳細入力
            </div>

            <div class="slider-row">
                <div class="slider-label">立・アクセス</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_location" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val1')">
                </div>
                <div class="slider-value" id="val1">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">部屋の清潔さ</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_cleanliness" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val2')">
                </div>
                <div class="slider-value" id="val2">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">サービス・接客</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_service" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val3')">
                </div>
                <div class="slider-value" id="val3">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">コスパ（価格満足度）</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_price" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val4')">
                </div>
                <div class="slider-value" id="val4">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">客室・館内施設</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_facilities" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val5')">
                </div>
                <div class="slider-value" id="val5">5</div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">タイトル</div>
            <input type="text" class="form-input-custom" name="title" placeholder="レビューのタイトルを入力してください" required>
        </div>

        <div class="form-section">
            <div class="section-label">レビュー内容</div>
            <textarea class="form-textarea-custom" name="content" rows="6" placeholder="客室の状態、サービス、立地など、あなたの体験を共有してください" required></textarea>
        </div>

        <div class="btn-group-row">
            <button type="submit" class="btn-submit-custom" onclick="return validateRating()">投稿する</button>
            <a href="reviewList.jsp" class="btn-cancel-custom">キャンセル</a>
        </div>
    </form>
</div>

<script>
    function updateSliderValue(slider, targetId) {
        document.getElementById(targetId).innerText = slider.value;
    }

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
        if (hiddenRatingInput.value === "0") {
            alert("満足度評価の星を1つ以上選択してください。");
            return false;
        }
        return true;
    }
</script>
</body>
</html>