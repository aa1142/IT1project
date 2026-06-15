<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%
    String noParam = request.getParameter("no");
    if (noParam == null || noParam.trim().isEmpty()) {
%>
        <script>
            alert("공지 번호가 없습니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    int noticeNo = Integer.parseInt(noParam);
    NoticeDao dao = new NoticeDao();
    NoticeDto dto = dao.getNoticeDetail(noticeNo);

    if (dto == null) {
%>
        <script>
            alert("존재하지 않는 공지사항입니다.");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    dao.increaseHit(noticeNo);
    int displayHit = dto.getHit() + 1;

    String title = dto.getTitle() == null ? "" : dto.getTitle();
    boolean important = title.startsWith("[중요공지]");
    String displayTitle = important ? title.replaceFirst("^\\[중요공지\\]\\s*", "") : title;
    String content = dto.getContent() == null ? "" : dto.getContent();
    String imageFile = dto.getImageFile();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JYP 호텔 - <%= displayTitle %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 50px; font-family: 'Pretendard', sans-serif; background-color: #f8f9fa; }
        .detail-card {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            padding: 40px;
        }
        .detail-title { font-size: 1.75rem; font-weight: 700; margin-bottom: 16px; }
        .detail-meta { color: #6c757d; font-size: 0.9rem; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #eaeded; }
        .detail-content { color: #333; font-size: 1rem; line-height: 1.8; white-space: pre-wrap; word-break: break-word; min-height: 200px; }
        .detail-image { max-width: 100%; border-radius: 8px; margin-bottom: 24px; }
        .important-badge {
            display: inline-block;
            margin-right: 8px;
            padding: 4px 10px;
            border-radius: 4px;
            background-color: #dc3545;
            color: #fff;
            font-size: 0.8rem;
            font-weight: 700;
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="detail-card">
    <h2 class="detail-title">
        <% if (important) { %>
            <span class="important-badge">중요공지</span>
        <% } %>
        <%= displayTitle %>
    </h2>

    <div class="detail-meta">
        <span>번호 <%= dto.getNoticeNo() %></span>
        <span class="mx-2">|</span>
        <span>작성일 <%= dto.getRegDate() %></span>
        <span class="mx-2">|</span>
        <span>조회 <%= displayHit %></span>
    </div>

    <% if (imageFile != null && !imageFile.isEmpty()) { %>
        <img src="../upload/<%= imageFile %>" alt="공지 이미지" class="detail-image">
    <% } %>

    <div class="detail-content"><%= content %></div>

    <div class="d-flex gap-2 mt-4 pt-3 border-top">
        <a href="noticeList.jsp" class="btn btn-light border">목록</a>
        <a href="noticeEdit.jsp?no=<%= dto.getNoticeNo() %>" class="btn btn-outline-primary">수정</a>
        <a href="../deleteNotice.do?noticeNo=<%= dto.getNoticeNo() %>"
           class="btn btn-outline-danger"
           onclick="return confirm('정말 삭제할까요?')">삭제</a>
    </div>
</div>
</body>
</html>
