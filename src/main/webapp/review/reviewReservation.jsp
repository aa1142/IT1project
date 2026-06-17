<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");

    String memberId = (String) session.getAttribute("sessionUserId");
    if (memberId == null) {
        memberId = (String) session.getAttribute("userId");
    }

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>리뷰 작성 예약 선택</title>
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
    <div class="page-title">리뷰를 작성할 예약 선택</div>
    <div class="page-desc">예약 내역을 선택하면 지점과 객실 정보가 자동으로 입력됩니다.</div>

    <%
        if (memberId == null) {
    %>
        <div class="empty-box">
            로그인이 필요합니다.<br>
            <a href="<%= ctx %>/wls/login.jsp" class="btn btn-dark mt-3">로그인</a>
        </div>
    <%
        } else {
            String sql = "SELECT BOOT_NO, ROOM_GRADE, ROOM_TYPE, COMPANY_NO, BOOT_CHECKIN, BOOT_CHECKOUT, BOOT_CONFIRM "
                       + "FROM BOOT b WHERE b.MEMBER_ID = ? "
                       + "AND NOT EXISTS (SELECT 1 FROM REVIEW r WHERE r.BOOT_NO = b.BOOT_NO) "
                       + "ORDER BY BOOT_CHECKIN DESC";
            boolean hasReservation = false;
            boolean loadFailed = false;

            try {
                try {
                    Class.forName("oracle.jdbc.OracleDriver");
                } catch (ClassNotFoundException e) {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                }

                try (Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "SCOTT", "tiger");
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
                            String statusText = confirm == 1 ? "예약확정" : (confirm == 2 ? "예약취소" : "예약대기");

                            String reviewUrl = ctx + "/review/reviewWrite.jsp"
                                    + "?bootNo=" + URLEncoder.encode(bootNo == null ? "" : bootNo, "UTF-8")
                                    + "&branch=" + companyNo
                                    + "&roomgrade=" + URLEncoder.encode(roomGrade == null ? "" : roomGrade, "UTF-8")
                                    + "&roomtype=" + roomType;
    %>
        <div class="reservation-card">
            <div class="reservation-info">
                <div class="reservation-no"><i class="fas fa-receipt me-1"></i><%= bootNo %></div>
                <div class="reservation-meta">
                    지점 <%= companyNo %> / <%= roomGrade %> / 객실 타입 <%= roomType %><br>
                    <%= checkin %> ~ <%= checkout %> / <%= statusText %>
                </div>
            </div>
            <% if (confirm == 2) { %>
                <span class="text-muted fw-bold">취소된 예약</span>
            <% } else { %>
                <a class="btn-review" href="<%= reviewUrl %>">리뷰 작성</a>
            <% } %>
        </div>
    <%
                        }
                    }
                }
            } catch (Exception e) {
                loadFailed = true;
    %>
        <div class="empty-box">
            예약 내역을 불러오지 못했습니다.<br>
            <span class="text-danger"><%= e.getMessage() %></span>
        </div>
    <%
            }

            if (!hasReservation && !loadFailed) {
    %>
        <div class="empty-box">리뷰를 작성할 예약 내역이 없습니다.</div>
    <%
            }
        }
    %>

    <a href="<%= ctx %>/review/reviewList" class="btn-back">리뷰 목록으로 돌아가기</a>
</div>
</body>
</html>
