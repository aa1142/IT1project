<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String noticeUserGrade = (String) session.getAttribute("sessionUserGrade");
    boolean noticeAdmin = "管理者".equals(noticeUserGrade)
            || "관리자".equals(noticeUserGrade);

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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 작성</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-5" style="max-width: 700px;">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">공지 등록</h3>

        <form action="../insertNotice.do" method="POST" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label fw-bold">제목</label>
                <input type="text" name="title" class="form-control" placeholder="공지 제목 입력" required>
            </div>

            <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" name="important" value="Y" id="importantNotice">
                <label class="form-check-label fw-bold text-danger" for="importantNotice">
                    중요공지
                </label>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">공지 이미지 첨부</label>
                <input type="file" name="noticeImage" class="form-control" accept="image/*">
                <div class="form-text text-muted">이미지 파일(*.jpg, *.png, *.jpeg)만 업로드 가능합니다.</div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">내용</label>
                <textarea name="content" class="form-control" rows="10" placeholder="내용을 입력하세요" required></textarea>
            </div>

            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-dark w-50">등록 완료</button>
                <a href="noticeList.jsp" class="btn btn-light border w-50">취소</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
