<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String noticeUserGrade = (String) session.getAttribute("sessionUserGrade");
    String noticeUserId = (String) session.getAttribute("sessionUserId");
    boolean noticeAdmin = "管理者".equals(noticeUserGrade)
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
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お知らせ登録</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5" style="max-width: 700px;">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">お知らせ登録</h3>

        <form action="../insertNotice.do" method="POST" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label fw-bold">タイトル</label>
                <input type="text" name="title" class="form-control" placeholder="お知らせのタイトルを入力" required>
            </div>

            <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" name="important" value="Y" id="importantNotice">
                <label class="form-check-label fw-bold text-danger" for="importantNotice">
                    重要
                </label>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">お知らせ画像の添付</label>
                <input type="file" name="noticeImage" class="form-control" accept="image/*">
                <div class="form-text text-muted">画像ファイル（*.jpg、*.png、*.jpeg）のみアップロード可能です。</div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">内容</label>
                <textarea name="content" class="form-control" rows="10" placeholder="内容を入力してください" required></textarea>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-dark w-50">登録する</button>
                <a href="noticeList.jsp" class="btn btn-light border w-50">キャンセル</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
