<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%
    String noticeUserGrade = (String) session.getAttribute("sessionUserGrade");
    String noticeUserId = (String) session.getAttribute("sessionUserId");
    String noticeAdminId = (String) session.getAttribute("adminId");
    boolean noticeAdmin = noticeAdminId != null
            || "管理者".equals(noticeUserGrade)
            || "관리자".equals(noticeUserGrade)
            || (noticeUserId != null && noticeUserId.toLowerCase().startsWith("admin"));

    if (!noticeAdmin) {
%>
        <script>
            location.href = "noticeList.jsp";
        </script>
<%
        return;
    }

    int noticeNo = Integer.parseInt(request.getParameter("no"));
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
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お知らせ編集</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container pt-4" style="max-width: 700px;">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>
<div class="container py-5" style="max-width: 700px;">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">お知らせ編集</h3>

        <form action="../updateNotice.do" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="noticeNo" value="<%= dto.getNoticeNo() %>">
            <input type="hidden" name="origImage" value="<%= dto.getImageFile() == null ? "" : dto.getImageFile() %>">

            <div class="mb-3">
                <label class="form-label fw-bold">タイトル</label>
                <input type="text" name="title" class="form-control" value="<%= dto.getTitle() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">内容</label>
                <textarea name="content" class="form-control" rows="10" required><%= dto.getContent() %></textarea>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">画像の変更</label>
                <input type="file" name="noticeImage" class="form-control" accept="image/*">
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary w-50" style="background-color: #1f2d3d; border:none;">変更を保存</button>
                <a href="noticeList.jsp" class="btn btn-light border w-50">キャンセル</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
