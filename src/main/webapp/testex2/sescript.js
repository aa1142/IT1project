/* hotelsearch.jsp — 지점 선택, 달력, 검색 폼 (서버 연동) */

var selectedCheckin = null;
var currentCalendarDate = new Date();
var selectedRoomClass = '스탠다드';

function formatDate(date) {
    var y = date.getFullYear();
    var m = String(date.getMonth() + 1).padStart(2, '0');
    var d = String(date.getDate()).padStart(2, '0');
    return y + '-' + m + '-' + d;
}

function parseLocalDate(str) {
    var p = str.split('-');
    return new Date(parseInt(p[0], 10), parseInt(p[1], 10) - 1, parseInt(p[2], 10));
}

function getToday() {
    var t = new Date();
    t.setHours(0, 0, 0, 0);
    return t;
}

function selectCompanyRadio(radio) {
    if (!radio) return;
    radio.checked = true;
    document.querySelectorAll('.hotel-list .hotel-option').forEach(function(el) {
        el.classList.remove('selected');
    });
    var option = radio.closest('.hotel-option');
    if (option) {
        option.classList.add('selected');
        var nameEl = option.querySelector('.hotel-option-name');
        if (nameEl) {
            document.getElementById('infoHotelName').textContent = nameEl.textContent.trim();
        }
    }
    updateInfoBox();
}

function initHotelOptions() {
    document.querySelectorAll('.hotel-list .hotel-option').forEach(function(option) {
        option.addEventListener('click', function(e) {
            var radio = option.querySelector('input[name="company_no"]');
            if (radio) {
                selectCompanyRadio(radio);
            }
        });
    });

    var checked = document.querySelector('input[name="company_no"]:checked');
    if (checked) {
        selectCompanyRadio(checked);
    }
}

function selectRoomClass(roomClass) {
    selectedRoomClass = roomClass;
    document.querySelectorAll('.room-class-btn').forEach(function(btn) {
        btn.classList.toggle('selected', btn.getAttribute('data-class') === roomClass);
    });
    var gradeInput = document.getElementById('room_grade');
    if (gradeInput) {
        gradeInput.value = roomClass;
    }
    var infoGrade = document.getElementById('infoRoomClass');
    if (infoGrade) {
        infoGrade.textContent = roomClass;
    }
}

function updateInfoBox() {
    var nightsEl = document.getElementById('nights');
    var roomsEl = document.getElementById('rooms');
    var adultsEl = document.getElementById('adults');
    var childrenEl = document.getElementById('children');
    if (!nightsEl) return;

    document.getElementById('infoNights').textContent = nightsEl.value;
    document.getElementById('infoRooms').textContent = roomsEl.value;
    document.getElementById('infoAdults').textContent = adultsEl.value;
    document.getElementById('infoChildren').textContent = childrenEl.value;
    document.getElementById('infoRoomClass').textContent = selectedRoomClass;

    if (selectedCheckin) {
        var co = new Date(selectedCheckin);
        co.setDate(co.getDate() + parseInt(nightsEl.value, 10));
        document.getElementById('infoCheckout').textContent = formatDate(co);
        document.getElementById('infoCheckin').textContent = formatDate(selectedCheckin);
    }
}

function changeCount(id, delta, min, max) {
    var input = document.getElementById(id);
    if (!input) return;
    var val = parseInt(input.value, 10) + delta;
    if (val >= min && val <= max) {
        input.value = val;
        updateInfoBox();
    }
}

function initCalendar() {
    var input = document.getElementById('checkinDate');
    var cal = document.getElementById('checkinCalendar');
    if (!input || !cal) return;

    renderCalendar();

    input.addEventListener('click', function(e) {
        e.stopPropagation();
        cal.classList.toggle('active');
    });
    cal.addEventListener('click', function(e) {
        e.stopPropagation();
    });
    document.addEventListener('click', function() {
        cal.classList.remove('active');
    });
}

function renderCalendar() {
    var cal = document.getElementById('checkinCalendar');
    if (!cal) return;

    var year = currentCalendarDate.getFullYear();
    var month = currentCalendarDate.getMonth();
    var today = getToday();
    var firstDay = new Date(year, month, 1);
    var startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    var html = '<div class="calendar-header">'
        + '<button type="button" onclick="previousMonth()">← 이전</button>'
        + '<h3>' + year + '년 ' + (month + 1) + '월</h3>'
        + '<button type="button" onclick="nextMonth()">다음 →</button>'
        + '</div>'
        + '<div class="weekdays"><div>일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div></div>'
        + '<div class="days">';

    for (var i = 0; i < 42; i++) {
        var date = new Date(startDate);
        date.setDate(startDate.getDate() + i);
        var isPast = date < today;
        var isOtherMonth = date.getMonth() !== month;
        var isSelected = selectedCheckin && date.toDateString() === selectedCheckin.toDateString();
        var cls = 'day' + (isPast || isOtherMonth ? ' disabled' : '') + (isSelected ? ' selected' : '');

        if (isPast || isOtherMonth) {
            html += '<div class="' + cls + '">' + date.getDate() + '</div>';
        } else {
            html += '<div class="' + cls + '" data-date="' + formatDate(date) + '">' + date.getDate() + '</div>';
        }
    }
    html += '</div>';
    cal.innerHTML = html;

    var daysEl = cal.querySelector('.days');
    if (daysEl) {
        daysEl.onclick = function(e) {
            var day = e.target.closest('.day');
            if (!day || day.classList.contains('disabled')) return;
            var ds = day.getAttribute('data-date');
            if (ds) selectDate(ds);
        };
    }
}

function selectDate(dateStr) {
    selectedCheckin = parseLocalDate(dateStr);
    document.getElementById('checkinDate').value = dateStr;
    document.getElementById('infoCheckin').textContent = dateStr;
    updateInfoBox();
    document.getElementById('checkinCalendar').classList.remove('active');
    renderCalendar();
}

function previousMonth() {
    currentCalendarDate.setMonth(currentCalendarDate.getMonth() - 1);
    renderCalendar();
}

function nextMonth() {
    currentCalendarDate.setMonth(currentCalendarDate.getMonth() + 1);
    renderCalendar();
}

function validateSearchForm() {
    var companyRadio = document.querySelector('input[name="company_no"]:checked');
    if (!companyRadio) {
        alert('호텔 지점을 선택해주세요.');
        return false;
    }
    var checkin = document.getElementById('checkinDate').value;
    if (!checkin) {
        alert('체크인 날짜를 선택해주세요.');
        return false;
    }
    return true;
}

function toggleExpand(id) {
    var el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('expanded');
    var btn = el.nextElementSibling;
    if (btn) {
        btn.textContent = el.classList.contains('expanded') ? '접기 ▲' : '더보기 ▼';
    }
}

function openLightbox(src, alt) {
    var overlay = document.getElementById('lightboxOverlay');
    var img = document.getElementById('lightboxImg');
    if (!overlay || !img) return;
    img.src = src;
    img.alt = alt || '';
    overlay.classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeLightbox() {
    var overlay = document.getElementById('lightboxOverlay');
    if (!overlay) return;
    overlay.classList.remove('active');
    document.body.style.overflow = '';
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeLightbox();
});

document.addEventListener('DOMContentLoaded', function() {
    if (typeof initRoomGrade !== 'undefined' && initRoomGrade) {
        selectRoomClass(initRoomGrade);
    } else {
        selectRoomClass('스탠다드');
    }

    initHotelOptions();
    initCalendar();

    if (typeof initCheckin !== 'undefined' && initCheckin) {
        selectDate(initCheckin);
    } else {
        selectDate(formatDate(getToday()));
    }

    updateInfoBox();

    var searchForm = document.getElementById('searchForm');
    if (searchForm) {
        searchForm.addEventListener('submit', function(e) {
            if (!validateSearchForm()) {
                e.preventDefault();
            }
        });
    }
});
