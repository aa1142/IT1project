<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="myNotice.NoticeDao" %>
<%@ page import="myNotice.NoticeDto" %>
<%@ page import="java.util.List" %>
<%
    String noticeUserGrade = (String) session.getAttribute("sessionUserGrade");
    String noticeUserId = (String) session.getAttribute("sessionUserId");
    String noticeAdmin =(String) session.getAttribute("adminId");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>JYPホテル - お知らせ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding: 50px 0; font-family: 'Pretendard', sans-serif; }
        .notice-wrap {
            max-width: 1140px;
            margin: 0 auto;
            padding: 0 12px;
        }
        .table thead { background-color: #1f2d3d; color: white; }
        .important-badge {
            display: inline-block;
            margin-right: 8px;
            padding: 3px 8px;
            border-radius: 4px;
            background-color: #dc3545;
            color: #fff;
            font-size: 0.78rem;
            font-weight: 700;
            vertical-align: middle;
        }
        .image-badge {
            display: inline-block;
            margin-left: 6px;
            color: #4b5563;
            font-size: 0.95rem;
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="notice-wrap mb-3">
    <a href="<%= request.getContextPath() %>/wls/index.jsp" class="btn btn-outline-dark btn-sm">ホームへ</a>
</div>
<% if (noticeAdmin!=null) { %>
<div class="notice-wrap mb-3">
    <a href="<%= request.getContextPath() %>/Admin/bootmng" class="btn btn-outline-dark btn-sm">予約管理</a>
</div>
<%} %>
<div class="notice-wrap">
    <h2 class="mb-4 fw-bold text-center"><%= noticeAdmin != null ? "お知らせ管理" : "お知らせ" %></h2>

    <table class="table table-hover text-center">
        <thead>
            <tr>
                <th style="width: 50%;">タイトル</th>
                <th>登録日</th>
                <th>照会数</th>
                <% if (noticeAdmin!=null) { %>
                    <th>管理</th>
                <% } %>
            </tr>
        </thead>
        <tbody>
        <%
            NoticeDao dao = new NoticeDao();
            List<NoticeDto> list = dao.getNoticeList();

            if (list == null || list.isEmpty()) {
        %>
            <tr>
                <td colspan="<%= noticeAdmin != null ? 4 : 3 %>">登録されたお知らせがありません。</td>
            </tr>
        <%
            } else {
                for (NoticeDto dto : list) {
                    String title = dto.getTitle() == null ? "" : dto.getTitle();
                    
                    // DB에 한국어 혹은 일본어로 저장되어 있을 중요 태그를 모두 검사합니다.
                    boolean important = title.startsWith("[중요공지]") || title.startsWith("[重要]");
                    String displayTitle = title;
                    String imageFile = dto.getImageFile();
                    boolean hasImage = imageFile != null && !imageFile.trim().isEmpty();
                    
                    if (important) {
                        // 중요 태그 문자열을 제거하고 실제 제목만 남깁니다.
                        displayTitle = title.replaceFirst("^\\[중요공지\\]\\s*", "").replaceFirst("^\\[重要\\]\\s*", "");
                    }
        %>	
            <tr>
                <td class="text-center">
                    <a href="noticeDetail.jsp?no=<%= dto.getNoticeNo() %>" class="text-decoration-none text-dark">
                        <% if (important) { %>
                            <span class="important-badge">重要</span>
                        <% } %>
                        <%= displayTitle %>
                        <% if (hasImage) { %>
                        <span class="image-badge" title="画像あり">&#128206;</span>
                        <% } %>
                    </a>
                </td>
                <td><%= dto.getRegDate() %></td>
                <td><%= dto.getHit() %></td>
                <% if (noticeAdmin != null) { %>
                    <td>
                        <a href="noticeEdit.jsp?no=<%= dto.getNoticeNo() %>" class="btn btn-sm btn-outline-primary">修正</a>
                        <a href="../deleteNotice.do?noticeNo=<%= dto.getNoticeNo() %>"
                           class="btn btn-sm btn-outline-danger"
                           onclick="return confirm('本当に削除しますか？')">削除</a>
                    </td>
                <% } %>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <% if (noticeAdmin != null) { %>
        <div class="text-end mt-4">
            <a href="noticeWrite.jsp" class="btn btn-dark">新規登録</a>
        </div>
    <% } %>
</div>
</body>
</html>
