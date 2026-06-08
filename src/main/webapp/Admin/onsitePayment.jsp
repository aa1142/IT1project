<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/adminTem/headTem.jsp" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%
    int currentPage = (request.getAttribute("currentPage") != null) ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPage = (request.getAttribute("totalPage") != null) ? (Integer) request.getAttribute("totalPage") : 3;
    
    String searchDate = request.getParameter("searchDate");
    if(searchDate == null) searchDate = "2026-06-08"; 
    
    String payStatus = request.getParameter("payStatus");
    if(payStatus == null) payStatus = "전체";
%>

<style>
    body {
        background-color: #f8f9fa;
    }
    /* 검색 영역 카드 스타일 */
    .search-card {
        background-color: white;
        border: 1px solid #ebedf2;
    }
    .search-label {
        font-size: 12px;
        color: #a3a6b5;
        font-weight: 600;
        margin-bottom: 4px;
    }
    /* 테이블 스타일 조정 */
    .table th {
        color: #8a92a6;
        font-weight: 500;
        background-color: #f8f9fa;
        border-bottom: 1px solid #edeff2;
    }
    .table td {
        vertical-align: middle;
        color: #495057;
        font-size: 14px;
        padding: 14px 8px;
    }
    /* 상태 배지 스타일 */
    .badge-custom {
        border-radius: 20px;
        padding: 6px 16px;
        font-weight: bold;
        font-size: 13px;
        border: none;
        display: inline-block;
    }
    .badge-warning-light { background-color: #fff8e6; color: #ffb800; }
    .badge-blue-light { background-color: #e6f0ff; color: #0066ff; }
    .badge-success-light { background-color: #e6f9f0; color: #00cc66; }
    .badge-danger-light { background-color: #ffe6e6; color: #ff3333; }
</style>

<div class="container-fluid px-4 mt-4">
    <h2 class="fw-bold fs-3 mb-3">현장결제</h2>
    
    <div class="card border-0 shadow-sm p-3 mb-4 search-card rounded">
        <form method="get" action="" class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="search-label">체크인 날짜</label> 
                <input type="text" class="form-select" id="searchDate" name="searchDate" value="<%= searchDate %>">
            </div>
            <div class="col-md-3">
                <label class="search-label">결제 상태</label> 
                <select class="form-select" name="payStatus">
                    <option value="전체" <%= "전체".equals(payStatus) ? "selected" : "" %>>전체</option>
                    <option value="결제대기" <%= "결제대기".equals(payStatus) ? "selected" : "" %>>결제대기</option>
                    <option value="결제완료" <%= "결제완료".equals(payStatus) ? "selected" : "" %>>결제완료</option>
                </select>
            </div>
            <div class="col-md-4">
                <label class="search-label">예약자명 검색</label>
                <input type="text" class="form-control" name="keyword" placeholder="예약자명을 입력하세요.">
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn text-white w-100 fw-bold" style="background-color: #1a2536; height: 38px;">탐색</button>
            </div>
        </form>
    </div>

    <div class="card border-0 shadow-sm bg-white rounded p-3">
        <table class="table text-center align-middle">
            <thead>
                <tr>
                    <th>예약번호</th>
                    <th>예약자명</th> <th>객실 종류</th>
                    <th>인원</th>     <th>이용일</th>   <th>신청 시간</th>
                    <th>처리 상태</th> <th>신청 승인</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="fw-semibold text-secondary">K249810-0001</td>
                    <td class="fw-bold">라용행</td>
                    <td>디럭스</td>
                    <td>2명</td>
                    <td>2026-06-10</td>
                    <td>2026-06-18</td>
                    <td class="text-warning fw-bold">처리중</td>
                    <td><span class="badge-custom badge-warning-light">신청</span></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<nav class="mt-4">
   <ul class="pagination justify-content-center align-items-center">
      <li class="page-item mx-2 <%= currentPage <= 1 ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" href="?page=<%= currentPage - 1 %>">&lt;</a>
      </li>
      
      <% for (int i = 1; i <= totalPage; i++) { 
            if (i == currentPage) { %>
               <li class="page-item active mx-1">
                  <a class="page-link rounded-circle text-center d-inline-block p-0" 
                     style="width:32px; height:32px; line-height:32px; background-color:#1a2536; border:none;" href="#">
                     <%= i %>
                  </a>
               </li>
      <%    } else { %>
               <li class="page-item mx-1">
                  <a class="page-link border-0 bg-transparent text-dark" href="?page=<%= i %>"><%= i %></a>
               </li>
      <%    }
         } %>
         
      <li class="page-item mx-2 <%= currentPage >= totalPage ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" href="?page=<%= currentPage + 1 %>">&gt;</a>
      </li>
   </ul>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 1. 날짜 입력창 달력 UI 적용
        flatpickr("#searchDate", {
            locale: "ko",
            dateFormat: "Y-m-d"
        });

        // 2. 상단 메뉴 활성화 및 스와핑 (headTem.jsp에 정의된 id 요소를 찾아 자동으로 제어합니다)
        const currentPath = window.location.pathname; 
        const brandLogo = document.getElementById('dynamic-brand');
        const menuList = document.getElementById('dynamic-menu-list');
        
        if (menuList && brandLogo) {
            const navLinks = menuList.querySelectorAll('.nav-link');
            let matchedLink = null;
            
            navLinks.forEach(link => {
                const hrefAttr = link.getAttribute('href');
                if (hrefAttr && currentPath.includes(hrefAttr)) {
                    matchedLink = link;
                }
            });
            
            if (matchedLink) {
                const currentMenuText = matchedLink.innerText; 
                brandLogo.innerText = currentMenuText;
                brandLogo.setAttribute('href', matchedLink.getAttribute('href'));
                
                const parentLi = matchedLink.parentElement;
                parentLi.innerHTML = `<a class="nav-link" href="/HotelReservation/Admin/bootmng">예약관리</a>`;
            }
        }
    });
</script>

<%@ include file="/adminTem/footTem.jsp" %>