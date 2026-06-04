<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/adminTem/headTem.jsp" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page import="adminDto.BootDto, adminDto.RoomDto" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.util.concurrent.TimeUnit" %>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<%
    List<BootDto> bootList = (List<BootDto>) request.getAttribute("bootList");
    if (bootList == null) bootList = new ArrayList<>();
    

    int currentPage = (request.getAttribute("currentPage") != null) ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPage = (request.getAttribute("totalPage") != null) ? (Integer) request.getAttribute("totalPage") : 1;
    String bootStatus = (String) request.getAttribute("bootStatus");
    if(bootStatus == null) bootStatus = "전체";

    String dateRange = request.getParameter("dateRange");
    SimpleDateFormat paramSdf = new SimpleDateFormat("yyyy-MM-dd");
    if (dateRange == null || dateRange.trim().isEmpty()) {
        Date today = new Date();
        Date nextWeek = new Date(today.getTime() + (7L * 24 * 60 * 60 * 1000));
        dateRange = paramSdf.format(today) + " ~ " + paramSdf.format(nextWeek);
    }
%>

<style>
    /* 객실 선택 UI 스타일 */
    .room-container { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 20px; }
    .room-box {
        width: 80px; height: 60px; border: 1px solid #dee2e6; border-radius: 4px;
        display: flex; flex-direction: column; justify-content: center; align-items: center;
        cursor: pointer; transition: all 0.2s; font-size: 12px; background-color: white;
    }
    .room-box:hover { border-color: #0d6efd; background-color: #f8fbff; }
    .room-box.selected { border: 2px solid #0d6efd !important; background-color: #e7f1ff; box-shadow: 0 0 8px rgba(13,110,253,0.3); }
    .room-box.reserved { background-color: #f8f9fa; color: #adb5bd; cursor: not-allowed; }
    
    /* 🎯 연락처 스타일 지정 (클릭 가능함을 시각적으로 알림) */
    .memo-trigger { color: #0d6efd; cursor: pointer; text-decoration: underline; text-underline-offset: 3px; }
    .memo-trigger:hover { color: #0a58ca; fw-bold; }
</style>

<script>
    let selectedRoomNum = null;
    let selectedBootNo = null; 

    document.addEventListener("DOMContentLoaded", function () {
        flatpickr("#dateRange", {
            mode: "range", locale: "ko", dateFormat: "Y-m-d", conjunction: " ~ ",
            defaultDate: "<%= dateRange %>".split(" ~ "), theme: "dark"
        });
    });

    // 방 클릭 시 테두리 변경 및 하단 배지 노출 처리 함수
    function selectRoom(el, roomNo) {
        if (el.classList.contains('reserved')) return;
        
        document.querySelectorAll('.room-box').forEach(box => box.classList.remove('selected'));
        el.classList.add('selected');
        
        document.getElementById('selectedRoomBadge').innerText = roomNo + "호";
        document.getElementById('selectedRoomBadge').classList.remove('d-none');
        document.getElementById('noSelectText').classList.add('d-none');
        
        selectedRoomNum = roomNo;
    }

    function openManageModal(element, bootNo) {
        const row = element.closest('tr');
        
        selectedBootNo = bootNo; 
        selectedRoomNum = null;  
        document.getElementById('selectedRoomBadge').classList.add('d-none');
        document.getElementById('selectedRoomBadge').innerText = "";
        document.getElementById('noSelectText').classList.remove('d-none');

        let checkInDate = row.cells[3].innerText;  
        let checkOutDate = row.cells[4].innerText; 

        if (checkInDate && checkInDate.length >= 10) {
            checkInDate = checkInDate.substring(0, 10);
        }
        if (checkOutDate && checkOutDate.length >= 10) {
            checkOutDate = checkOutDate.substring(0, 10);
        }

        document.getElementById('modalResNo').innerText = row.cells[0].innerText;
        document.getElementById('modalGuestName').innerText = row.cells[1].innerText;
        document.getElementById('modalPhone').innerText = row.cells[2].innerText;
        
        document.getElementById('modalCheckIn').innerText = checkInDate;
        document.getElementById('modalCheckOut').innerText = checkOutDate;
        
        document.getElementById('modalRoomType').innerText = element.getAttribute('data-room-grade');
        document.getElementById('modalBootPlease').innerText = element.getAttribute('data-please') || "없음";

        const grade = element.getAttribute('data-room-grade');
        const typeText = row.cells[6].innerText; 
        const type = typeText === "싱글" ? 1 : (typeText === "트윈" ? 2 : 5);

        $.ajax({
            url: '${pageContext.request.contextPath}/admin/getAvailableRooms',
            type: 'GET',
            data: { grade: grade, type: type, checkIn: checkInDate, checkOut: checkOutDate },
            success: function(data) {
                const container = $('#dynamicRoomContainer');
                container.empty(); 
                
                if(!data || data.length === 0) {
                    container.append('<p class="text-muted small p-3 text-center">현재 배정 가능한 빈 객실이 없습니다.</p>');
                } else {
                    let html = '<div class="room-container">';
                    
                    data.forEach(room => {
                        const roomNum = room.roomNo || room.room_no; 
                        
                        html += '<div class="room-box" onclick="selectRoom(this, \'' + roomNum + '\')">'
                             + '    <span class="fw-bold">' + roomNum + '호</span>'
                             + '    <small>사용 가능</small>'
                             + '</div>';
                    });
                    
                    html += '</div>';
                    container.append(html);
                }
            },
            error: function(xhr, status, error) {
                console.error(xhr.responseText);
                alert("객실 조회 실패!\n" + "상태 코드: " + xhr.status);
            }
        });

        $('#reservationModal').modal('show');
    }

    // 🎯 연락처 클릭 시 메모 모달을 띄워주는 함수
    function openMemoModal(name, phoneNo) {
        // 하단에 인클루드 된 memoModal의 ID가 'memoModal'이라고 가정합니다.
        // 만약 memoModal.jsp 내부의 실제 모달 ID가 다르다면 그 ID로 수정해 주어야 합니다.
        if(typeof $('#memoModal').modal === 'function') {
            $('#memoModal').modal('show');
        } else {
            alert("메모 모달을 불러올 수 없습니다. 모달 ID를 확인해 주세요.");
        }
    }

    function assignRoomComplete() {
        if (!selectedBootNo) {
            alert("예약 정보가 올바르지 않습니다.");
            return;
        }
        if (!selectedRoomNum) {
            alert("배정할 객실을 선택해 주세요.");
            return;
        }

        if (confirm(selectedBootNo + "번 예약에 " + selectedRoomNum + "호 객실을 배정하시겠습니까?")) {
            $.ajax({
                url: '${pageContext.request.contextPath}/admin/assignRoom.do', 
                type: 'POST',
                data: { 
                    bootNo: selectedBootNo, 
                    roomNo: selectedRoomNum 
                },
                dataType: 'json',
                success: function(res) {
                    if (res.status === "success") {
                        alert("객실 배정이 완료되었습니다!");
                        $('#reservationModal').modal('hide');
                        location.reload(); 
                    } else {
                        alert("배정 실패: " + res.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert("서버와 통신 중 오류가 발생했습니다.");
                }
            });
        }
    }
</script>

<style>
    .room-container { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 25px; }
    
    .room-box {
        width: 100px; height: 70px; border: 2px solid #dee2e6; border-radius: 8px; 
        display: flex; flex-direction: column; justify-content: center; align-items: center;
        cursor: pointer; transition: all 0.2s ease; background-color: white;
    }
    .room-box span { font-size: 16px; font-weight: bold; }
    .room-box small { font-size: 12px; margin-top: 4px; color: #6c757d; }
    .room-box:hover { border-color: #0d6efd; background-color: #f0f7ff; transform: translateY(-2px); }
    .room-box.selected { border: 3px solid #0d6efd !important; background-color: #e7f1ff; box-shadow: 0 4px 12px rgba(13,110,253,0.2); }
    .room-box.reserved { background-color: #f8f9fa; color: #adb5bd; cursor: not-allowed; border-color: #e9ecef; }
</style>

<div class="container-fluid px-4">
    <h2 class="fw-bold fs-3 mb-3">예약관리</h2>
    <div class="card border-0 shadow-sm p-3 mb-4 bg-white rounded">
        <form method="get" action="" class="row g-2 align-items-end">
            <div class="col-md-3"><label class="form-label text-muted small">예약일정</label><input type="text" id="dateRange" name="dateRange" class="form-control" value="<%= dateRange %>" readonly></div>
            <div class="col-md-2">
                <label class="form-label text-muted small">예약처리</label>
                <select class="form-select" name="bootStatus">
                    <option value="전체" <%= "전체".equals(bootStatus) ? "selected" : "" %>>전체</option>
                    <option value="결제완료" <%= "결제완료".equals(bootStatus) ? "selected" : "" %>>결제완료</option>
                    <option value="예약확정" <%= "예약확정".equals(bootStatus) ? "selected" : "" %>>예약확정</option>
                </select>
            </div>
            <div class="col-md-2"><button type="submit" class="btn btn-primary w-100" style="background-color: #1a2536;">검색</button></div>
        </form>
    </div>

    <div class="card border-0 shadow-sm bg-white rounded p-3">
        <table class="table table-hover text-center align-middle">
            <thead><tr><th>예약번호</th><th>예약자명</th><th>연락처</th><th>체크인</th><th>체크아웃</th><th>등급</th><th>이용</th><th>상태</th><th>관리</th></tr></thead>
            <tbody>
               <% for (BootDto boot : bootList) { 
                    // 🎯 1. 자바단에서 안전하게 날짜 데이터 앞 10자리(YYYY-MM-DD)만 분리
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
                        <button class="btn btn-info btn-sm" onclick="openManageModal(this, '<%= boot.getBootNo() %>')" data-room-grade="<%= boot.getRoomGrade() %>" data-please="<%= boot.getBootPlease() %>">관리</button>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="reservationModal" tabindex="-1" aria-labelledby="reservationModalLabel" aria-hidden="true">
   <div class="modal-dialog modal-dialog-centered modal-xl">
      <div class="modal-content border-0 shadow-lg">
         <div class="modal-header text-white" style="background-color: #1a2536;">
            <h5 class="modal-title fw-bold" id="reservationModalLabel">예약 상세 - 객실 지정</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
         </div>
         <div class="modal-body bg-light p-4">
            <div class="row g-4">
               <div class="col-lg-4">
                  <div class="card border-0 shadow-sm p-3 mb-3 bg-white">
                     <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">📋 예약 정보</h6>
                     <div class="mb-2">
                        <small class="text-muted d-block">예약번호</small>
                        <span id="modalResNo" class="fw-bold text-secondary"></span>
                     </div>
                     <div class="mb-2">
                        <small class="text-muted d-block">예약자명</small>
                        <span id="modalGuestName" class="fw-bold text-dark"></span>
                     </div>
                     <div class="mb-2">
                        <small class="text-muted d-block">연락처</small>
                        <span id="modalPhone" class="fw-bold"></span>
                     </div>
                     <div class="row g-2 mt-2">
                        <div class="col-6">
                           <small class="text-muted d-block">체크인</small>
                           <span id="modalCheckIn" class="small fw-bold"></span>
                        </div>
                        <div class="col-6">
                           <small class="text-muted d-block">체크아웃</small>
                           <span id="modalCheckOut" class="small fw-bold"></span>
                        </div>
                     </div>
                  </div>
                  <div class="card border-0 shadow-sm p-3 bg-white">
                     <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">🛏️ 예약 객실 및 요청사항</h6>
                     <div class="mb-3">
                        <small class="text-muted d-block mb-1">객실 종류</small>
                        <span id="modalRoomType" class="fw-bold text-primary fs-6"></span>
                     </div>
                     <div>
                        <small class="text-muted d-block mb-1">고객 요청사항</small>
                        <div class="p-2 rounded bg-primary-subtle border border-primary-subtle">
                           <span id="modalBootPlease" class="small text-primary-emphasis fw-bold" style="word-break: break-all; white-space: pre-wrap;">없음</span>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-8">
                  <div class="card border-0 shadow-sm p-4 bg-white h-100">
                     <h6 class="fw-bold text-dark mb-3">🏢 객실 배정 현황</h6>
                     <div class="d-flex flex-wrap gap-3 mb-4 p-2 bg-light rounded small text-muted align-items-center">
                        <div class="d-flex align-items-center"><span class="d-inline-block bg-white border rounded me-2" style="width:16px; height:16px;"></span>사용 가능</div>
                        <div class="d-flex align-items-center"><span class="d-inline-block bg-secondary rounded me-2" style="width:16px; height:16px;"></span>예약됨</div>
                        <div class="d-flex align-items-center"><span class="d-inline-block bg-warning rounded me-2" style="width:16px; height:16px;"></span>청소 중</div>
                        <div class="d-flex align-items-center"><span class="d-inline-block bg-white border border-primary rounded me-2" style="width:16px; height:16px;"></span>선택됨</div>
                     </div>
                     <div id="dynamicRoomContainer" class="py-2">
                        <p class="text-muted small">관리 버튼을 누르면 실시간 객실 현황을 불러옵니다.</p>
                     </div>
                     <div class="mt-auto pt-3 border-top d-flex justify-content-between align-items-center">
                        <div>
                           <span class="text-muted small">선택된 객실:</span>
                           <span id="selectedRoomBadge" class="badge bg-primary fs-6 ms-2 px-3 py-2 d-none"></span>
                           <span id="noSelectText" class="text-secondary small ms-2">객실을 선택해 주세요.</span>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
         <div class="modal-footer bg-light">
            <button type="button" class="btn btn-light border" data-bs-dismiss="modal">취소</button>
            <button type="button" class="btn btn-primary" style="background-color: #0d6efd; border: none;" onclick="assignRoomComplete()">객실 지정 완료</button>
         </div>
      </div>
   </div>
</div>

<nav class="mt-4">
   <ul class="pagination justify-content-center align-items-center">
      <li class="page-item mx-2 <%= currentPage <= 1 ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" 
            href="?page=<%= currentPage - 1 %>&dateRange=<%= dateRange != null ? dateRange : "" %>&bootStatus=<%= bootStatus %>" aria-label="Previous">
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
                     href="?page=<%= i %>&dateRange=<%= dateRange != null ? dateRange : "" %>&bootStatus=<%= bootStatus %>">
                     <%= i %>
                  </a>
               </li>
      <%    }
         } %>
      <li class="page-item mx-2 <%= currentPage >= totalPage ? "disabled" : "" %>">
         <a class="page-link border-0 bg-transparent text-muted" 
            href="?page=<%= currentPage + 1 %>&dateRange=<%= dateRange != null ? dateRange : "" %>&bootStatus=<%= bootStatus %>" aria-label="Next">
            <span aria-hidden="true">&gt;</span>
         </a>
      </li>
   </ul>
</nav>

<%@ include file="/WEB-INF/Admin/memoModal.jsp" %>
<%@ include file="/WEB-INF/adminTem/footTem.jsp" %>