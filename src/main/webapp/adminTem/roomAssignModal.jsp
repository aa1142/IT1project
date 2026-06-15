<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    /* 객실 선택 UI 스타일 */
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

<script>
    let selectedRoomNum = null;
    let selectedBootNo = null; 
	console.log("모달 들어옴");
    // 🎯 [추가] 누락되었던 방 선택(클릭) 처리 함수를 구현했습니다.
    function selectRoom(element, roomNum) {
        // 기존에 선택되어 있던 방들의 하이라이트(selected) 클래스 전부 제거
        $('.room-box').removeClass('selected');
        
        // 현재 클릭한 방 상자에 selected 클래스 추가 (테두리 파랗게 변경)
        $(element).addClass('selected');
        
        // 전역 변수에 클릭한 방 번호 저장
        selectedRoomNum = roomNum;
        
        // 모달 하단의 배지 업데이트 및 안내 문구 토글
        document.getElementById('selectedRoomBadge').innerText = roomNum + "호";
        document.getElementById('selectedRoomBadge').classList.remove('d-none');
        document.getElementById('noSelectText').classList.add('d-none');
    }

    // 관리 모달 열기 및 데이터 바인딩
    function openManageModal(element, bootNo) {
        const row = element.closest('tr');
        
        selectedBootNo = bootNo; 
        selectedRoomNum = null;  
        document.getElementById('selectedRoomBadge').classList.add('d-none');
        document.getElementById('selectedRoomBadge').innerText = "";
        document.getElementById('noSelectText').classList.remove('d-none');
        
        const grade = element.getAttribute('data-room-grade');
        const typeText = element.getAttribute('data-room-type-text');
        const type = parseInt(element.getAttribute('data-room-type')) || 1;
        const checkInDate = element.getAttribute('data-checkin');
        const checkOutDate = element.getAttribute('data-checkout');

        // 모달 상단 텍스트 바인딩
        document.getElementById('modalResNo').innerText = bootNo;
        document.getElementById('modalGuestName').innerText = row.cells[1].innerText; 
        document.getElementById('modalPhone').innerText = row.cells[2].innerText;     
        
        document.getElementById('modalCheckIn').innerText = checkInDate;
        document.getElementById('modalCheckOut').innerText = checkOutDate;
        
        document.getElementById('modalRoomType').innerText = grade + " (" + typeText + ")";
        
        
        const pleaseText = element.getAttribute('data-please');

     // 값이 없거나, 문자열 "null"이거나, 공백만 있는 경우 "없음"으로 처리
     document.getElementById('modalBootPlease').innerText = 
         (pleaseText && pleaseText !== "null" && pleaseText.trim() !== "") ? pleaseText : "없음";

        // 빈 객실 실시간 비동기 조회 Ajax
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
                alert("객실 조회 실패! " + "상태 코드: " + xhr.status);
            }
        });

        $('#reservationModal').modal('show');
    }

    // 객실 지정 최종 완료 요청
    function assignRoomComplete() {
        if (!selectedBootNo) { alert("예약 정보가 올바르지 않습니다."); return; }
        if (!selectedRoomNum) { alert("배정할 객실을 선택해 주세요."); return; }

        if (confirm(selectedBootNo + "번 예약에 " + selectedRoomNum + "호 객실을 배정하시겠습니까?")) {
            $.ajax({
                url: '${pageContext.request.contextPath}/admin/assignRoom.do', 
                type: 'POST',
                data: { bootNo: selectedBootNo, roomNo: selectedRoomNum, bootEmail: boot.getBootEmail },
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
                     <div class="mb-2"><small class="text-muted d-block">예약번호</small><span id="modalResNo" class="fw-bold text-secondary"></span></div>
                     <div class="mb-2"><small class="text-muted d-block">예약자명</small><span id="modalGuestName" class="fw-bold text-dark"></span></div>
                     <div class="mb-2"><small class="text-muted d-block">연락처</small><span id="modalPhone" class="fw-bold"></span></div>
                     <div class="row g-2 mt-2">
                        <div class="col-6"><small class="text-muted d-block">체크인</small><span id="modalCheckIn" class="small fw-bold"></span></div>
                        <div class="col-6"><small class="text-muted d-block">체크아웃</small><span id="modalCheckOut" class="small fw-bold"></span></div>
                     </div>
                  </div>
                  <div class="card border-0 shadow-sm p-3 bg-white">
                     <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">🛏️ 예약 객실 및 요청사항</h6>
                     <div class="mb-3"><small class="text-muted d-block mb-1">객실 종류</small><span id="modalRoomType" class="fw-bold text-primary fs-6"></span></div>
                     <div><small class="text-muted d-block mb-1">고객 요청사항</small>
                        <div class="p-2 rounded bg-primary-subtle border border-primary-subtle">
                           <span id="modalBootPlease" class="small text-primary-emphasis fw-bold" style="word-break: break-all; white-space: pre-wrap;">없음</span>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-8">
                  <div class="card border-0 shadow-sm p-4 bg-white h-100">
                     <h6 class="fw-bold text-dark mb-3">🏢 배정 가능한 방</h6>
                     <div id="dynamicRoomContainer" class="py-2">
                        <p class="text-muted small">실시간 객실 현황을 불러옵니다.</p>
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