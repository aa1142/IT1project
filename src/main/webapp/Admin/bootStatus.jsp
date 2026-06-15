<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/adminTem/headTem.jsp" %>

<style>
    body {
        background-color: #f1f5f9;
        font-family: 'Malgun Gothic', dotum, sans-serif;
    }
    .nav-dark {
        background-color: #1e293b;
        color: #ffffff;
    }
    .card-custom {
        border: none;
        border-radius: 12px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
        background-color: #ffffff;
    }
    .text-summary-title {
        font-size: 0.85rem;
        color: #64748b;
        font-weight: 600;
    }
    .text-summary-value {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1e293b;
    }
    .calendar-table th, .calendar-table td {
        text-align: center;
        padding: 6px 4px;
        font-size: 0.9rem;
        vertical-align: middle;
    }
    .calendar-active {
        display: inline-block;
        width: 28px;
        height: 28px;
        line-height: 28px;
        background-color: #0f172a;
        color: #fff !important;
        border-radius: 50%;
        font-weight: bold;
    }
    .table-custom th {
        color: #64748b;
        font-size: 0.85rem;
        font-weight: 600;
        border-bottom: 2px solid #e2e8f0;
    }
    .table-custom td {
        font-size: 0.9rem;
        vertical-align: middle;
    }
    .table-diagonal {
        background: linear-gradient(to top right, transparent 49.5%, #dee2e6 49.5%, #dee2e6 50.5%, transparent 50.5%);
        position: relative;
    }
    .table-diagonal .left-bottom {
        position: absolute;
        left: 15px;
        bottom: 8px;
    }
    .table-diagonal .right-top {
        position: absolute;
        right: 15px;
        top: 8px;
    }
</style>

<% String todayStr = java.time.LocalDate.now().toString(); %>
<%@ page import="java.util.List" %>
<%@ page import="dto.RoomDto" %>

<div class="container py-4">

    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card card-custom p-3 h-100">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <button class="btn btn-sm btn-light" id="btn-prev-month">&lt;</button>
                    <span class="fw-bold" id="calendar-title"></span>
                    <button class="btn btn-sm btn-light" id="btn-next-month">&gt;</button>
                </div>
                <table class="table table-borderless calendar-table">
                    <thead>
                        <tr class="text-muted">
                            <th class="text-danger">일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th class="text-primary">토</th>
                        </tr>
                    </thead>
                    <tbody id="calendar-body">
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="col-md-8">
            <div class="card card-custom p-4 h-100 shadow-sm">
                <h6 class="fw-bold mb-3">객실 등급별 예약 요약 <span class="text-muted fs-7 fw-normal" id="summary-date-text">(<%= todayStr %>)</span></h6>
                <div class="table-responsive">
                    <table class="table table-custom align-middle text-center m-0">
                        <thead>
                            <tr class="table-light">
                                <th class="table-diagonal" style="width: 25%; height: 50px;">
                                    <span class="left-bottom text-secondary">등급</span>
                                    <span class="right-top text-secondary">타입</span>
                                </th>
                                <th style="width: 25%;">싱글</th>
                                <th style="width: 25%;">트윈</th>
                                <th style="width: 25%;">패밀리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="fw-semibold text-secondary text-start ps-3">스탠다드</td>
                            	<td>
						            <span class="fw-bold text-primary" id="stdSingleReserved">-</span><span class="text-muted">/</span><span id="stdSingleTotal">-</span>
						            <br><small class="text-success fw-bold" id="stdSingleLeft"></small>
						        </td>
						        <td>
						            <span class="fw-bold text-primary" id="stdTwinReserved">-</span><span class="text-muted">/</span><span id="stdTwinTotal">-</span>
						            <br><small class="text-success fw-bold" id="stdTwinLeft"></small>
						        </td>
						        <td>
						            <span class="fw-bold text-primary" id="stdFamilyReserved">-</span><span class="text-muted">/</span><span id="stdFamilyTotal">-</span>
						            <br><small class="text-success fw-bold" id="stdFamilyLeft"></small>
						        </td>
                            </tr>
                            
                            <tr>
                                <td class="fw-semibold text-secondary text-start ps-3">디럭스</td>
                                <td>
						            <span class="fw-bold text-primary" id="dlxSingleReserved">-</span><span class="text-muted">/</span><span id="dlxSingleTotal">-</span>
						            <br><small class="text-success fw-bold" id="dlxSingleLeft"></small>
						        </td>
						        <td>
						            <span class="fw-bold text-primary" id="dlxTwinReserved">-</span><span class="text-muted">/</span><span id="dlxTwinTotal">-</span>
						            <br><small class="text-success fw-bold" id="dlxTwinLeft"></small>
						        </td>
						        <td>
						            <span class="fw-bold text-primary" id="dlxFamilyReserved">-</span><span class="text-muted">/</span><span id="dlxFamilyTotal">-</span>
						            <br><small class="text-success fw-bold" id="dlxFamilyLeft"></small>
						        </td>
                            </tr>
                            
							
							<tr>
							    <td class="fw-semibold text-secondary text-start ps-3">스윗트</td>
							    <td class="text-muted bg-light-subtle">
							        - </td>
							    <td>
							        <span class="fw-bold text-primary" id="steTwinReserved">-</span><span class="text-muted">/</span><span id="steTwinTotal">-</span>
							        <br><small class="text-success fw-bold" id="steTwinLeft"></small>
							    </td>
							    <td>
							        <span class="fw-bold text-primary" id="steFamilyReserved">-</span><span class="text-muted">/</span><span id="steFamilyTotal">-</span>
							        <br><small class="text-success fw-bold" id="steFamilyLeft"></small>
							    </td>
							</tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="card card-custom p-4 mb-4">
        <h6 class="fw-bold mb-3">방 종류별 예약 이용률</h6>
        <div class="row align-items-center mb-2">
            <div class="col-2 text-secondary fw-semibold">스탠다드 <span class="badge bg-light text-dark ms-1">45%</span></div>
            <div class="col-8">
                <div class="progress" style="height: 12px;">
                    <div class="progress-bar bg-primary" style="width: 45%"></div>
                </div>
            </div>
            <div class="col-2 text-end"><button class="btn btn-sm btn-outline-secondary py-1 px-3" style="font-size:0.8rem">예약 이용</button></div>
        </div>
        <div class="row align-items-center mb-2">
            <div class="col-2 text-secondary fw-semibold">디럭스 <span class="badge bg-light text-dark ms-1">45%</span></div>
            <div class="col-8">
                <div class="progress" style="height: 12px;">
                    <div class="progress-bar bg-success" style="width: 45%"></div>
                </div>
            </div>
            <div class="col-2 text-end"><button class="btn btn-sm btn-outline-secondary py-1 px-3" style="font-size:0.8rem">예약 이용</button></div>
        </div>
        <div class="row align-items-center">
            <div class="col-2 text-secondary fw-semibold">스위트 <span class="badge bg-light text-dark ms-1">10%</span></div>
            <div class="col-8">
                <div class="progress" style="height: 12px;">
                    <div class="progress-bar bg-warning" style="width: 10%"></div>
                </div>
            </div>
            <div class="col-2 text-end"><button class="btn btn-sm btn-outline-secondary py-1 px-3" style="font-size:0.8rem">예약 이용</button></div>
        </div>
    </div>

    <h6 class="fw-bold mb-3 text-secondary">방 종류별 가격 수정</h6>
    <div class="row g-3">
    <%
        List<RoomDto> priceList = (List<RoomDto>) request.getAttribute("priceList");
        
        java.util.Map<String, java.util.Map<Integer, Integer>> gradeMap = new java.util.LinkedHashMap<String, java.util.Map<Integer, Integer>>();
        gradeMap.put("스탠다드", new java.util.HashMap<Integer, Integer>());
        gradeMap.put("디럭스", new java.util.HashMap<Integer, Integer>());
        gradeMap.put("스윗트", new java.util.HashMap<Integer, Integer>());

        if (priceList != null && !priceList.isEmpty()) {
            for (RoomDto room : priceList) {
                String grade = room.getRoomGrade();
                
                if (gradeMap.containsKey(grade)) {
                    gradeMap.get(grade).put(room.getRoomType(), room.getRoomPrice());
                }
            }

            for (String grade : gradeMap.keySet()) {
                String bgClass = "bg-secondary";
                if ("스탠다드".equals(grade)) {
                    bgClass = "bg-primary";
                } else if ("디럭스".equals(grade)) {
                    bgClass = "bg-success";
                } else if ("스윗트".equals(grade)) {
                    bgClass = "bg-warning";
                }
                
                Integer singlePrice = gradeMap.get(grade).get(1);
                Integer twinPrice = gradeMap.get(grade).get(2);
                Integer familyPrice = gradeMap.get(grade).get(5);
                
                String formattedSingle = (singlePrice != null) ? String.format("%,d", singlePrice) : "0";
                String formattedTwin = (twinPrice != null) ? String.format("%,d", twinPrice) : "0";
                String formattedFamily = (familyPrice != null) ? String.format("%,d", familyPrice) : "0";
    %>
<div class="col-md-4">
    <%-- ✨ 변경 1: h-100 d-flex flex-column 클래스 추가 (높이 동기화 및 세로 정렬) --%>
    <div class="card card-custom p-4 h-100 d-flex flex-column">
        <div class="d-flex align-items-center mb-3">
            <span class="p-2 <%= bgClass %> rounded-circle me-2"></span>
            <h6 class="fw-bold mb-0"><%= grade %></h6>
        </div>
        
        <% if (!"스윗트".equals(grade)) { %>
        <div class="mb-2">
            <label class="form-label text-muted small mb-1">1박 가격(싱글)</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-single" value="<%= formattedSingle %>">
                <span class="input-group-text bg-light text-muted small fw-bold">원</span>
            </div>
        </div>
        <% } %>
        
         <div class="mb-2">
             <label class="form-label text-muted small mb-1">1박 가격(트윈)</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-twin" value="<%= formattedTwin %>">
                <span class="input-group-text bg-light text-muted small fw-bold">원</span>
            </div>
        </div>
         <div class="mb-2">
               <label class="form-label text-muted small mb-1">1박 가격(패밀리)</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-family" value="<%= formattedFamily %>">
                <span class="input-group-text bg-light text-muted small fw-bold">원</span>
            </div>
        </div>
        
        <%-- ✨ 변경 2: mt-2를 지우고 mt-auto 추가 (남는 공간을 밀어내어 바닥에 고정) --%>
        <button class="btn btn-success w-100 btn-save mt-auto" onclick="">저장</button>
    </div>
</div>
<%-- (기존 코드 생략) --%>
    <% 
            } 
        } else { 
    %>
        <div class="col-12 text-center text-muted py-4">
            등록된 객실 가격 정보가 없습니다.
        </div>
    <% 
        } 
    %>
    </div>

</div>

<script>
$(document).ready(function() {
    
    // ================= 1. 실시간 3자리 쉼표 포맷팅 =================
    $(document).on('input', '.price-input', function() {
        let value = $(this).val().replace(/[^0-9]/g, '');
        let formatted = value.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        $(this).val(formatted);
    });

    // ================= 2. 가격 수정 저장 버튼 이벤트 (3개 가격 통합 추출) =================
    $(".btn-save").click(function() {
        let card = $(this).closest('.card');
        let gradeName = card.find('h6').text(); 
        
        // 각 타입별 인풋창의 값을 따로 추출합니다.
        let singleStr = card.find('.price-single').val() || "0";
        let twinStr = card.find('.price-twin').val() || "0";
        let familyStr = card.find('.price-family').val() || "0";
        
        // DB 전송용 순수 숫자 추출
        let rawSingle = singleStr.replace(/,/g, ''); 
        let rawTwin = twinStr.replace(/,/g, ''); 
        let rawFamily = familyStr.replace(/,/g, ''); 
        
        alert("[" + gradeName + " 가격 수정내역]" +
              "싱글: " + singleStr + "원 (서버용: " + rawSingle + ")" +
              "트윈: " + twinStr + "원 (서버용: " + rawTwin + ")" +
              "패밀리: " + familyStr + "원 (서버용: " + rawFamily + ")" +
              "성공적으로 가져왔습니다!");
        
    });

    // ================= 3. 동적 달력 스크립트 구성 =================
    let today = new Date();
    let currentYear = today.getFullYear();
    let currentMonth = today.getMonth(); 

    const realTodayYear = today.getFullYear();
    const realTodayMonth = today.getMonth();
    const realTodayDate = today.getDate();

    function renderCalendar(year, month) {
        $('#calendar-title').text(year + '년 ' + (month + 1) + '월');

        let firstDay = new Date(year, month, 1).getDay();
        let totalDays = new Date(year, month + 1, 0).getDate();

        let tbody = $('#calendar-body');
        tbody.empty(); 

        let row = $('<tr>');

        for (let i = 0; i < firstDay; i++) {
            row.append('<td></td>');
        }

        for (let day = 1; day <= totalDays; day++) {
            if (row.children().length === 7) {
                tbody.append(row);
                row = $('<tr>');
            }

            let td = $('<td>');
            
            let formattedMonth = String(month + 1).padStart(2, '0');
            let formattedDay = String(day).padStart(2, '0');
            let fullDate = year + '-' + formattedMonth + '-' + formattedDay;

            td.addClass('calendar-day').attr('data-date', fullDate);
            td.css('cursor', 'pointer'); 
            
            let dayOfWeek = (firstDay + day - 1) % 7;
            if (dayOfWeek === 0) td.addClass('text-danger');
            else if (dayOfWeek === 6) td.addClass('text-primary');

            let daySpan = $('<span>').text(day);

            if (year === realTodayYear && month === realTodayMonth && day === realTodayDate) {
                daySpan.addClass('calendar-active');
            }

            td.append(daySpan);
            row.append(td);
        }

        while (row.children().length < 7 && row.children().length > 0) {
            row.append('<td></td>');
        }
        if (row.children().length > 0) {
            tbody.append(row);
        }
    }

    $('#btn-prev-month').click(function() {
        currentMonth--;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
        renderCalendar(currentYear, currentMonth);
    });

    $('#btn-next-month').click(function() {
        currentMonth++;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        renderCalendar(currentYear, currentMonth);
    });

    renderCalendar(currentYear, currentMonth);

    let todayFormatStr = realTodayYear + '-' + String(realTodayMonth + 1).padStart(2, '0') + '-' + String(realTodayDate).padStart(2, '0');
    fetchReservationSummary(todayFormatStr);
});

$(document).on('click', '.calendar-day', function() {
    let selectedDate = $(this).data('date'); 
    
    $('.calendar-day span').removeClass('calendar-active');
    $(this).find('span').addClass('calendar-active');
    
    fetchReservationSummary(selectedDate);
});

function fetchReservationSummary(targetDate) {
    $('#summary-date-text').text('(' + targetDate + ')');
    
    $.ajax({
        url: '${pageContext.request.contextPath}/admin/getBootSummary.do', 
        type: 'GET',
        data: { date: targetDate }, 
        dataType: 'json', 
        success: function(data) {
            // 1. 스탠다드 라인 (3개 전부)
            parseAndRender('stdSingle', data.standard1);
            parseAndRender('stdTwin', data.standard2);
            parseAndRender('stdFamily', data.standard5);
            
            // 2. 디럭스 라인 (3개 전부)
            parseAndRender('dlxSingle', data.deluxe1);
            parseAndRender('dlxTwin', data.deluxe2);
            parseAndRender('dlxFamily', data.deluxe5);
            
            // 3. 스윗트 라인 (3개 전부)
            parseAndRender('steSingle', data.suite1); // 서블릿에서 suite1도 던져주도록 설정 필요!
            parseAndRender('steTwin', data.suite2);
            parseAndRender('steFamily', data.suite5);
        },
        error: function(xhr, status, error) {
            console.error("데이터 로드 실패: ", error);
        }
    });
}

// 💡 스크립트 가장 하단(태그 닫히기 전)에 이 함수 정의를 반드시 넣어주셔야 합니다!
function parseAndRender(prefix, rawStr) {
    // 서버에서 데이터가 안 오거나 null 일 때의 예외 처리
    if (!rawStr || rawStr.indexOf('/') === -1) {
        $('#' + prefix + 'Reserved').text('0');
        $('#' + prefix + 'Total').text('0');
        $('#' + prefix + 'Left').text('(0실 남음)');
        return;
    }

    // "3/10" 형태의 문자열을 분리 (Parse 단계)
    let parts = rawStr.split('/');
    let reserved = parseInt(parts[0], 10) || 0;
    let total = parseInt(parts[1], 10) || 0;
    let left = total - reserved;
    if (left < 0) left = 0; // 혹시 모를 음수 방지

    // HTML 엘리먼트에 꽂아넣기 (Render 단계)
    $('#' + prefix + 'Reserved').text(reserved);
    $('#' + prefix + 'Total').text(total);
    $('#' + prefix + 'Left').text('(' + left + '실 남음)');
}

//================= 2. 가격 수정 저장 버튼 이벤트 (3개 가격 통합 추출) =================
$(".btn-save").click(function() {
    let card = $(this).closest('.card');
    let gradeName = card.find('h6').text(); 
    
    // 각 타입별 인풋창의 값을 따로 추출합니다.
    let singleStr = card.find('.price-single').val() || "0";
    let twinStr = card.find('.price-twin').val() || "0";
    let familyStr = card.find('.price-family').val() || "0";
    
    // DB 전송용 순수 숫자 추출 (쉼표 제거)
    let rawSingle = singleStr.replace(/,/g, ''); 
    let rawTwin = twinStr.replace(/,/g, ''); 
    let rawFamily = familyStr.replace(/,/g, ''); 
    
    // 🚀 [추가] 실제 DB 반영을 위한 AJAX 호출
    $.ajax({
        url: '${pageContext.request.contextPath}/admin/updateRoomPrice.do', // 1. 본인의 Controller 매핑 주소로 맞추세요!
        type: 'POST', // 데이터를 수정하는 작업이므로 POST 방식 권장
        data: {
            roomGrade: gradeName,     // ex) '스탠다드', '디럭스', '스위트'
            priceSingle: rawSingle,   // ex) 150000 (스위트라면 위에서 0으로 처리됨)
            priceTwin: rawTwin,       // ex) 200000
            priceFamily: rawFamily    // ex) 350000
        },
        dataType: 'text', // 서버에서 성공여부 문자열("success")을 받아온다고 가정
        success: function(response) {
            if (response.trim() === "success") {
                alert(gradeName + " 가격이 성공적으로 수정되었습니다! 👍");
                // 만약 수정 후 화면을 새로고침하고 싶다면 아래 주석 해제
                // location.reload();
            } else {
                alert("가격 수정에 실패했습니다. 다시 시도해 주세요.");
            }
        },
        error: function(xhr, status, error) {
            console.error("가격 수정 통신 실패: ", error);
            alert("서버 연결 중 오류가 발생했습니다.");
        }
    });
});
</script>

<%@ include file="/adminTem/footTem.jsp" %>