<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // セッションに保存されたすべてのログイン情報を削除（初期化）します。
    session.invalidate();
%>
<script>
    alert("正常にログアウトされました。");
    location.href = "index.jsp"; // ログアウト後、メイン画面へ移動
</script>