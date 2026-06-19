<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="review.ReviewDbUtil" %>
<%
    request.setCharacterEncoding("UTF-8");

    String memberId = (String) session.getAttribute("sessionUserId");
    if (memberId == null) {
        memberId = (String) session.getAttribute("userId");
    }

    String ctx = request.getContextPath();
    if (memberId == null) {
        response.sendRedirect(ctx + "/wls/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>レビュー作成 予約選択</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; color: #333; font-family: 'Pretendard', sans-serif; padding: 50px 0; }
        .reservation-container { max-width: 900px; margin: 0 auto; background: #fff; padding: 36px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .page-title { font-size: 1.5rem; font-weight: bold; margin-bottom: 8px; }
        .page-desc { color: #6c757d; margin-bottom: 28px; }
        .reservation-card { border: 1px solid #eaeded; border-radius: 8px; padding: 18px; margin-bottom: 14px; display: flex; justify-content: space-between; gap: 18px; align-items: center; }
        .reservation-info { line-height: 1.8; }
        .reservation-no { font-weight: bold; color: #1f2d3d; }
        .reservation-meta { color: #555; font-size: 0.95rem; }
        .btn-review { background-color: #1f2d3d; color: #fff; padding: 10px 18px; border-radius: 6px; text-decoration: none; font-weight: bold; white-space: nowrap; }
        .btn-review:hover { color: #fff; background-color: #111c28; }
        .btn-back { display: inline-block; margin-top: 18px; color: #495057; text-decoration: none; font-weight: bold; }
        .empty-box { text-align: center; color: #6c757d; padding: 50px 20px; border: 1px dashed #ced4da; border-radius: 8px; }
        @media (max-width: 700px) {
            .reservation-card { flex-direction: column; align-items: flex-start; }
            .btn-review { width: 100%; text-align: center; }
        }
    </style>
</head>
<body>
<div class="reservation-container">
    <div class="page-title">レビューを作成する予約を選択</div>
    <div class="page-desc">予約済みの客室情報をもとにレビューを作成します。</div>

    <%
        String sql = "SELECT * FROM BOOT WHERE MEMBER_ID = ? ORDER BY BOOT_NO DESC";
        boolean hasReservation = false;
        boolean loadFailed = false;

        try (Connection conn = ReviewDbUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    hasReservation = true;
                    String bootNo = rs.getString("BOOT_NO");
                    String roomGrade = rs.getString("ROOM_GRADE");
                    int roomType = rs.getInt("ROOM_TYPE");
                    int companyNo = rs.getInt("COMPANY_NO");
                    String checkin = String.valueOf(rs.getDate("BOOT_CHECKIN"));
                    String checkout = String.valueOf(rs.getDate("BOOT_CHECKOUT"));
                    int confirm = rs.getInt("BOOT_CONFIRM");

                    String branchName = "東京店";
                    if (companyNo == 2) branchName = "新宿店";
                    else if (companyNo == 3) branchName = "横浜店";

                    String roomTypeName = String.valueOf(roomType);
                    if (roomType == 1) roomTypeName = "シングル";
                    else if (roomType == 2) roomTypeName = "ツイン";
                    else if (roomType == 5) roomTypeName = "ファミリー";

                    String statusText = confirm == 1 ? "予約確定" : (confirm == 2 ? "予約キャンセル" : "予約進行中");
                    String reviewUrl = ctx + "/review/reviewWrite.jsp"
                            + "?bootNo=" + URLEncoder.encode(bootNo == null ? "" : bootNo, "UTF-8")
                            + "&branch=" + companyNo
                            + "&roomgrade=" + URLEncoder.encode(roomGrade == null ? "" : roomGrade, "UTF-8")
                            + "&roomtype=" + roomType
                            + "&checkin=" + URLEncoder.encode(checkin == null ? "" : checkin, "UTF-8")
                            + "&checkout=" + URLEncoder.encode(checkout == null ? "" : checkout, "UTF-8");
    %>
        <div class="reservation-card">
            <div class="reservation-info">
                <div class="reservation-no"><i class="fas fa-receipt me-1"></i>予約番号 <%= bootNo %></div>
                <div class="reservation-meta">
                    <%= branchName %> / <%= roomGrade == null ? "" : roomGrade %> / <%= roomTypeName %><br>
                    <%= checkin %> ~ <%= checkout %> / <%= statusText %>
                </div>
            </div>
            <% if (confirm == 2) { %>
                <span class="text-muted fw-bold">キャンセルされた予約</span>
            <% } else { %>
                <a class="btn-review" href="<%= reviewUrl %>">レビュー作成</a>
            <% } %>
        </div>
    <%
                }
            }
        } catch (Exception e) {
            loadFailed = true;
    %>
        <div class="empty-box">
            予約情報を読み込めませんでした。<br>
            <span class="text-danger"><%= e.getMessage() %></span>
        </div>
    <%
        }

        if (!hasReservation && !loadFailed) {
    %>
        <div class="empty-box">レビューを作成できる予約履歴がありません。</div>
    <%
        }
    %>

    <a href="<%= ctx %>/review/reviewList" class="btn-back">レビュー一覧へ戻る</a>
</div>
</body>
</html>
