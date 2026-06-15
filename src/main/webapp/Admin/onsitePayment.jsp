<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/adminTem/headTem.jsp" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="dto.BootDto" %>

<%
    // 서블릿에서 보낸 동적 데이터 수신
    List<BootDto> bootList = (List<BootDto>) request.getAttribute("bootList");
    if (bootList == null) bootList = new ArrayList<>();

    int currentPage = (request.getAttribute("currentPage") != null) ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPage = (request.getAttribute("totalPage") != null) ? (Integer) request.getAttribute("totalPage") : 1;
    
    String bootStatus = (String) request.getAttribute("bootStatus");
    if(bootStatus == null) bootStatus = "전체";

    String bootTime = (String) request.getAttribute("bootTime");
    if(bootTime == null) bootTime = "upcoming";
%>

<style>
    body { background-color: #f8f9fa; }
    /* 검색 영역 카드 스타일 */
    .search-card { background-color: white; border: 1px solid #ebedf2; }
    .search-label { font-size: 12px; color: #a3a6b5; font-weight: 600; margin-bottom: 4px; }
    
    /* 테이블 스타일 조정 */
    .table th { color: #8a92a6; font-weight: 500; background-color: #f8f9fa; border-bottom: 1px solid #edeff2; }
    .table td { vertical-align: middle; color: #495057; font-size: 14px; padding: 14px 8px; }
    
    /* 연락처 메모 트리거 */
    .memo-trigger { color: #0d6efd; cursor: pointer; text-decoration: underline; text-underline-offset: 3px; }
    .memo-trigger:hover { color: #0a58ca; font-weight: bold; }
</style>

<div class="container-fluid px-4 mt-4">
    <h2 class="fw-bold fs-3 mb-3">현장결제 관리</h2>
    
    <div class="card border-0 shadow-sm p-3 mb-4 search-card rounded">
        <form method="get" action="${pageContext.request.contextPath}/Admin/onsitePayment" class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="search-label">예약 구분 (기간)</label> 
                <select class="form-select" name="bootTime">
                    <option value="upcoming" <%= "upcoming".equals(bootTime) ? "selected" : "" %>>현재 / 예정된 예약</option>
                    <option value="past" <%= "past".equals(bootTime) ? "selected" : "" %>>지난 예약 내역 (과거)</option>
                </select>
            </div>
            <div class="col-md-4">
                <label class="search-label">결제 상태</label> 
                <select class="form-select" name="bootStatus">
                    <option value="전체" <%= "전체".equals(bootStatus) ? "selected" : "" %>>전체 내역 보기</option>
                    <option value="예약대기" <%= "예약대기".equals(bootStatus) ? "selected" : "" %>>예약대기 건</option>
                    <option value="예약확정" <%= "예약확정".equals(bootStatus) ? "selected" : "" %>>예약확정 건</option>
                </select>
            </div>
            <div class="col-md-4">
                <button type="submit" class="btn text-white w-100 fw-bold" style="background-color: #1a2536; height: 38px;">필터 검색</button>
            </div>
        </form>
    </div>

    <div class="card border-0 shadow-sm bg-white rounded p-3">
        <table class="table text-center align-middle">
            <thead>
                <tr>
                    <th>예약번호</th>
                    <th>예약자명</th> 
                    <th>전화번호</th> 
                    <th>객실 종류</th>
                    <th>이용 타입</th>     
                    <th>체크인</th> 
                    <th>체크아웃</th>
                    <th>처리 상태</th> 
                    <th>객실 배정</th>
                </tr>
            </thead>
            <tbody>
                <% if(bootList.isEmpty()) { %>
                    <tr>
                        <td colspan="9" class="text-muted py-4">조회된 현장결제 내역이 없습니다.</td>
                    </tr>
                <% } else { 
                    for (BootDto boot : bootList) { 
                        String cleanCheckIn = boot.getBootCheckin();
                        String cleanCheckOut = boot.getBootCheckout();
                        if(cleanCheckIn != null && cleanCheckIn.length() >= 10) cleanCheckIn = cleanCheckIn.substring(0, 10);
                        if(cleanCheckOut != null && cleanCheckOut.length() >= 10) cleanCheckOut = cleanCheckOut.substring(0, 10);
                %>
                <tr>
                    <td class="fw-semibold text-secondary"><%= boot.getBootNo() %></td>
                    <td class="fw-bold"><%= boot.getBootName() %></td>
                    <td>
                        <span class="memo-trigger" onclick="openMemoModal('<%= boot.getBootName() %>', '<%= boot.getBootPhone() %>')">
                            <%= boot.getBootPhone() %>
                        </span>
                    </td>
                    <td><%= boot.getRoomGrade() %></td>
                    <td><%= (boot.getRoomType()==1?"싱글":boot.getRoomType()==2?"트윈":"패밀리") %></td>
                    <td><%= cleanCheckIn %></td>
                    <td><%= cleanCheckOut %></td>
                    <td>
                        <% if(boot.getBootConfirm() == 1) { %>
                            <span class="text-success fw-bold">예약확정</span>
                        <% } else { %>
                            <span class="text-warning fw-bold">예약대기</span>
                        <% } %>
                    </td>
                    <td>
						<button class="btn btn-sm text-white fw-bold" style="background-color: #0d6efd; border: none; border-radius: 4px; padding: 5px 12px;"
						        onclick="openManageModal(this, '<%= boot.getBootNo() %>')" 
						        data-room-grade="<%= boot.getRoomGrade() %>" 
						        data-room-type="<%= boot.getRoomType() %>"
						        data-room-type-text="<%= (boot.getRoomType()==1?"싱글":boot.getRoomType()==2?"트윈":"패밀리") %>"
						        data-checkin="<%= cleanCheckIn %>"
						        data-checkout="<%= cleanCheckOut %>"
						        data-please="<%= boot.getBootPlease() %>">
						    관리
						</button>
                    </td>
                </tr>
                <%   } 
                   } %>
            </tbody>
        </table>
    </div>
</div>

<nav class="mt-4">
   <ul class="pagination justify-content-center align-items-center">
      <li class="page-item mx-2 <%= currentPage <= 1 ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" href="?page=<%= currentPage - 1 %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>">&lt;</a>
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
                  <a class="page-link border-0 bg-transparent text-dark" href="?page=<%= i %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>"><%= i %></a>
               </li>
      <%    }
         } %>
         
      <li class="page-item mx-2 <%= currentPage >= totalPage ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" href="?page=<%= currentPage + 1 %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>">&gt;</a>
      </li>
   </ul>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 1. 상단 메뉴 활성화 및 스와핑 (headTem.jsp 연동용 주소 자동 매핑)
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

    // 연락처 클릭 시 메모 모달 바인딩 함수
    // 🎯 [수정] 자바스크립트 에러를 내던 오타 'Buchung'을 지웠습니다.
    function openMemoModal(name, phoneNo) {
        if(typeof $('#memoModal').modal === 'function') {
            $('#memoModal').modal('show');
        } else {
            alert("메모 모달을 불러올 수 없습니다.");
        }
    }
</script>

<%@ include file="/adminTem/memoModal.jsp" %>
<%@ include file="/adminTem/roomAssignModal.jsp" %>
<%@ include file="/adminTem/footTem.jsp" %>