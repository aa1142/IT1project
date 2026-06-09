<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%
    // 목록에서 보낸 번호(?no=번호) 가로채기
    int noticeNo = Integer.parseInt(request.getParameter("no"));
    NoticeDao dao = new NoticeDao();
    NoticeDto dto = dao.getNoticeDetail(noticeNo); // 기존 정보 가져오기
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>공지사항 수정</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5" style="max-width: 700px;">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">공지 수정</h3>
        <form action="../updateNotice.do" method="POST">
            <input type="hidden" name="noticeNo" value="<%= dto.getNoticeNo() %>">
            
            <div class="mb-3">
                <label class="form-label fw-bold">제목</label>
                <input type="text" name="title" class="form-control" value="<%= dto.getTitle() %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">내용</label>
                <textarea name="content" class="form-control" rows="10" required><%= dto.getContent() %></textarea>
            </div>
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary w-50" style="background-color: #1f2d3d; border:none;">수정 완료</button>
                <a href="noticeList.jsp" class="btn btn-light border w-50">취소</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>