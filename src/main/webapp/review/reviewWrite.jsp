<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JYP 호텔 리뷰 작성</title>
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
    </style>
</head>
<body>
<div style="max-width:680px; margin:0 auto 20px auto;">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">홈으로</a>
</div>
<div class="write-container">
    <div class="page-title">JYP 호텔 리뷰 작성</div>

    <form id="reviewForm" method="POST" action="<%= request.getContextPath() %>/review/reviewInsert">
        <div class="form-section">
            <div class="section-label"><i class="fas fa-map-marker-alt text-danger"></i> 방문 지점 선택</div>
            <select class="form-select-custom" name="branch" required>
                <option value="" disabled selected>지점을 선택해주세요</option>
                <option value="1">JYP 호텔 도쿄</option>
                <option value="2">JYP 호텔 신주쿠</option>
                <option value="3">JYP 호텔 요코하마</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label"><i class="fas fa-bed"></i> 이용 객실 등급 선택</div>
            <select class="form-select-custom" name="roomgrade" required>
                <option value="" disabled selected>이용하신 객실 등급을 선택해주세요</option>
                <option value="standard">Standard</option>
                <option value="deluxe">Deluxe</option>
                <option value="suite">Suite</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label"><i class="fas fa-door-open"></i> 객실 타입 선택</div>
            <select class="form-select-custom" name="roomtype" required>
                <option value="" disabled selected>객실 타입을 선택해주세요</option>
                <option value="1">싱글</option>
                <option value="2">더블</option>
                <option value="3">트윈</option>
            </select>
        </div>

        <div class="form-section">
            <div class="section-label justify-content-center" style="font-size: 0.9rem; color: #555;">만족도 별점</div>
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
                <i class="fas fa-sliders-h"></i> 세부 항목 점수 선택
            </div>

            <div class="slider-row">
                <div class="slider-label">위치 만족도</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_location" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val1')">
                </div>
                <div class="slider-value" id="val1">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">청소 청결도</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_cleanliness" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val2')">
                </div>
                <div class="slider-value" id="val2">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">친절 및 서비스</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_service" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val3')">
                </div>
                <div class="slider-value" id="val3">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">가격 대비 만족도</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_price" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val4')">
                </div>
                <div class="slider-value" id="val4">5</div>
            </div>

            <div class="slider-row">
                <div class="slider-label">객실 및 부대시설</div>
                <div class="slider-wrapper">
                    <input type="range" class="form-range-custom" name="score_facilities" min="0" max="10" value="5" oninput="updateSliderValue(this, 'val5')">
                </div>
                <div class="slider-value" id="val5">5</div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label">제목</div>
            <input type="text" class="form-input-custom" name="title" placeholder="리뷰 제목을 입력해주세요" required>
        </div>

        <div class="form-section">
            <div class="section-label">리뷰 내용</div>
            <textarea class="form-textarea-custom" name="content" rows="6" placeholder="객실 상태, 서비스, 위치 등 경험을 공유해주세요" required></textarea>
        </div>

        <div class="btn-group-row">
            <button type="submit" class="btn-submit-custom" onclick="return validateRating()">작성 완료</button>
            <a href="reviewList.jsp" class="btn-cancel-custom">취소</a>
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
            alert("만족도 별점을 최소 1점 이상 선택해주세요.");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
