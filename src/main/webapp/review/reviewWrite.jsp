<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();
    String bootNo = request.getParameter("bootNo");
    if (bootNo == null || bootNo.trim().isEmpty()) {
        response.sendRedirect(ctx + "/review/reviewReservation.jsp");
        return;
    }

    String branch = request.getParameter("branch");
    String roomGrade = request.getParameter("roomgrade");
    String roomType = request.getParameter("roomtype");
    String checkin = request.getParameter("checkin");
    String checkout = request.getParameter("checkout");

    String branchName = "東京店";
    if ("2".equals(branch)) branchName = "新宿店";
    else if ("3".equals(branch)) branchName = "横浜店";

    String roomTypeName = roomType == null ? "" : roomType;
    if ("1".equals(roomType)) roomTypeName = "シングル";
    else if ("2".equals(roomType)) roomTypeName = "ツイン";
    else if ("5".equals(roomType)) roomTypeName = "ファミリー";
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
        .top-actions { max-width: 680px; margin: 0 auto 20px auto; display: flex; flex-direction: column; align-items: flex-start; gap: 8px; }
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
        .btn-submit-custom { background-color: #1f2d3d; color: #fff; flex: 1; padding: 14px; border: none; border-radius: 6px; font-weight: bold; font-size: 1rem; }
        .btn-cancel-custom { background-color: #fff; color: #495057; border: 1px solid #ced4da; flex: 1; padding: 14px; border-radius: 6px; font-weight: bold; font-size: 1rem; text-align: center; text-decoration: none; }
    </style>
</head>
<body>
<div class="top-actions">
    <a href="<%= ctx %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
    <a href="<%= ctx %>/review/reviewList" class="btn btn-outline-dark btn-sm">一覧へ</a>
</div>

<div class="write-container">
    <div class="page-title">JYPホテル レビュー作成</div>

    <form id="reviewForm" method="POST" action="<%= ctx %>/review/reviewInsert">
        <input type="hidden" name="bootNo" value="<%= bootNo %>">
        <input type="hidden" name="branch" value="<%= branch %>">

        <div class="form-section">
            <div class="section-label"><i class="fas fa-receipt text-danger"></i> 予約情報</div>
            <div class="reservation-grid">
                <div class="label">予約番号</div><div><%= bootNo %></div>
                <div class="label">店舗</div><div><%= branchName %></div>
                <div class="label">客室</div><div><%= roomGrade == null ? "" : roomGrade %> / <%= roomTypeName %></div>
                <div class="label">宿泊日</div><div><%= checkin == null ? "" : checkin %> ~ <%= checkout == null ? "" : checkout %></div>
            </div>
        </div>

        <div class="form-section">
            <div class="section-label justify-content-center" style="font-size: 0.9rem; color: #555;">評価</div>
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
            <div class="section-label">レビュー内容</div>
            <textarea class="form-textarea-custom" name="content" rows="7" placeholder="ご利用後の感想を入力してください。" required></textarea>
        </div>

        <div class="btn-group-row">
            <button type="submit" class="btn-submit-custom" onclick="return validateRating()">投稿する</button>
            <a href="<%= ctx %>/review/reviewReservation.jsp" class="btn-cancel-custom">キャンセル</a>
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
        if (hiddenRatingInput && hiddenRatingInput.value === "0") {
            alert("評価を1点以上選択してください。");
            return false;
        }
        return true;
    }
</script>
</body>
</html>
