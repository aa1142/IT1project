<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JYP 호텔 - 공지사항 목록</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 50px; font-family: 'Pretendard', sans-serif; }
        .table thead { background-color: #1f2d3d; color: white; }
    </style>
</head>
<body>
<div class="container">
    <h2 class="mb-4 fw-bold">공지사항 관리</h2>
    
    <table class="table table-hover text-center">
        <thead>
            <tr>
                <th>번호</th>
                <th style="width: 50%;">제목</th>
                <th>작성일</th>
                <th>조회수</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
        <%
            NoticeDao dao = new NoticeDao();
            List<NoticeDto> list = dao.getNoticeList();
            
            if(list.isEmpty()) {
                out.print("<tr><td colspan='5'>등록된 공지가 없습니다.</td></tr>");
            } else {
                for(NoticeDto dto : list) {
        %>
            <tr>
                <td><%= dto.getNoticeNo() %></td>
                <td class="text-start"><%= dto.getTitle() %></td>
                <td><%= dto.getRegDate() %></td>
                <td><%= dto.getHit() %></td>
                <td>
                    <a href="noticeEdit.jsp?no=<%= dto.getNoticeNo() %>" class="btn btn-sm btn-outline-primary">수정</a>
                    <a href="../deleteNotice.do?noticeNo=<%= dto.getNoticeNo() %>" 
                       class="btn btn-sm btn-outline-danger" 
                       onclick="return confirm('정말 삭제할까요?')">삭제</a>
                </td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <div class="text-end mt-4">
        <a href="noticeWrite.jsp" class="btn btn-dark">공지 등록</a>
    </div>
</div>
</body>
</html>