<%@page import="java.io.Console"%>
<%@page import="dao.BootDao"%>
<%@page import="dto.RoomDto"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap, java.util.Iterator" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { background-color: #f8f9fa; font-family: 'Malgun Gothic', sans-serif; }
        
        /* 🎨 状態別背景色カスタム */
        .status-available { background-color: #e8f7ee !important; color: #198754 !important; border: 1px solid #c3e6cb; }
        .status-occupied  { background-color: #e8f0fe !important; color: #0d6efd !important; border: 1px solid #b8daff; }
        .status-cleaning  { background-color: #fff3cd !important; color: #ffc107 !important; border: 1px solid #ffeeba; }
        .status-inspecting{ background-color: #f8d7da !important; color: #dc3545 !important; border: 1px solid #f5c6cb; }
        
        /* 🌟 本日予約ありカードスタイル (紫系) */
		.status-upcoming { 
		    background-color: #f3e5f5 !important; 
		    color: #8e24aa !important; 
		    border: 1px solid #d1c4e9; 
		}
        
        /* 客室カードスタイル - 내부 여백 최적화 */
        .room-card {
            width: 140px; height: 80px; display: flex; flex-direction: column;
            justify-content: center; align-items: center; border-radius: 10px;
            font-weight: bold; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            cursor: pointer; transition: transform 0.2s; padding: 4px 0;
        }
        .room-card:hover { transform: scale(1.05); }
        .legend-box { display: inline-block; width: 12px; height: 12px; margin-right: 5px; vertical-align: middle; }
    </style>
</head>
<body>

    <jsp:include page="/adminTem/headTem.jsp" />

    <%
        // 🌟 本日の日付取得 (例: "2026-06-09")
        String todayStr = java.time.LocalDate.now().toString();

        Map<String, Integer> roomCounts = (Map<String, Integer>) request.getAttribute("roomCounts");
        if (roomCounts == null) roomCounts = new HashMap<>();

        List<RoomDto> roomList = (List<RoomDto>) request.getAttribute("roomList");
        if (roomList == null) roomList = new ArrayList<>();

        int stdCount = roomCounts.get("STANDARD") != null ? roomCounts.get("STANDARD") : 0;
        int dlxCount = roomCounts.get("DELUXE") != null ? roomCounts.get("DELUXE") : 0;
        int steCount = roomCounts.get("SUITE") != null ? roomCounts.get("SUITE") : (roomCounts.get("SUITE") != null ? roomCounts.get("SUITE") : 0);
        int totalRooms = stdCount + dlxCount + steCount;

        int countAvailable   = request.getAttribute("countAvailable") != null ? (Integer) request.getAttribute("countAvailable") : 0;
        int countOccupied    = request.getAttribute("countOccupied") != null ? (Integer) request.getAttribute("countOccupied") : 0;
        int countCleaning    = request.getAttribute("countCleaning") != null ? (Integer) request.getAttribute("countCleaning") : 0;
        int countInspecting = request.getAttribute("countInspecting") != null ? (Integer) request.getAttribute("countInspecting") : 0;
    %>

    <div class="container-fluid px-5 py-4">
        <div class="row">
            
            <div class="col-md-2">
                <div class="card p-3 shadow-sm bg-white" style="border-radius: 12px; min-height: 400px;">
                    <span class="text-muted small fw-bold">全客室</span>
                    <div class="d-flex justify-content-between align-items-end border-bottom pb-2 mb-3">
                        <h4 class="fw-bold m-0"><%= totalRooms %>室</h4>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3">
                        <span class="fw-semibold text-secondary">STANDARD</span>
                        <span class="fw-bold text-dark"><%= stdCount %></span>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3 border-top pt-2">
                        <span class="fw-semibold text-secondary">DELUXE</span>
                        <span class="fw-bold text-dark"><%= dlxCount %></span>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3 border-top pt-2">
                        <span class="fw-semibold text-secondary">スイート</span>
                        <span class="fw-bold text-dark"><%= steCount %></span>
                    </div>
                </div>
            </div>

            <div class="col-md-10">
                
                <div class="row g-3 mb-3">
                    <div class="col"><div class="card p-3 text-center status-available shadow-sm"><div class="small">空室</div><h3 class="fw-bold m-0 mt-1"><%= countAvailable %>室</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-occupied shadow-sm"><div class="small">宿泊中</div><h3 class="fw-bold m-0 mt-1"><%= countOccupied %>室</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-cleaning shadow-sm"><div class="small">清掃中</div><h3 class="fw-bold m-0 mt-1"><%= countCleaning %>室</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-inspecting shadow-sm"><div class="small">点検中</div><h3 class="fw-bold m-0 mt-1"><%= countInspecting %>室</h3></div></div>
                </div>

                <div class="mb-4 small fw-semibold text-secondary">
                    <span class="me-3"><span class="legend-box status-available"></span>空室</span>
                    <span class="me-3"><span class="legend-box status-upcoming"></span>本日予約あり</span>
                    <span class="me-3"><span class="legend-box status-occupied"></span>宿泊中</span>
                    <span class="me-3"><span class="legend-box status-cleaning"></span>清掃中</span>
                    <span><span class="legend-box status-inspecting"></span>点検中</span>
                </div>

                <h5 class="fw-bold mb-3">客室状況ボード</h5>

                <% 
                	BootDao bootDao = new BootDao();
                    int lastFloor = 0; 
                    
                    for (RoomDto room : roomList) {
                        int currentFloor = room.getRoomNo()/100;
                        if (currentFloor != lastFloor) {
                            if (lastFloor != 0) {
                %>
                                </div></div> 
                <%
                            }
                %>
                            <div class="mb-4">
                                <div class="fw-bold text-dark mb-2"><%= currentFloor %>階</div>
                                <div class="d-flex flex-wrap gap-3">
                <% 
                                    lastFloor = currentFloor;
                        } 
                                        
                        String roomNow   = room.getRoomNow() != null ? room.getRoomNow() : "";
                        String roomNo    = String.valueOf(room.getRoomNo());
                        String roomGrade = room.getRoomGrade() != null ? room.getRoomGrade() : "";
                        int roomType = room.getRoomType();
                        String roomTypeName = "";
                        switch(roomType){
                        case 1:
                        	roomTypeName = "シングル";
                        	break;
                        case 2:
                        	roomTypeName = "ツイン";
                        	break;
                        case 5:
                        	roomTypeName = "ファミリー";
                        	break;	
                        }
                        
                        String[] firstCheckInOut = bootDao.SelectOneFirstBootDate(room.getRoomNo(), room.getCompanyNo());
                        String firstCheckIn = "";
                        String firstCheckOut = "";
                        String reservationDisplay = "予約なし"; 
                        if (firstCheckInOut != null && firstCheckInOut[0] != null && !firstCheckInOut[0].trim().equals("")) {
                            firstCheckIn = firstCheckInOut[0];
                            firstCheckOut = firstCheckInOut[1];
                            reservationDisplay = firstCheckIn + " ~ " + firstCheckOut; 
                            
                            if (firstCheckIn.contains(todayStr)) {
                                if (roomNow.equals("空室") || roomNow.equals("予約中") || roomNow.equals("チェックイン予定")) {
                                    roomNow = "本日予約あり";
                                }
                            }
                        }
                        
                        String cardClass = "";
                        String statusText = "";
                                
                        switch (roomNow) {
                            case "空室":
                                cardClass = "status-available";
                                statusText = "空室";
                                break;
                                
                            case "本日予約あり": 
                            case "チェックイン予定": 
                                cardClass = "status-upcoming";
                                statusText = "本日予約あり";
                                break;
                                
                            case "予約中":
                            case "宿泊中": 
                                cardClass = "status-occupied";
                                statusText = "宿泊中";
                                break;
                                
                            case "清掃中":
                                cardClass = "status-cleaning";
                                statusText = "清掃中";
                                break;
                                
                            default:       
                                cardClass = "status-inspecting";
                                statusText = "点検中";
                                break;
                        }
                        
                %>
                <div class="room-card <%= cardClass %>" onclick="openRoomModal('<%= roomNo %>', '<%= roomGrade %>', '<%= statusText %>', '<%= firstCheckIn %>', '<%= roomType %>')">
                    <div class="text-muted fw-bold" style="font-size: 11px; line-height: 1.1;"><%= String.format("%03d", room.getRoomNo() % 1000) %>号室</div>
				    
				    <div style="font-size: 12px; line-height: 1.2; margin-top: 1px;"><%= roomGrade %></div>
				    
                    <div class="text-secondary fw-bold" style="font-size: 11px; line-height: 1.1; margin-bottom: 2px;"><%= roomTypeName %></div>
				    
				    <div style="font-size: 11px; font-weight: normal; opacity: 0.85; line-height: 1.1;">
				        <% if (statusText.equals("本日予約あり")) { %>
				            <span class="fw-bold" style="color: #8e24aa;">⏰ CI予定</span>
				        <% } else if (!roomNow.equals("宿泊中")&&firstCheckInOut != null && firstCheckInOut[0] != null && !firstCheckInOut[0].trim().equals("")) { 
				            String shortDate = (firstCheckIn.length() >= 10) ? firstCheckIn.substring(5, 10).replace("-", "/") : "";
				        %>
				            <span class="text-secondary">📅 <%= shortDate %></span>
				        <% } else { %>
				            <span><%= statusText %></span>
				        <% } %>
				    </div>
				</div>
                <% 
                    } 
                    
                    if (lastFloor != 0) {
                %>
                        </div></div>
                <% 
                    } 
                %>

            </div> 
        </div> 
    </div> 

    <div class="modal fade" id="roomDetailModal" tabindex="-1" aria-labelledby="roomDetailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow border-0" style="border-radius: 15px;">
                <div class="modal-header bg-dark text-white" style="border-top-left-radius: 14px; border-top-right-radius: 14px;">
                    <h5 class="modal-title fw-bold" id="roomDetailModalLabel">🚪 客室詳細情報</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <table class="table table-bordered align-middle text-center m-0">
                        <tbody>
                            <tr>
                                <th class="table-light text-secondary" style="width: 35%;">客室番号</th>
                                <td id="modalRoomNo" class="fw-bold fs-5 text-dark"></td>
                            </tr>
                            <tr>
                                <th class="table-light text-secondary">客室グレード</th>
                                <td id="modalRoomGrade" class="fw-semibold text-primary"></td>
                            </tr>
                            <tr>
                                <th class="table-light text-secondary">現在のステータス</th>
                                <td>
                                    <span id="modalRoomStatus" class="fw-bold fs-5" style="cursor: pointer;" onclick="toggleStatusEdit()"></span>
                                    
                                    <select id="modalStatusSelect" class="form-select form-select-sm d-none mx-auto" style="width: 70%;" onchange="changeStatusBadge(this.value)">
                                        <option value="空室">空室</option>
                                        <option value="本日予約あり">本日予約あり</option> 
                                        <option value="宿泊中">宿泊中</option>
                                        <option value="清掃中">清掃中</option>
                                        <option value="点検中">点検中</option>
                                    </select>
                                </td>
                            </tr>
                            
                            <tr id="rowName" class="status-dependent-row">
                                <th class="table-light text-secondary">宿泊者名</th>
                                <td>
                                    <span id="modalRoomName" class="text-dark fw-medium">-</span>
                                    <input type="text" id="inputRoomName" class="form-control form-control-sm d-none mx-auto" style="width: 80%;" placeholder="宿泊者氏名">
                                </td> 
                            </tr>
                            <tr id="rowPhone" class="status-dependent-row">
                                <th class="table-light text-secondary">電話番号</th>
                                <td>
                                    <span id="modalRoomPhone" class="memo-trigger" style="cursor: pointer; text-decoration: underline; color: #007bff;">-</span>
                                    <input type="text" id="inputRoomPhone" class="form-control form-control-sm d-none mx-auto" style="width: 80%;" placeholder="010-0000-0000" maxlength="13">
                                </td>
                            </tr>
                            <tr id="rowAdult" class="status-dependent-row">
                                <th class="table-light text-secondary">大人</th>
                                <td>
                                    <span id="modalRoomAdult" class="text-dark fw-medium">-</span>
                                    <input type="number" id="inputRoomAdult" class="form-control form-control-sm d-none mx-auto" style="width: 50%;" min="0" value="0">
                                </td>
                            </tr>
                            <tr id="rowChild" class="status-dependent-row">
                                <th class="table-light text-secondary">子供</th>
                                <td>
                                    <span id="modalRoomChild" class="text-dark fw-medium">-</span>
                                    <input type="number" id="inputRoomChild" class="form-control form-control-sm d-none mx-auto" style="width: 50%;" min="0" value="0">
                                </td>
                            </tr>
                            <tr id="rowCheckInOut" class="status-dependent-row">
                                <th class="table-light text-secondary">予約期間</th>
                                <td>
                                    <span id="modalRoomCheckInOut" class="text-dark fw-medium">-</span>
                                    <div id="inputCheckInOutGroup" class="d-flex gap-1 justify-content-center d-none">
                                        <input type="date" id="inputCheckin" class="form-control form-control-sm">
                                        <span class="align-self-center">~</span>
                                        <input type="date" id="inputCheckout" class="form-control form-control-sm">
                                    </div>
                                </td> 
                            </tr>
                            <tr id="rowNextReservation" class="status-dependent-row">
							    <th class="table-light text-secondary">次回予約日</th>
							    <td id="modalNextReservation" class="text-danger fw-bold">-</td> 
							</tr>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer" style="border-top: none;">
                    <button type="button" class="btn btn-secondary fw-semibold" data-bs-dismiss="modal">閉じる</button>
                    <button type="button" class="btn btn-primary fw-semibold" onclick="submitStatusLetter()">状態変更</button>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/adminTem/memoModal.jsp" %>
    
 <script>
var currentFirstCheckin = "";
var currentRoomGrade = "";
var currentRoomType = "";

$(document).on('input', '#inputRoomPhone', function() {
    let val = $(this).val().replace(/[^0-9]/g, ''); 
    let formatted = '';

    if (val.length < 4) {
        formatted = val;
    } else if (val.length < 8) {
        formatted = val.substr(0, 3) + '-' + val.substr(3);
    } else if (val.length < 11) {
        formatted = val.substr(0, 3) + '-' + val.substr(3, 3) + '-' + val.substr(6);
    } else {
        formatted = val.substr(0, 3) + '-' + val.substr(3, 4) + '-' + val.substr(7, 4);
    }
    $(this).val(formatted);
});

function openRoomModal(roomNo, roomGrade, statusText, firstCheckin, roomType) {
    console.log("モーダルオープン:", roomNo);
    
    currentFirstCheckin = firstCheckin; 
    currentRoomGrade = roomGrade;
    currentRoomType = roomType;
    
    document.getElementById('modalRoomNo').innerText = roomNo + "号室";
    document.getElementById('modalRoomGrade').innerText = roomGrade;
    
    document.getElementById('modalRoomStatus').classList.remove('d-none');
    document.getElementById('modalStatusSelect').classList.add('d-none');
    
    const todayStr = '<%= todayStr %>'; 
    const hasReservationToday = firstCheckin && firstCheckin.includes(todayStr);
    const $upcomingOption = $('#modalStatusSelect option[value="本日予約あり"]');

    if (hasReservationToday) {
        $upcomingOption.show().prop('disabled', true);
    } else {
        $upcomingOption.hide().prop('disabled', true);
    }
    
    updateBadgeDesign(statusText);
    document.getElementById('modalStatusSelect').value = statusText;
    
    toggleConditionalRows(statusText);
    clearReservationFields();
    toggleWalkInInputs(false); 

    if (firstCheckin && firstCheckin !== "null" && firstCheckin.trim() !== "") {
        document.getElementById('modalNextReservation').innerText = firstCheckin;
    } else {
        document.getElementById('modalNextReservation').innerText = "予約履歴なし";
    }

    $.ajax({
        url: "${pageContext.request.contextPath}/Admin/getSelectBoot",
        type: "GET",
        data: { roomNo: roomNo },
        dataType: "json",
        success: function(res) {
            if (res) {
                if (res.bootName) { 
                    document.getElementById('modalRoomName').innerText = res.bootName;
                    
                    const phoneSpan = document.getElementById('modalRoomPhone');
                    phoneSpan.innerText = res.bootPhone;
                    phoneSpan.onclick = function() {
                        openMemoModal(res.bootName, res.bootPhone);
                    };
                    
                    document.getElementById('modalRoomAdult').innerText = (res.bootAdult !== undefined ? res.bootAdult : 0) + "名";
                    document.getElementById('modalRoomChild').innerText = (res.bootChild !== undefined ? res.bootChild : 0) + "名";
                    
                    if (res.bootCheckin && res.bootCheckout) {
                        var checkinDate = res.bootCheckin.split(' ')[0];
                        var checkoutDate = res.bootCheckout.split(' ')[0];
                        document.getElementById('modalRoomCheckInOut').innerText = checkinDate + " ~ " + checkoutDate;
                    }
                }
            }
        },
        error: function(xhr, status, error) {
            console.error("予約情報の取得中にエラーが発生しました: ", error);
        }
    });
    
    const myModal = new bootstrap.Modal(document.getElementById('roomDetailModal'));
    myModal.show();
}

function clearReservationFields() {
    document.getElementById('modalRoomName').innerText = "-";
    
    const phoneSpan = document.getElementById('modalRoomPhone');
    phoneSpan.innerText = "-";
    phoneSpan.onclick = null; 
    
    document.getElementById('modalRoomAdult').innerText = "-";
    document.getElementById('modalRoomChild').innerText = "-";
    document.getElementById('modalRoomCheckInOut').innerText = "-";
    document.getElementById('modalNextReservation').innerText = "-"; 
    
    document.getElementById('inputRoomName').value = "";
    document.getElementById('inputRoomPhone').value = "";
    document.getElementById('inputRoomAdult').value = "0";
    document.getElementById('inputRoomChild').value = "0";
    document.getElementById('inputCheckin').value = "";
    document.getElementById('inputCheckout').value = "";
}

function toggleStatusEdit() {
    document.getElementById('modalRoomStatus').classList.add('d-none');
    document.getElementById('modalStatusSelect').classList.remove('d-none');
    document.getElementById('modalStatusSelect').focus();
}

function changeStatusBadge(newStatus) {
    updateBadgeDesign(newStatus); 
    toggleConditionalRows(newStatus);
    
    const todayStr = '<%= todayStr %>'; 
    const hasReservationToday = currentFirstCheckin && currentFirstCheckin.includes(todayStr);
    
    if (newStatus === '宿泊中' && !hasReservationToday) {
        toggleWalkInInputs(true); 
    } else {
        toggleWalkInInputs(false); 
    }
    
    document.getElementById('modalStatusSelect').classList.add('d-none');
    document.getElementById('modalRoomStatus').classList.remove('d-none');
}

function toggleWalkInInputs(isWalkIn) {
    const spanIds = ['modalRoomName', 'modalRoomPhone', 'modalRoomAdult', 'modalRoomChild', 'modalRoomCheckInOut'];
    const inputIds = ['inputRoomName', 'inputRoomPhone', 'inputRoomAdult', 'inputRoomChild', 'inputCheckInOutGroup'];
    
    spanIds.forEach(id => {
        const el = document.getElementById(id);
        if(el) {
            if(isWalkIn) el.classList.add('d-none');
            else el.classList.remove('d-none');
        }
    });
    
    inputIds.forEach(id => {
        const el = document.getElementById(id);
        if(el) {
            if(isWalkIn) el.classList.remove('d-none');
            else el.classList.add('d-none');
        }
    });

    if (isWalkIn) {
        const today = '<%= todayStr %>';
        document.getElementById('inputCheckin').value = today;
        
        let tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        let yyyy = tomorrow.getFullYear();
        let mm = String(tomorrow.getMonth() + 1).padStart(2, '0');
        let dd = String(tomorrow.getDate()).padStart(2, '0');
        document.getElementById('inputCheckout').value = `${yyyy}-${mm}-${dd}`;
    }
}

function toggleConditionalRows(status) {
    const rowName = document.getElementById('rowName');     
    const rowPhone = document.getElementById('rowPhone');
    const rowAdult = document.getElementById('rowAdult');
    const rowChild = document.getElementById('rowChild');
    const rowCheckInOut = document.getElementById('rowCheckInOut');
    const rowNextReservation = document.getElementById('rowNextReservation'); 
    
    rowName.classList.add('d-none');     
    rowPhone.classList.add('d-none');     
    rowAdult.classList.add('d-none');    
    rowChild.classList.add('d-none');    
    rowCheckInOut.classList.add('d-none');
    rowNextReservation.classList.add('d-none'); 
    
    if (status === '宿泊中' || status === '本日予約あり' || status === 'チェックイン予定') {
        rowName.classList.remove('d-none');   
        rowPhone.classList.remove('d-none');  
        rowAdult.classList.remove('d-none'); 
        rowChild.classList.remove('d-none'); 
        rowCheckInOut.classList.remove('d-none');
    }
    
    if (status === '空室') {
        rowNextReservation.classList.remove('d-none');
    }
}

function updateBadgeDesign(statusText) {
    const statusSpan = document.getElementById('modalRoomStatus');
    statusSpan.innerText = statusText;
    statusSpan.className = "fw-bold fs-5 "; 
    
    if (statusText === '空室') {
        statusSpan.classList.add('text-success');
    } else if (statusText === '宿泊中') {
        statusSpan.classList.add('text-primary');
    } else if (statusText === '本日予約あり' || statusText === 'チェックイン予定') {
        statusSpan.style.color = "#8e24aa"; 
    } else if (statusText === '清掃中') {
        statusSpan.classList.add('text-warning');
    } else {
        statusSpan.classList.add('text-danger');
    }
}
    
function submitStatusLetter() {
    const roomNoRaw = document.getElementById('modalRoomNo').innerText;
    const roomNo = parseInt(roomNoRaw); 
    const roomNow = document.getElementById('modalStatusSelect').value;

    if (!roomNo || !roomNow) {
        alert("客室情報またはステータスの値が正しくありません。");
        return;
    }

    const isWalkInMode = !document.getElementById('inputRoomName').classList.contains('d-none');
    
    let ajaxData = { 
        roomNo: roomNo, 
        roomNow: roomNow, 
        roomGrade: currentRoomGrade,
        roomType : currentRoomType
    };
	console.log(isWalkInMode);
    if (isWalkInMode) {
        const bootName = document.getElementById('inputRoomName').value.trim();
        const bootPhone = document.getElementById('inputRoomPhone').value.trim();
        const bootAdult = document.getElementById('inputRoomAdult').value;
        const bootChild = document.getElementById('inputRoomChild').value;
        const bootCheckin = document.getElementById('inputCheckin').value;
        const bootCheckout = document.getElementById('inputCheckout').value;

        if (!bootName) {
            alert("ウォークインのお客様の氏名を入力してください。");
            document.getElementById('inputRoomName').focus();
            return;
        }

        ajaxData.bootName = bootName;
        ajaxData.bootPhone = bootPhone;
        ajaxData.bootAdult = bootAdult;
        ajaxData.bootChild = bootChild;
        ajaxData.bootCheckin = bootCheckin;
        ajaxData.bootCheckout = bootCheckout;
        ajaxData.isWalkIn = "Y"; 
    }

    $.ajax({
        url: "${pageContext.request.contextPath}/Admin/updateRoomStatus",
        type: "Post", 
        data: ajaxData, 
        success: function(response) {
            if (response.trim() === "SUCCESS") {
                alert(roomNo + "号室の ステータスが [" + roomNow + "] に変更されました。");
                location.reload(); 
            } else {
                alert("状態の変更に失敗しました。もう一度お試しください。");
            }
        },
        error: function(xhr, status, error) {
            console.error("ステータス変更中に通信エラーが発生しました:", error);
            alert("サーバー通信中にエラーが発生しました。");
        }
    });
}
</script>
</body>
</html>