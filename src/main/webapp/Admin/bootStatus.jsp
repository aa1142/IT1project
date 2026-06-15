<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/adminTem/headTem.jsp" %>

<style>
    body {
        background-color: #f1f5f9;
        /* 🎯 일본어 가독성을 위한 표준 비즈니스 고딕 폰트셋 적용 */
        font-family: "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
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
                            <th class="text-danger">日</th><th>月</th><th>火</th><th>水</th><th>木</th><th>金</th><th class="text-primary">土</th>
                        </tr>
                    </thead>
                    <tbody id="calendar-body">
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="col-md-8">
            <div class="card card-custom p-4 h-100 shadow-sm">
                <h6 class="fw-bold mb-3">客室ランク別予約概要 <span class="text-muted fs-7 fw-normal" id="summary-date-text">(<%= todayStr %>)</span></h6>
                <div class="table-responsive">
                    <table class="table table-custom align-middle text-center m-0">
                        <thead>
                            <tr class="table-light">
                                <th class="table-diagonal" style="width: 25%; height: 50px;">
                                    <span class="left-bottom text-secondary">ランク</span>
                                    <span class="right-top text-secondary">タイプ</span>
                                </th>
                                <th style="width: 25%;">シングル</th>
                                <th style="width: 25%;">ツイン</th>
                                <th style="width: 25%;">ファミリー</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="fw-semibold text-secondary text-start ps-3">スタンダード</td>
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
                                <td class="fw-semibold text-secondary text-start ps-3">デラックス</td>
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
                                <td class="fw-semibold text-secondary text-start ps-3">スイート</td>
                                <td class="text-muted bg-light-subtle">-</td>
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


    <h6 class="fw-bold mb-3 text-secondary">客室タイプ別料金修正</h6>
    <div class="row g-3">
    <%
        List<RoomDto> priceList = (List<RoomDto>) request.getAttribute("priceList");
        
        java.util.Map<String, java.util.Map<Integer, Integer>> gradeMap = new java.util.LinkedHashMap<String, java.util.Map<Integer, Integer>>();
        gradeMap.put("STANDARD", new java.util.HashMap<Integer, Integer>());
        gradeMap.put("DELUXE", new java.util.HashMap<Integer, Integer>());
        gradeMap.put("SUITE", new java.util.HashMap<Integer, Integer>());

        if (priceList != null && !priceList.isEmpty()) {
            for (RoomDto room : priceList) {
                String grade = room.getRoomGrade();
                
                if (gradeMap.containsKey(grade)) {
                    gradeMap.get(grade).put(room.getRoomType(), room.getRoomPrice());
                }
            }

            for (String grade : gradeMap.keySet()) {
                String bgClass = "bg-secondary";
                if ("STANDARD".equals(grade)) {
                    bgClass = "bg-primary";
                } else if ("DELUXE".equals(grade)) {
                    bgClass = "bg-success";
                } else if ("SUITE".equals(grade)) {
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
    <div class="card card-custom p-4 h-100 d-flex flex-column">
        <div class="d-flex align-items-center mb-3">
            <span class="p-2 <%= bgClass %> rounded-circle me-2"></span>
            <h6 class="fw-bold mb-0"><%= grade %></h6>
        </div>
        
        <% if (!"SUITE".equals(grade)) { %>
        <div class="mb-2">
            <label class="form-label text-muted small mb-1">1泊料金（シングル）</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-single" value="<%= formattedSingle %>">
                <span class="input-group-text bg-light text-muted small fw-bold">円</span>
            </div>
        </div>
        <% } %>
        
         <div class="mb-2">
             <label class="form-label text-muted small mb-1">1泊料金（ツイン）</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-twin" value="<%= formattedTwin %>">
                <span class="input-group-text bg-light text-muted small fw-bold">円</span>
            </div>
        </div>
         <div class="mb-2">
                <label class="form-label text-muted small mb-1">1泊料金（ファミリー）</label>
            <div class="input-group">
                <input type="text" class="form-control text-end fw-semibold price-input price-family" value="<%= formattedFamily %>">
                <span class="input-group-text bg-light text-muted small fw-bold">円</span>
            </div>
        </div>
        
        <button class="btn btn-success w-100 btn-save mt-auto">SAVE</button>
    </div>
</div>
    <% 
            } 
        } else { 
    %>
        <div class="col-12 text-center text-muted py-4">
            登録された客室料金情報がありません。
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
        
        let singleStr = card.find('.price-single').val() || "0";
        let twinStr = card.find('.price-twin').val() || "0";
        let familyStr = card.find('.price-family').val() || "0";
        
        let rawSingle = singleStr.replace(/,/g, ''); 
        let rawTwin = twinStr.replace(/,/g, ''); 
        let rawFamily = familyStr.replace(/,/g, ''); 
        
        // 🚀 테스트용 얼럿 문구 일본어화
        alert("[" + gradeName + " 料金修正内訳]\n" +
              "シングル: " + singleStr + "円 (サーバー用: " + rawSingle + ")\n" +
              "ツイン: " + twinStr + "円 (サーバー用: " + rawTwin + ")\n" +
              "ファミリー: " + familyStr + "円 (サーバー用: " + rawFamily + ")\n" +
              "正常に取得されました！");
    });

    // ================= 3. 동적 달력 스크립트 구성 =================
    let today = new Date();
    let currentYear = today.getFullYear();
    let currentMonth = today.getMonth(); 

    const realTodayYear = today.getFullYear();
    const realTodayMonth = today.getMonth();
    const realTodayDate = today.getDate();

    function renderCalendar(year, month) {
        // 🎯 연, 월 타이틀 일본어 포맷 변경
        $('#calendar-title').text(year + '年 ' + (month + 1) + '月');

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
            parseAndRender('stdSingle', data.standard1);
            parseAndRender('stdTwin', data.standard2);
            parseAndRender('stdFamily', data.standard5);
            
            parseAndRender('dlxSingle', data.deluxe1);
            parseAndRender('dlxTwin', data.deluxe2);
            parseAndRender('dlxFamily', data.deluxe5);
            
            parseAndRender('steSingle', data.suite1); 
            parseAndRender('steTwin', data.suite2);
            parseAndRender('steFamily', data.suite5);
        },
        error: function(xhr, status, error) {
            console.error("データの読み込みに失敗しました: ", error);
        }
    });
}

function parseAndRender(prefix, rawStr) {
    if (!rawStr || rawStr.indexOf('/') === -1) {
        $('#' + prefix + 'Reserved').text('0');
        $('#' + prefix + 'Total').text('0');
        // 🎯 잔여 실 표기법 변경
        $('#' + prefix + 'Left').text('(残り0室)');
        return;
    }

    let parts = rawStr.split('/');
    let reserved = parseInt(parts[0], 10) || 0;
    let total = parseInt(parts[1], 10) || 0;
    let left = total - reserved;
    if (left < 0) left = 0; 

    $('#' + prefix + 'Reserved').text(reserved);
    $('#' + prefix + 'Total').text(total);
    // 🎯 남은 객실 동적 텍스트 일본어화
    $('#' + prefix + 'Left').text('(残り' + left + '室)');
}

//================= 4. 가격 수정 저장 DB 전송 (비동기 AJAX 통신부 문구 변경) =================
$(document).on('click', '.btn-save', function() {
    let card = $(this).closest('.card');
    let gradeName = card.find('h6').text(); 
    
    let singleStr = card.find('.price-single').val() || "0";
    let twinStr = card.find('.price-twin').val() || "0";
    let familyStr = card.find('.price-family').val() || "0";
    
    let rawSingle = singleStr.replace(/,/g, ''); 
    let rawTwin = twinStr.replace(/,/g, ''); 
    let rawFamily = familyStr.replace(/,/g, ''); 
    
    $.ajax({
        url: '${pageContext.request.contextPath}/admin/updateRoomPrice.do', 
        type: 'POST', 
        data: {
            roomGrade: gradeName,     
            priceSingle: rawSingle,   
            priceTwin: rawTwin,       
            priceFamily: rawFamily    
        },
        dataType: 'text', 
        success: function(response) {
            if (response.trim() === "success") {
                alert(gradeName + "の料金が正常に修正されました！ 👍");
            } else {
                alert("料金の修正に失敗しました。もう一度お試しください。");
            }
        },
        error: function(xhr, status, error) {
            console.error("料金修正の通信失敗: ", error);
            alert("サーバーとの通信중에 エラーが発生しました。");
        }
    });
});
</script>

<%@ include file="/adminTem/footTem.jsp" %>