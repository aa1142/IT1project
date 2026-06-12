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
        
        /* 🎨 상태별 배경색 커스텀 */
        .status-available { background-color: #e8f7ee !important; color: #198754 !important; border: 1px solid #c3e6cb; }
        .status-occupied  { background-color: #e8f0fe !important; color: #0d6efd !important; border: 1px solid #b8daff; }
        .status-cleaning  { background-color: #fff3cd !important; color: #ffc107 !important; border: 1px solid #ffeeba; }
        .status-inspecting{ background-color: #f8d7da !important; color: #dc3545 !important; border: 1px solid #f5c6cb; }
        
        /* 🌟 금일 예약있음 카드 스타일 (보라색 계열) */
		.status-upcoming { 
		    background-color: #f3e5f5 !important; 
		    color: #8e24aa !important; 
		    border: 1px solid #d1c4e9; 
		}
        
        /* 객실 카드 스타일 */
        .room-card {
            width: 140px; height: 80px; display: flex; flex-direction: column;
            justify-content: center; align-items: center; border-radius: 10px;
            font-weight: bold; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            cursor: pointer; transition: transform 0.2s;
        }
        .room-card:hover { transform: scale(1.05); }
        .legend-box { display: inline-block; width: 12px; height: 12px; margin-right: 5px; vertical-align: middle; }
    </style>
</head>
<body>

    <jsp:include page="/adminTem/headTem.jsp" />

    <%
        // 🌟 오늘 날짜 구하기 (예: "2026-06-09")
        String todayStr = java.time.LocalDate.now().toString();

        Map<String, Integer> roomCounts = (Map<String, Integer>) request.getAttribute("roomCounts");
        if (roomCounts == null) roomCounts = new HashMap<>();

        List<RoomDto> roomList = (List<RoomDto>) request.getAttribute("roomList");
        if (roomList == null) roomList = new ArrayList<>();

        int stdCount = roomCounts.get("스탠다드") != null ? roomCounts.get("스탠다드") : 0;
        int dlxCount = roomCounts.get("디럭스") != null ? roomCounts.get("디럭스") : 0;
        int steCount = roomCounts.get("스위트") != null ? roomCounts.get("스위트") : (roomCounts.get("스윗트") != null ? roomCounts.get("스윗트") : 0);
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
                    <span class="text-muted small fw-bold">전체 객실</span>
                    <div class="d-flex justify-content-between align-items-end border-bottom pb-2 mb-3">
                        <h4 class="fw-bold m-0"><%= totalRooms %>실</h4>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3">
                        <span class="fw-semibold text-secondary">스탠다드</span>
                        <span class="fw-bold text-dark"><%= stdCount %></span>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3 border-top pt-2">
                        <span class="fw-semibold text-secondary">디럭스</span>
                        <span class="fw-bold text-dark"><%= dlxCount %></span>
                    </div>
                    
                    <div class="d-flex justify-content-between mb-3 border-top pt-2">
                        <span class="fw-semibold text-secondary">스위트</span>
                        <span class="fw-bold text-dark"><%= steCount %></span>
                    </div>
                </div>
            </div>

            <div class="col-md-10">
                
                <div class="row g-3 mb-3">
                    <div class="col"><div class="card p-3 text-center status-available shadow-sm"><div class="small">사용 가능</div><h3 class="fw-bold m-0 mt-1"><%= countAvailable %>실</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-occupied shadow-sm"><div class="small">투숙 중</div><h3 class="fw-bold m-0 mt-1"><%= countOccupied %>실</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-cleaning shadow-sm"><div class="small">청소 중</div><h3 class="fw-bold m-0 mt-1"><%= countCleaning %>실</h3></div></div>
                    <div class="col"><div class="card p-3 text-center status-inspecting shadow-sm"><div class="small">점검 중</div><h3 class="fw-bold m-0 mt-1"><%= countInspecting %>실</h3></div></div>
                </div>

                <div class="mb-4 small fw-semibold text-secondary">
                    <span class="me-3"><span class="legend-box status-available"></span>사용 가능</span>
                    <span class="me-3"><span class="legend-box status-upcoming"></span>금일 예약있음</span>
                    <span class="me-3"><span class="legend-box status-occupied"></span>투숙 중</span>
                    <span class="me-3"><span class="legend-box status-cleaning"></span>청소 중</span>
                    <span><span class="legend-box status-inspecting"></span>점검 중</span>
                </div>

                <h5 class="fw-bold mb-3">객실 현황판</h5>

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
                                <div class="fw-bold text-dark mb-2"><%= currentFloor %>층</div>
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
                        	roomTypeName = "싱글";
                        	break;
                        case 2:
                        	roomTypeName = "트윈";
                        	break;
                        case 5:
                        	roomTypeName = "패밀리";
                        	break;	
                        }
                        
                        System.out.println("jsp RoomNo = "+room.getRoomNo());
                        String[] firstCheckInOut = bootDao.SelectOneFirstBootDate(room.getRoomNo(), room.getCompanyNo());
                        String firstCheckIn = "";
                        String firstCheckOut = "";
                        String reservationDisplay = "예약없음"; // 🌟 화면에 보여줄 기본 텍스트
                        if (firstCheckInOut != null && firstCheckInOut[0] != null && !firstCheckInOut[0].trim().equals("")) {
                            firstCheckIn = firstCheckInOut[0];
                            firstCheckOut = firstCheckInOut[1];
                            reservationDisplay = firstCheckIn + " ~ " + firstCheckOut; // 날짜가 있으면 "2026-06-10 ~ 2026-06-11" 형태로 변경
                            
                            // 오늘 날짜에 예약이 있는지 비교
                            if (firstCheckIn.contains(todayStr)) {
                                if (roomNow.equals("사용 가능") || roomNow.equals("예약 중") || roomNow.equals("체크인 예정")) {
                                    roomNow = "금일 예약있음";
                                }
                            }
                        }
                        
                        String cardClass = "";
                        String statusText = "";
                                
                        switch (roomNow) {
                            case "사용 가능":
                                cardClass = "status-available";
                                statusText = "사용 가능";
                                break;
                                
                            case "금일 예약있음": 
                            case "체크인 예정": 
                                cardClass = "status-upcoming";
                                statusText = "금일 예약있음";
                                break;
                                
                            case "예약 중":
                            case "투숙 중": 
                                cardClass = "status-occupied";
                                statusText = "투숙 중";
                                break;
                                
                            case "청소 중":
                                cardClass = "status-cleaning";
                                statusText = "청소 중";
                                break;
                                
                            default:       
                                cardClass = "status-inspecting";
                                statusText = "점검 중";
                                break;
                        }
                        
                %>
                <div class="room-card <%= cardClass %>" onclick="openRoomModal('<%= roomNo %>', '<%= roomGrade %>', '<%= statusText %>', '<%= firstCheckIn %>', '<%= roomType %>')">
				    <div class="small text-muted fw-normal" style="font-size: 11px;"><%= roomNo %>호</div>
				    
				    <div class="my-1"><%= roomGrade %>(<%= roomTypeName %>)</div>
				    
				    <div style="font-size: 11px; font-weight: normal; opacity: 0.8;">
				        <% if (statusText.equals("금일 예약있음")) { %>
				            <span class="fw-bold" style="color: #8e24aa;">⏰ 입실 예정</span>
				        <% } else if (!roomNow.equals("투숙 중")&&firstCheckInOut != null && firstCheckInOut[0] != null && !firstCheckInOut[0].trim().equals("")) { 
				            // 오늘 이후 미래에 예약이 있는 경우 월-일(MM/DD)만 컴팩트하게 표시
				            String shortDate = (firstCheckIn.length() >= 10) ? firstCheckIn.substring(5, 10).replace("-", "/") : "";
				        %>
				            <span class="text-secondary">📅 <%= shortDate %> 예정</span>
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
                    <h5 class="modal-title fw-bold" id="roomDetailModalLabel">🚪 객실 상세 정보</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <table class="table table-bordered align-middle text-center m-0">
                        <tbody>
                            <tr>
                                <th class="table-light text-secondary" style="width: 35%;">객실 번호</th>
                                <td id="modalRoomNo" class="fw-bold fs-5 text-dark"></td>
                            </tr>
                            <tr>
                                <th class="table-light text-secondary">객실 등급</th>
                                <td id="modalRoomGrade" class="fw-semibold text-primary"></td>
                            </tr>
                            <tr>
                                <th class="table-light text-secondary">현재상태</th>
                                <td>
                                    <span id="modalRoomStatus" class="fw-bold fs-5" style="cursor: pointer;" onclick="toggleStatusEdit()"></span>
                                    
                                    <select id="modalStatusSelect" class="form-select form-select-sm d-none mx-auto" style="width: 70%;" onchange="changeStatusBadge(this.value)">
                                        <option value="사용 가능">사용 가능</option>
                                        <option value="금일 예약있음">금일 예약있음</option> 
                                        <option value="투숙 중">투숙 중</option>
                                        <option value="청소 중">청소 중</option>
                                        <option value="점검 중">점검 중</option>
                                    </select>
                                </td>
                            </tr>
                            
                            <tr id="rowName" class="status-dependent-row">
                                <th class="table-light text-secondary">이름</th>
                                <td>
                                    <span id="modalRoomName" class="text-dark fw-medium">-</span>
                                    <input type="text" id="inputRoomName" class="form-control form-control-sm d-none mx-auto" style="width: 80%;" placeholder="현장 투숙객 이름">
                                </td> 
                            </tr>
                            <tr id="rowPhone" class="status-dependent-row">
                                <th class="table-light text-secondary">전화번호</th>
                                <td>
                                    <span id="modalRoomPhone" class="memo-trigger" style="cursor: pointer; text-decoration: underline; color: #007bff;">-</span>
                                    <input type="text" id="inputRoomPhone" class="form-control form-control-sm d-none mx-auto" style="width: 80%;" placeholder="010-0000-0000" maxlength="13">
                                </td>
                            </tr>
                            <tr id="rowAdult" class="status-dependent-row">
                                <th class="table-light text-secondary">성인</th>
                                <td>
                                    <span id="modalRoomAdult" class="text-dark fw-medium">-</span>
                                    <input type="number" id="inputRoomAdult" class="form-control form-control-sm d-none mx-auto" style="width: 50%;" min="0" value="0">
                                </td>
                            </tr>
                            <tr id="rowChild" class="status-dependent-row">
                                <th class="table-light text-secondary">어린이</th>
                                <td>
                                    <span id="modalRoomChild" class="text-dark fw-medium">-</span>
                                    <input type="number" id="inputRoomChild" class="form-control form-control-sm d-none mx-auto" style="width: 50%;" min="0" value="0">
                                </td>
                            </tr>
                            <tr id="rowCheckInOut" class="status-dependent-row">
                                <th class="table-light text-secondary">예약기간</th>
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
							    <th class="table-light text-secondary">다음 예약일</th>
							    <td id="modalNextReservation" class="text-danger fw-bold">-</td> 
							</tr>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer" style="border-top: none;">
                    <button type="button" class="btn btn-secondary fw-semibold" data-bs-dismiss="modal">닫기</button>
                    <button type="button" class="btn btn-primary fw-semibold" onclick="submitStatusLetter()">상태 변경</button>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/adminTem/memoModal.jsp" %>
    
 <script>
// 전역 변수로 모달에 필요한 데이터 백업 관리
var currentFirstCheckin = "";
var currentRoomGrade = "";
var currentRoomType = "";

// 전화번호 자동 하이픈 생성 로직
$(document).on('input', '#inputRoomPhone', function() {
    let val = $(this).val().replace(/[^0-9]/g, ''); // 숫자만 남기기
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

// 모달 열기 함수 (roomType 파라미터 추가 수신)
function openRoomModal(roomNo, roomGrade, statusText, firstCheckin, roomType) {
    console.log("방 모달 오픈:", roomNo);
    
    // 전역 변수에 데이터 백업 (나중에 전송할 때 사용)
    currentFirstCheckin = firstCheckin; 
    currentRoomGrade = roomGrade;
    currentRoomType = roomType;
    
    document.getElementById('modalRoomNo').innerText = roomNo + "호";
    document.getElementById('modalRoomGrade').innerText = roomGrade;
    
    document.getElementById('modalRoomStatus').classList.remove('d-none');
    document.getElementById('modalStatusSelect').classList.add('d-none');
    
    const todayStr = '<%= todayStr %>'; 
    const hasReservationToday = firstCheckin && firstCheckin.includes(todayStr);
    const $upcomingOption = $('#modalStatusSelect option[value="금일 예약있음"]');

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
        document.getElementById('modalNextReservation').innerText = "예약 내역 없음";
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
                    
                    document.getElementById('modalRoomAdult').innerText = (res.bootAdult !== undefined ? res.bootAdult : 0) + "명";
                    document.getElementById('modalRoomChild').innerText = (res.bootChild !== undefined ? res.bootChild : 0) + "명";
                    
                    if (res.bootCheckin && res.bootCheckout) {
                        var checkinDate = res.bootCheckin.split(' ')[0];
                        var checkoutDate = res.bootCheckout.split(' ')[0];
                        document.getElementById('modalRoomCheckInOut').innerText = checkinDate + " ~ " + checkoutDate;
                    }
                }
            }
        },
        error: function(xhr, status, error) {
            console.error("예약 정보를 불러오는 중 오류 발생: ", error);
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
    
    if (newStatus === '투숙 중' && !hasReservationToday) {
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
    
    if (status === '투숙 중' || status === '금일 예약있음' || status === '체크인 예정') {
        rowName.classList.remove('d-none');   
        rowPhone.classList.remove('d-none');  
        rowAdult.classList.remove('d-none'); 
        rowChild.classList.remove('d-none'); 
        rowCheckInOut.classList.remove('d-none');
    }
    
    if (status === '사용 가능') {
        rowNextReservation.classList.remove('d-none');
    }
}

function updateBadgeDesign(statusText) {
    const statusSpan = document.getElementById('modalRoomStatus');
    statusSpan.innerText = statusText;
    statusSpan.className = "fw-bold fs-5 "; 
    
    if (statusText === '사용 가능') {
        statusSpan.classList.add('text-success');
    } else if (statusText === '투숙 중') {
        statusSpan.classList.add('text-primary');
    } else if (statusText === '금일 예약있음' || statusText === '체크인 예정') {
        statusSpan.style.color = "#8e24aa"; 
    } else if (statusText === '청소 중') {
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
        alert("방 정보 혹은 상태 값이 올바르지 않습니다.");
        return;
    }

    const isWalkInMode = !document.getElementById('inputRoomName').classList.contains('d-none');
    
    // 🌟 쉼표(,) 추가 완료 및 전역 변수를 활용한 셋팅 매핑 완료!
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
            alert("현장 결제 고객의 이름을 입력해 주세요.");
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
        type: "Post", // 👈 지난번에 말씀드린 대로 보안/표준을 위해 Post로 매핑 변경해 드렸습니다.
        data: ajaxData, 
        success: function(response) {
            if (response.trim() === "SUCCESS") {
                alert(roomNo + "호 객실 상태가 [" + roomNow + "]으로 변경되었습니다.");
                location.reload(); 
            } else {
                alert("상태 변경에 실패했습니다. 다시 시도해 주세요.");
            }
        },
        error: function(xhr, status, error) {
            console.error("상태 변경 중 통신 오류 발생:", error);
            alert("서버 통신 중 오류가 발생했습니다.");
        }
    });
}
</script>
</body>
</html>