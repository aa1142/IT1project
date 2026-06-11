<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/adminTem/headTem.jsp" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page import="dto.BootDto,dto.RoomDto" %>
<%
    List<BootDto> bootList = (List<BootDto>) request.getAttribute("bootList");
    if (bootList == null) bootList = new ArrayList<>();
    
    int currentPage = (request.getAttribute("currentPage") != null) ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPage = (request.getAttribute("totalPage") != null) ? (Integer) request.getAttribute("totalPage") : 1;
    String bootStatus = (String) request.getAttribute("bootStatus");
    if(bootStatus == null) bootStatus = "전체";

    // 기간 필터 값 수신 (기본값: 현재/예정된 예약)
    String bootTime = (String) request.getAttribute("bootTime");
    if(bootTime == null) bootTime = "upcoming";
%>

<style>
    /* 🎯 연락처 스타일 지정 (클릭 가능함을 시각적으로 알림) */
    .memo-trigger { color: #0d6efd; cursor: pointer; text-decoration: underline; text-underline-offset: 3px; }
    .memo-trigger:hover { color: #0a58ca; font-weight: bold; }
</style>

<script>
    // 🎯 연락처 클릭 시 메모 모달을 띄워주는 함수 (본문 테이블에서 호출)
    function openMemoModal(name, phoneNo) {
        if(typeof $('#memoModal').modal === 'function') {
            $('#memoModal').modal('show');
        } else {
            alert("메모 모달을 불러올 수 없습니다. 모달 ID를 확인해 주세요.");
        }
    }
</script>

<div class="container-fluid px-4">
    <h2 class="fw-bold fs-3 mb-3">예약관리</h2>
    
    <div class="card border-0 shadow-sm p-3 mb-4 bg-white rounded">
        <form method="get" action="" class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label text-muted small fw-semibold">예약 구분</label>
                <select class="form-select" name="bootTime">
                    <option value="upcoming" <%= "upcoming".equals(bootTime) ? "selected" : "" %>>현재 / 예정된 예약</option>
                    <option value="past" <%= "past".equals(bootTime) ? "selected" : "" %>>지난 예약 내역 (과거)</option>
                </select>
            </div>
            
            <div class="col-md-3">
                <label class="form-label text-muted small fw-semibold">예약처리 상태조회</label>
                <select class="form-select" name="bootStatus">
                    <option value="전체" <%= "전체".equals(bootStatus) ? "selected" : "" %>>전체 내역 보기</option>
                    <option value="결제완료" <%= "결제완료".equals(bootStatus) ? "selected" : "" %>>결제완료 건</option>
                    <option value="예약확정" <%= "예약확정".equals(bootStatus) ? "selected" : "" %>>예약확정 건</option>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100" style="background-color: #1a2536; border: none; height: 38px;">필터 검색</button>
            </div>
        </form>
    </div>

    <div class="card border-0 shadow-sm bg-white rounded p-3">
        <table class="table table-hover text-center align-middle">
            <thead>
                <tr>
                    <th>예약번호</th>
                    <th>예약자명</th>
                    <th>연락처</th>
                    <th>체크인</th>
                    <th>체크아웃</th>
                    <th>등급</th>
                    <th>이용</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
               <% for (BootDto boot : bootList) { 
                    String cleanCheckIn = boot.getBootCheckin();
                    String cleanCheckOut = boot.getBootCheckout();
                    if(cleanCheckIn != null && cleanCheckIn.length() >= 10) cleanCheckIn = cleanCheckIn.substring(0, 10);
                    if(cleanCheckOut != null && cleanCheckOut.length() >= 10) cleanCheckOut = cleanCheckOut.substring(0, 10);
               %>
                <tr>
                    <td><%= boot.getBootNo() %></td>
                    <td><%= boot.getBootName() %></td>
                    <td>
                        <span class="memo-trigger" onclick="openMemoModal('<%= boot.getBootName() %>', '<%= boot.getBootPhone() %>')">
                            <%= boot.getBootPhone() %>
                        </span>
                    </td>
                    <td><%= cleanCheckIn %></td>
                    <td><%= cleanCheckOut %></td>
                    <td><%= boot.getRoomGrade() %></td>
                    <td><%= (boot.getRoomType()==1?"싱글":boot.getRoomType()==2?"트윈":"패밀리") %></td>
                    <td><%= (boot.getBootConfirm()==1?"예약확정":"결제완료") %></td>
                    <td>
                        <button type="button" 
						        class="btn btn-info btn-sm" 
						        onclick="openManageModal(this, '<%= boot.getBootNo() %>')" 
						        data-room-grade="<%= boot.getRoomGrade() != null ? boot.getRoomGrade() : "" %>" 
						        data-please="<%= boot.getBootPlease() != null ? boot.getBootPlease().replace("\"", "&quot;").replace("\r\n", " ") : "" %>" 
						        data-checkin="<%= cleanCheckIn %>" 
						        data-checkout="<%= cleanCheckOut %>" 
						        data-room-type-text="<%= boot.getRoomType() == 1 ? "싱글" : boot.getRoomType() == 2 ? "트윈" : "패밀리" %>">
						    관리
						</button>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<nav class="mt-4">
   <ul class="pagination justify-content-center align-items-center">
      <li class="page-item mx-2 <%= currentPage <= 1 ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted"  
            href="?page=<%= currentPage - 1 %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>" aria-label="Previous">
            <span aria-hidden="true">&lt;</span>
         </a>
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
                  <a class="page-link border-0 bg-transparent text-dark"  
                     href="?page=<%= i %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>">
                     <%= i %>
                  </a>
               </li>
      <%    }
         } %>
         
      <li class="page-item mx-2 <%= currentPage >= totalPage ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted"  
            href="?page=<%= currentPage + 1 %>&bootStatus=<%= bootStatus %>&bootTime=<%= bootTime %>" aria-label="Next">
            <span aria-hidden="true">&gt;</span>
         </a>
      </li>
   </ul>
</nav>

<%@ include file="/adminTem/memoModal.jsp" %>
<%@ include file="/adminTem/roomAssignModal.jsp" %>
<%@ include file="/adminTem/footTem.jsp" %>