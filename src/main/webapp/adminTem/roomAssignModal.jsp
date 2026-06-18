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
    console.log("モーダル読み込み完了");
    
    // 🎯 방 선택(클릭) 처리 함수
    function selectRoom(element, roomNum) {
        $('.room-box').removeClass('selected');
        $(element).addClass('selected');
        
        // ⚠️ 전역 변수에는 DB 전송을 위해 원래의 5자리 번호(예: 20101)를 그대로 저장합니다.
        selectedRoomNum = roomNum;
        
        // 렌더링: 배지 화면에 보여줄 때만 마지막 3글자만 출력 (예: 101号室)
        const displayRoomNum = String(roomNum).slice(-3);
        document.getElementById('selectedRoomBadge').innerText = displayRoomNum + "号室";
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

        document.getElementById('modalResNo').innerText = bootNo;
        document.getElementById('modalGuestName').innerText = row.cells[1].innerText; 
        document.getElementById('modalPhone').innerText = row.cells[2].innerText;     
        
        document.getElementById('modalCheckIn').innerText = checkInDate;
        document.getElementById('modalCheckOut').innerText = checkOutDate;
        
        document.getElementById('modalRoomType').innerText = grade + " (" + typeText + ")";
        
        const pleaseText = element.getAttribute('data-please');
        document.getElementById('modalBootPlease').innerText = 
            (pleaseText && pleaseText !== "null" && pleaseText.trim() !== "") ? pleaseText : "なし";

        // 빈 객실 실시간 비동기 조회 Ajax
        $.ajax({
            url: '${pageContext.request.contextPath}/admin/getAvailableRooms',
            type: 'GET',
            data: { grade: grade, type: type, checkIn: checkInDate, checkOut: checkOutDate },
            success: function(data) {
                const container = $('#dynamicRoomContainer');
                container.empty(); 
                
                if(!data || data.length === 0) {
                    container.append('<p class="text-muted small p-3 text-center">現在、割り当て可能な空き客室가 없습니다.</p>');
                } else {
                    let html = '<div class="room-container">';
                    data.forEach(room => {
                        const roomNum = room.roomNo || room.room_no; 
                        
                        // 🎯 [수정] 화면에 보여줄 3자리 방 호수 추출 (예: 20101 -> 101)
                        const displayRoomNum = String(roomNum).slice(-3);
                        
                        // 클릭 이벤트에는 원래 roomNum(5자리)을 넘겨주고, 화면 text에는 displayRoomNum(3자리)을 출력합니다.
                        html += '<div class="room-box" onclick="selectRoom(this, \'' + roomNum + '\')">'
                             + '    <span class="fw-bold">' + displayRoomNum + '号室</span>'
                             + '    <small>利用可能</small>'
                             + '</div>';
                    });
                    html += '</div>';
                    container.append(html);
                }
            },
            error: function(xhr, status, error) {
                console.error(xhr.responseText);
                alert("客室の照会に失敗しました。 " + "ステータスコード: " + xhr.status);
            }
        });

        $('#reservationModal').modal('show');
    }

    // 객실 지정 최종 완료 요청
    function assignRoomComplete() {
        console.log("ajax 들어옴");
        if (!selectedBootNo) { alert("予約情報が正しくありません。"); return; }
        if (!selectedRoomNum) { alert("割り当てる客室を選択してください。"); return; }
        
        // 🎯 [수정] 컨펌창 띄울 때도 마지막 3글자만 보여주도록 처리
        const displayRoomNum = String(selectedRoomNum).slice(-3);
        
        if (confirm(selectedBootNo + "番の予約に " + displayRoomNum + "号室を割り当てますか？")) {
            $.ajax({
                url: '${pageContext.request.contextPath}/admin/assignRoom.do', 
                type: 'POST',
                // ⚠️ 여기서는 원래의 5자리 번호(selectedRoomNum)를 서버로 전송해야 DB 처리가 정상적으로 이루어집니다.
                data: { bootNo: selectedBootNo, roomNo: selectedRoomNum},
                dataType: 'json',
                success: function(res) {
                    if (res.status === "success") {
                        alert("客室の割り当てが完了しました！");
                        $('#reservationModal').modal('hide');
                        location.reload(); 
                    } else {
                        alert("割り当て失敗: " + res.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert("サーバーとの通信中にエラーが発生しました。");
                }
            });
        }
    }
</script>

<div class="modal fade" id="reservationModal" tabindex="-1" aria-labelledby="reservationModalLabel" aria-hidden="true">
   <div class="modal-dialog modal-dialog-centered modal-xl">
      <div class="modal-content border-0 shadow-lg">
         <div class="modal-header text-white" style="background-color: #1a2536;">
            <h5 class="modal-title fw-bold" id="reservationModalLabel">予約詳細 - 客室割り当て</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
         </div>
         <div class="modal-body bg-light p-4">
            <div class="row g-4">
               <div class="col-lg-4">
                  <div class="card border-0 shadow-sm p-3 mb-3 bg-white">
                     <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">📋 予約情報</h6>
                     <div class="mb-2"><small class="text-muted d-block">予約番号</small><span id="modalResNo" class="fw-bold text-secondary"></span></div>
                     <div class="mb-2"><small class="text-muted d-block">予約者名</small><span id="modalGuestName" class="fw-bold text-dark"></span></div>
                     <div class="mb-2"><small class="text-muted d-block">連絡先</small><span id="modalPhone" class="fw-bold"></span></div>
                     <div class="row g-2 mt-2">
                        <div class="col-6"><small class="text-muted d-block">チェック인</small><span id="modalCheckIn" class="small fw-bold"></span></div>
                        <div class="col-6"><small class="text-muted d-block">チェックアウト</small><span id="modalCheckOut" class="small fw-bold"></span></div>
                     </div>
                  </div>
                  <div class="card border-0 shadow-sm p-3 bg-white">
                     <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">🛏️ 予約客室およびご要望</h6>
                     <div class="mb-3"><small class="text-muted d-block mb-1">客室タイプ</small><span id="modalRoomType" class="fw-bold text-primary fs-6"></span></div>
                     <div><small class="text-muted d-block mb-1">お客様のご要望</small>
                        <div class="p-2 rounded bg-primary-subtle border border-primary-subtle">
                           <span id="modalBootPlease" class="small text-primary-emphasis fw-bold" style="word-break: break-all; white-space: pre-wrap;">なし</span>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-lg-8">
                  <div class="card border-0 shadow-sm p-4 bg-white h-100">
                     <h6 class="fw-bold text-dark mb-3">🏢 割り当て可能な客室</h6>
                     <div id="dynamicRoomContainer" class="py-2">
                        <p class="text-muted small">リアルタイム의客室状況을読み込んでいます。</p>
                     </div>
                     <div class="mt-auto pt-3 border-top d-flex justify-content-between align-items-center">
                        <div>
                           <span class="text-muted small">選択された客室:</span>
                           <span id="selectedRoomBadge" class="badge bg-primary fs-6 ms-2 px-3 py-2 d-none"></span>
                           <span id="noSelectText" class="text-secondary small ms-2">客室を選択してください。</span>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
         <div class="modal-footer bg-light">
            <button type="button" class="btn btn-light border" data-bs-dismiss="modal">キャンセル</button>
            <button type="button" class="btn btn-primary" style="background-color: #0d6efd; border: none;" onclick="assignRoomComplete()">客室割り当て完了</button>
         </div>
      </div>
   </div>
</div>