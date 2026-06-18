<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%
    String noticeUserGrade = (String) session.getAttribute("sessionUserGrade");
    String noticeUserId = (String) session.getAttribute("sessionUserId");
    boolean noticeAdmin = "管理者".equals(noticeUserGrade)
            || "관리자".equals(noticeUserGrade)
            || (noticeUserId != null && noticeUserId.toLowerCase().startsWith("admin"));

    String noParam = request.getParameter("no");
    if (noParam == null || noParam.trim().isEmpty()) {
%>
        <script>
            alert("お知らせ番号がありません。");
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
            alert("存在しないお知らせです。");
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    dao.increaseHit(noticeNo);
    int displayHit = dto.getHit() + 1;

    String title = dto.getTitle() == null ? "" : dto.getTitle();
    // 데이터베이스에 한국어 혹은 일본어로 저장되어 있을 중요 태그를 모두 검사합니다.
    boolean important = title.startsWith("[중요공지]") || title.startsWith("[重要]");
    String displayTitle = title;
    if (important) {
        displayTitle = title.replaceFirst("^\\[중요공지\\]\\s*", "").replaceFirst("^\\[重要\\]\\s*", "");
    }
    String content = dto.getContent() == null ? "" : dto.getContent();
    String imageFile = dto.getImageFile();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル - <%= displayTitle %></title>
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
<div style="max-width:800px; margin:0 auto 20px auto;">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>
<div class="detail-card">
    <h2 class="detail-title">
        <% if (important) { %>
            <span class="important-badge">重要</span>
        <% } %>
        <%= displayTitle %>
    </h2>

    <div class="detail-meta">
        <span>No. <%= dto.getNoticeNo() %></span>
        <span class="mx-2">|</span>
        <span>登録日 <%= dto.getRegDate() %></span>
        <span class="mx-2">|</span>
        <span>照会数 <%= displayHit %></span>
    </div>

    <% if (imageFile != null && !imageFile.isEmpty()) { %>
        <img src="../upload/<%= imageFile %>" alt="お知らせ画像" class="detail-image">
    <% } %>

    <div class="detail-content"><%= content %></div>

    <div class="d-flex gap-2 mt-4 pt-3 border-top">
        <a href="noticeList.jsp" class="btn btn-light border">一覧へ</a>
        <% if (noticeAdmin) { %>
            <a href="noticeEdit.jsp?no=<%= dto.getNoticeNo() %>" class="btn btn-outline-primary">修正</a>
            <a href="../deleteNotice.do?noticeNo=<%= dto.getNoticeNo() %>"
               class="btn btn-outline-danger"
               onclick="return confirm('本当に削除しますか？')">削除</a>
        <% } %>
    </div>
</div>
</body>
</html>
