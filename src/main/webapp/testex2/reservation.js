/* hotelreservation.jsp — 옵션·요금·검증·결제 */

var selectedPlans = [];

function isOptionSelected(id) {
    return selectedPlans.indexOf(id) !== -1;
}

function getSelectedPaymentMethod() {
    var online = document.querySelector('input[name="payment_method"][value="online"]');
    if (online && online.checked) {
        return 'online';
    }
    return 'onsite';
}

function handlePaymentMethodChange() {
    var method = getSelectedPaymentMethod();
    var noteOnline = document.getElementById('paymentNoteOnline');
    var noteOnsite = document.getElementById('paymentNoteOnsite');
    var btnNote = document.getElementById('reserveBtnNote');
    var btn = document.getElementById('reserveBtn');
    var cardOnline = document.getElementById('payCardOnline');
    var cardOnsite = document.getElementById('payCardOnsite');

    if (cardOnline) {
        cardOnline.classList.toggle('selected', method === 'online');
    }
    if (cardOnsite) {
        cardOnsite.classList.toggle('selected', method === 'onsite');
    }
    if (noteOnline) {
        noteOnline.style.display = method === 'online' ? 'block' : 'none';
    }
    if (noteOnsite) {
        noteOnsite.style.display = method === 'onsite' ? 'block' : 'none';
    }
    if (btnNote) {
        btnNote.textContent = method === 'online'
            ? 'カカオペイ決済画面へ移動します。'
            : '現地決済で予約を申し込みます。';
    }
    if (btn) {
        btn.textContent = method === 'online' ? 'カカオペイで決済する' : '現地決済で予約する';
    }
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

function formatYen(amount) {
    return '¥' + (amount || 0).toLocaleString('ja-JP');
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
        totalEl.textContent = formatYen(total);
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

function hasMemberProfile(cfg) {
    return !!(cfg.memberLastName || cfg.memberFirstName || cfg.memberPhone || cfg.memberEmail || cfg.memberAddress);
}

function fillBookerFromMember(cfg) {
    document.getElementById('booker_last_name').value = cfg.memberLastName || '';
    document.getElementById('booker_first_name').value = cfg.memberFirstName || '';
    document.getElementById('boot_phone').value = cfg.memberPhone || '';
    document.getElementById('boot_email').value = cfg.memberEmail || '';
    document.getElementById('boot_email_confirm').value = cfg.memberEmail || '';
    document.getElementById('member_address').value = cfg.memberAddress || '';
}

function clearBookerFields() {
    document.getElementById('booker_last_name').value = '';
    document.getElementById('booker_first_name').value = '';
    document.getElementById('boot_phone').value = '';
    document.getElementById('boot_email').value = '';
    document.getElementById('boot_email_confirm').value = '';
    document.getElementById('member_address').value = '';
}

function handleLoadMemberInfo() {
    var cb = document.getElementById('loadMemberInfo');
    if (!cb) return;

    var checked = cb.checked;
    var cfg = window.resConfig || {};

    if (checked && !cfg.isLoggedIn) {
        alert('会員情報の読み込みはログイン後にご利用いただけます。');
        cb.checked = false;
        if (cfg.loginUrl) {
            if (confirm('ログインページへ移動しますか？')) {
                location.href = cfg.loginUrl;
            }
        }
        return;
    }

    if (checked && !hasMemberProfile(cfg)) {
        alert('読み込む会員情報がありません。\n会員登録・マイページで情報を登録したかご確認ください。');
        cb.checked = false;
        return;
    }

    if (checked) {
        fillBookerFromMember(cfg);
    } else {
        clearBookerFields();
    }

    if (document.getElementById('sameAsBooker') && document.getElementById('sameAsBooker').checked) {
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
            alert('必須項目をすべて入力してください。');
            return false;
        }
    }
    if (document.getElementById('boot_email').value !== document.getElementById('boot_email_confirm').value) {
        alert('メールアドレスが一致しません。');
        return false;
    }
    if (!document.getElementById('agreeTerms').checked) {
        alert('宿泊規約に同意してください。');
        return false;
    }

    var btn = document.getElementById('reserveBtn');
    btn.disabled = true;
    btn.textContent = getSelectedPaymentMethod() === 'online' ? '決済画面へ移動中...' : '予約処理中...';
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

    document.querySelectorAll('input[name="payment_method"]').forEach(function(el) {
        el.addEventListener('change', handlePaymentMethodChange);
    });
    handlePaymentMethodChange();

    if (window.lucide) {
        lucide.createIcons();
    }
    syncHiddenOptions();
    updateTotal();
}
