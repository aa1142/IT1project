<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // 세션에 저장된 모든 로그인 정보를 삭제(초기화)합니다.
    session.invalidate();
%>
<script>
    alert("정상적으로 로그아웃 되었습니다.");
    location.href = "index.jsp"; // 로그아웃 후 다시 메인으로 이동
</script>
