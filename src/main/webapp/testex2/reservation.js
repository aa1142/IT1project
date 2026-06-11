/* hotelreservation.jsp — 옵션·요금·검증 */

var selectedPlans = [];

function isOptionSelected(id) {
    return selectedPlans.indexOf(id) !== -1;
}

function getPriceData() {
    var form = document.getElementById('reserveForm');
    if (!form) {
        return { roomTotal: 0, breakfastTotal: 0, fastCheckinUnit: 0 };
    }
    return {
        roomTotal: parseInt(form.getAttribute('data-room-total'), 10) || 0,
        breakfastTotal: parseInt(form.getAttribute('data-breakfast-total'), 10) || 0,
        fastCheckinUnit: parseInt(form.getAttribute('data-fastcheckin-unit'), 10) || 0
    };
}

function syncHiddenOptions() {
    var breakfastYn = document.getElementById('breakfast_yn');
    var fastYn = document.getElementById('fast_checkin_yn');
    if (breakfastYn) {
        breakfastYn.value = isOptionSelected('breakfast') ? 'Y' : 'N';
    }
    if (fastYn) {
        fastYn.value = isOptionSelected('fastCheckin') ? 'Y' : 'N';
    }
}

function toggleOption(optionId) {
    var idx = selectedPlans.indexOf(optionId);
    if (idx === -1) {
        selectedPlans.push(optionId);
    } else {
        selectedPlans.splice(idx, 1);
    }

    var card = document.getElementById('option-' + optionId);
    if (card) {
        card.classList.toggle('selected', isOptionSelected(optionId));
    }

    var priceRow = document.getElementById('price-' + optionId);
    if (priceRow) {
        priceRow.style.display = isOptionSelected(optionId) ? 'flex' : 'none';
    }

    syncHiddenOptions();
    updateTotal();

    if (window.lucide) {
        lucide.createIcons();
    }
}

function formatWon(amount) {
    return '₩' + (amount || 0).toLocaleString('ko-KR');
}

function updateTotal() {
    var prices = getPriceData();
    var total = prices.roomTotal;
    var breakfastOn = isOptionSelected('breakfast');
    var fastOn = isOptionSelected('fastCheckin');

    var sidebarBreakfast = document.getElementById('sidebar-breakfast');
    var sidebarFast = document.getElementById('sidebar-fastCheckin');
    if (sidebarBreakfast) {
        sidebarBreakfast.style.display = breakfastOn ? 'flex' : 'none';
    }
    if (sidebarFast) {
        sidebarFast.style.display = fastOn ? 'flex' : 'none';
    }

    if (breakfastOn) {
        total += prices.breakfastTotal;
    }
    if (fastOn) {
        total += prices.fastCheckinUnit;
    }

    var totalEl = document.getElementById('reserveTotal');
    if (totalEl) {
        totalEl.textContent = formatWon(total);
    }
}

function handleSameAsBooker() {
    var checked = document.getElementById('sameAsBooker').checked;
    if (checked) {
        document.getElementById('guest_last_name').value = document.getElementById('booker_last_name').value;
        document.getElementById('guest_first_name').value = document.getElementById('booker_first_name').value;
        document.getElementById('guest_phone').value = document.getElementById('boot_phone').value;
    }
    ['guest_last_name', 'guest_first_name', 'guest_phone'].forEach(function(id) {
        document.getElementById(id).readOnly = checked;
    });
}

function handleLoadMemberInfo() {
    var checked = document.getElementById('loadMemberInfo').checked;
    var cfg = window.resConfig || {};
    if (checked) {
        document.getElementById('booker_last_name').value = cfg.memberLastName || '';
        document.getElementById('booker_first_name').value = cfg.memberFirstName || '';
        document.getElementById('boot_phone').value = cfg.memberPhone || '';
        document.getElementById('boot_email').value = cfg.memberEmail || '';
        document.getElementById('boot_email_confirm').value = cfg.memberEmail || '';
        document.getElementById('member_address').value = cfg.memberAddress || '';
    } else {
        document.getElementById('booker_last_name').value = '';
        document.getElementById('booker_first_name').value = '';
        document.getElementById('boot_phone').value = '';
        document.getElementById('boot_email').value = '';
        document.getElementById('boot_email_confirm').value = '';
        document.getElementById('member_address').value = '';
    }
    if (document.getElementById('sameAsBooker').checked) {
        handleSameAsBooker();
    }
}

function submitReserveForm() {
    if (document.getElementById('sameAsBooker').checked) {
        handleSameAsBooker();
    }
    syncHiddenOptions();

    var ids = ['guest_last_name', 'guest_first_name', 'guest_phone',
        'booker_last_name', 'booker_first_name', 'boot_phone', 'boot_email', 'boot_email_confirm'];
    for (var i = 0; i < ids.length; i++) {
        if (!document.getElementById(ids[i]).value.trim()) {
            alert('필수 항목을 모두 입력해주세요.');
            return false;
        }
    }
    if (document.getElementById('boot_email').value !== document.getElementById('boot_email_confirm').value) {
        alert('이메일 주소가 일치하지 않습니다.');
        return false;
    }
    if (!document.getElementById('agreeTerms').checked) {
        alert('숙박약관에 동의해주세요.');
        return false;
    }
    document.getElementById('reserveBtn').disabled = true;
    document.getElementById('reserveBtn').textContent = '처리 중...';
    return true;
}

function initReservationPage() {
    var breakfastBtn = document.getElementById('option-breakfast');
    var fastBtn = document.getElementById('option-fastCheckin');
    if (breakfastBtn) {
        breakfastBtn.addEventListener('click', function() { toggleOption('breakfast'); });
    }
    if (fastBtn) {
        fastBtn.addEventListener('click', function() { toggleOption('fastCheckin'); });
    }

    if (window.lucide) {
        lucide.createIcons();
    }
    syncHiddenOptions();
    updateTotal();
}
