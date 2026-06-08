/* ════════════════════════════════════════════════════════
       호텔 데이터
       ════════════════════════════════════════════════════════ */
    var hotelData = [
        {
            id: 1, city: "도쿄",
            name: "JYP 호텔 도쿄 지점",
            rating: 4.5,
            images: ['images/hotel1/main.jpg', 'images/hotel1/room.jpg', 'images/hotel1/restaurant.jpg', 'images/hotel1/pool.jpg'],
            amenities: [
                {icon:'🍴',label:'식사'},{icon:'📶',label:'WiFi'},{icon:'♿',label:'장애인'},
                {icon:'🏢',label:'비즈니스'},{icon:'🛏️',label:'침대'},{icon:'🎨',label:'침구'},
                {icon:'🖥️',label:'컴퓨터'},{icon:'📡',label:'WiFi 6'},{icon:'🚪',label:'출입'}
            ],
            cities: "오차노미즈, 구단시타, 이이다바시, 스이도바시 인근",
            features: "고마고메역 인근에서 유일하게 14층에서 숙박할 수 있는 호텔입니다! 최상층은 고급 인테리어의 슈페리어 룸으로 운영됩니다.",
            meal: "매일 아침 7시 오픈! 도쿄에서 인기 있는 주먹밥 전문점 '켄짱 오니기리 오츠카점'과 협력하여 제공하는 조식.",
            access: [{icon:'🚂', text:'JR 야마노테선 고마고메역 (북쪽 출구) → 도보 3분'}],
            rooms: [
                { grade:"싱글 베드룸", roomClass:"스탠다드", features:['금연','시티뷰'],
                  images:['images/hotel1/room1_1.jpg','images/hotel1/room1_2.jpg','images/hotel1/room1_3.jpg','images/hotel1/room1_4.jpg'],
                  description:"한 명의 손님을 위한 아늑한 공간. 현대적인 인테리어와 편안한 침구가 특징입니다.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'📱',label:'충전기'}],
                  meal:"조식 미포함", pricing:[{capacity:"최대 1인",price:450000,unit:"원",remaining:"잔여 5개"}] },
                { grade:"싱글 베드룸", roomClass:"디럭스", features:['금연','시티뷰','프리미엄'],
                  images:['images/hotel1/room2_1.jpg','images/hotel1/room2_2.jpg','images/hotel1/room2_3.jpg','images/hotel1/room2_4.jpg'],
                  description:"디럭스 싱글 객실. 더 넓은 공간과 프리미엄 어메니티가 제공됩니다.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'📱',label:'충전기'}],
                  meal:"조식 포함", pricing:[{capacity:"최대 1인",price:650000,unit:"원",remaining:"잔여 3개"}] },
                { grade:"트윈 베드룸", roomClass:"스탠다드", features:['금연','오션뷰'],
                  images:['images/hotel1/room3_1.jpg','images/hotel1/room3_2.jpg','images/hotel1/room3_3.jpg','images/hotel1/room3_4.jpg'],
                  description:"두 명의 손님을 위한 넓은 공간. 트윈 침대와 함께 편안한 휴식이 보장됩니다.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'📱',label:'충전기'}],
                  meal:"조식 포함 - 일식 조식", pricing:[{capacity:"최대 2인",price:650000,unit:"원",remaining:"잔여 8개"}] },
                { grade:"트윈 베드룸", roomClass:"디럭스", features:['금연','오션뷰','럭셔리'],
                  images:['images/hotel1/room4_1.jpg','images/hotel1/room4_2.jpg','images/hotel1/room4_3.jpg','images/hotel1/room4_4.jpg'],
                  description:"디럭스 트윈 객실. 고급 인테리어와 최상의 전망을 제공합니다.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - 프리미엄", pricing:[{capacity:"최대 2인",price:950000,unit:"원",remaining:"잔여 4개"}] },
                { grade:"패밀리 룸", roomClass:"스탠다드", features:['금연','시티뷰','킹사이즈'],
                  images:['images/hotel1/room5_1.jpg','images/hotel1/room5_2.jpg','images/hotel1/room5_3.jpg','images/hotel1/room5_4.jpg'],
                  description:"가족 단위의 손님들을 위한 큰 공간.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'🧸',label:'아동용품'}],
                  meal:"조식 포함 - 일식/양식 선택", pricing:[{capacity:"최대 5인",price:950000,unit:"원",remaining:"잔여 3개"}] },
                { grade:"패밀리 룸", roomClass:"디럭스", features:['금연','시티뷰','킹사이즈','프리미엄'],
                  images:['images/hotel1/room6_1.jpg','images/hotel1/room6_2.jpg','images/hotel1/room6_3.jpg','images/hotel1/room6_4.jpg'],
                  description:"디럭스 패밀리 룸. 가족 모두를 위한 넓고 고급스러운 공간.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'🧸',label:'아동용품'}],
                  meal:"조식 포함 - 프리미엄 뷔페", pricing:[{capacity:"최대 5인",price:1300000,unit:"원",remaining:"잔여 2개"}] },
                { grade:"스위트룸", roomClass:"스위트", features:['금연','펜트하우스','전용라운지'],
                  images:['images/hotel1/suite1_1.jpg','images/hotel1/suite1_2.jpg','images/hotel1/suite1_3.jpg','images/hotel1/suite1_4.jpg'],
                  description:"최고급 스위트룸. 별도의 거실과 침실, 전용 라운지 이용이 가능합니다.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'자쿠지'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'🍾',label:'미니바'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - VIP 룸서비스", pricing:[{capacity:"최대 4인",price:2500000,unit:"원",remaining:"잔여 1개"}] }
            ]
        },
        {
            id: 2, city: "도쿄",
            name: "JYP 호텔 신주쿠 지점",
            rating: 4.0,
            images: ['images/hotel2/main.jpg', 'images/hotel2/room.jpg', 'images/hotel2/restaurant.jpg', 'images/hotel2/pool.jpg'],
            amenities: [
                {icon:'📶',label:'WiFi'},{icon:'🍴',label:'식사'},{icon:'🏢',label:'비즈니스'},
                {icon:'🛏️',label:'침대'},{icon:'📡',label:'WiFi 6'},{icon:'🚪',label:'출입'},
                {icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피'}
            ],
            cities: "신주쿠, 시부야, 미나토 인근",
            features: "합리적인 가격의 편안한 객실을 제공하는 호텔. 주요 교통 중심지와 가까운 최적의 위치입니다.",
            meal: "매일 아침 간단한 토스트와 커피가 포함된 무료 조식을 제공합니다.",
            access: [{icon:'🚂', text:'JR 야마노테선 신주쿠역 → 도보 3분'}],
            rooms: [
                { grade:"싱글 베드룸", roomClass:"스탠다드", features:['금연'],
                  images:['images/hotel2/room1_1.jpg','images/hotel2/room1_2.jpg','images/hotel2/room1_3.jpg','images/hotel2/room1_4.jpg'],
                  description:"기본적인 편의시설을 갖춘 싱글 객실.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'📱',label:'충전기'},{icon:'☕',label:'커피'}],
                  meal:"조식 미포함", pricing:[{capacity:"최대 1인",price:350000,unit:"원",remaining:"잔여 10개"}] },
                { grade:"싱글 베드룸", roomClass:"디럭스", features:['금연','업그레이드'],
                  images:['images/hotel2/room2_1.jpg','images/hotel2/room2_2.jpg','images/hotel2/room2_3.jpg','images/hotel2/room2_4.jpg'],
                  description:"디럭스 싱글. 더 넓고 쾌적한 공간.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'📱',label:'충전기'},{icon:'☕',label:'커피'}],
                  meal:"조식 포함", pricing:[{capacity:"최대 1인",price:500000,unit:"원",remaining:"잔여 5개"}] },
                { grade:"트윈 베드룸", roomClass:"스탠다드", features:['금연','시티뷰'],
                  images:['images/hotel2/room3_1.jpg','images/hotel2/room3_2.jpg','images/hotel2/room3_3.jpg','images/hotel2/room3_4.jpg'],
                  description:"두 명을 위한 스탠다드 트윈 객실.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'📱',label:'충전기'}],
                  meal:"조식 포함 - 컨티넨탈식", pricing:[{capacity:"최대 2인",price:500000,unit:"원",remaining:"잔여 12개"}] },
                { grade:"트윈 베드룸", roomClass:"디럭스", features:['금연','시티뷰','프리미엄'],
                  images:['images/hotel2/room4_1.jpg','images/hotel2/room4_2.jpg','images/hotel2/room4_3.jpg','images/hotel2/room4_4.jpg'],
                  description:"디럭스 트윈. 고급스러운 인테리어.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - 프리미엄", pricing:[{capacity:"최대 2인",price:750000,unit:"원",remaining:"잔여 6개"}] },
                { grade:"패밀리 룸", roomClass:"스탠다드", features:['금연','넓은공간'],
                  images:['images/hotel2/room5_1.jpg','images/hotel2/room5_2.jpg','images/hotel2/room5_3.jpg','images/hotel2/room5_4.jpg'],
                  description:"가족 여행에 적합한 넓은 패밀리 객실.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🧸',label:'아동용품'},{icon:'☕',label:'커피머신'},{icon:'🍽️',label:'식탁'}],
                  meal:"조식 포함 - 뷔페식", pricing:[{capacity:"최대 5인",price:750000,unit:"원",remaining:"잔여 5개"}] },
                { grade:"패밀리 룸", roomClass:"디럭스", features:['금연','넓은공간','프리미엄'],
                  images:['images/hotel2/room6_1.jpg','images/hotel2/room6_2.jpg','images/hotel2/room6_3.jpg','images/hotel2/room6_4.jpg'],
                  description:"디럭스 패밀리 룸. 프리미엄 서비스와 넓은 공간.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🧸',label:'아동용품'},{icon:'☕',label:'커피머신'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - 프리미엄 뷔페", pricing:[{capacity:"최대 5인",price:1100000,unit:"원",remaining:"잔여 3개"}] },
                { grade:"스위트룸", roomClass:"스위트", features:['금연','VIP','전용발코니'],
                  images:['images/hotel2/suite1_1.jpg','images/hotel2/suite1_2.jpg','images/hotel2/suite1_3.jpg','images/hotel2/suite1_4.jpg'],
                  description:"프리미엄 스위트룸. 넓은 거실과 전용 발코니.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'자쿠지'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'🍾',label:'미니바'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - VIP 서비스", pricing:[{capacity:"최대 4인",price:1800000,unit:"원",remaining:"잔여 2개"}] }
            ]
        },
        {
            id: 3, city: "요코하마",
            name: "JYP 호텔 요코하마 지점",
            rating: 4.8,
            images: ['images/hotel3/main.jpg', 'images/hotel3/room.jpg', 'images/hotel3/restaurant.jpg', 'images/hotel3/pool.jpg'],
            amenities: [
                {icon:'🍴',label:'식사'},{icon:'📶',label:'WiFi'},{icon:'♿',label:'장애인'},
                {icon:'🏢',label:'비즈니스'},{icon:'🛏️',label:'침대'},{icon:'🎨',label:'침구'},
                {icon:'🖥️',label:'컴퓨터'},{icon:'📡',label:'WiFi 6'},{icon:'🚪',label:'출입'}
            ],
            cities: "지요다구, 주오구, 미나토구 인근",
            features: "세계 최고 수준의 시설을 자랑하는 럭셔리 호텔. 24시간 프리미엄 컨시어지 서비스가 제공됩니다.",
            meal: "미슐랭 레스토랑 및 라운지 바 완비. 룸서비스 가능.",
            access: [{icon:'✈️', text:'하네다 공항 → 리무진 픽업 서비스 40분'}],
            rooms: [
                { grade:"싱글 베드룸", roomClass:"스탠다드", features:['금연','시티뷰'],
                  images:['images/디럭스 싱글.png','images/욕실.png'],
                  description:"럭셔리한 싱글 객실. 최고급 침구와 현대식 편의시설.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'📱',label:'충전기'}],
                  meal:"조식 포함 - 프리미엄", pricing:[{capacity:"최대 1인",price:850000,unit:"원",remaining:"잔여 3개"}] },
                { grade:"싱글 베드룸", roomClass:"디럭스", features:['금연','시티뷰','VIP'],
                  images:['images/hotel3/room2_1.jpg','images/hotel3/room2_2.jpg','images/hotel3/room2_3.jpg','images/hotel3/room2_4.jpg'],
                  description:"디럭스 싱글. 전용 컨시어지 서비스 포함.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - VIP", pricing:[{capacity:"최대 1인",price:1200000,unit:"원",remaining:"잔여 2개"}] },
                { grade:"트윈 베드룸", roomClass:"스탠다드", features:['금연','오션뷰','럭셔리'],
                  images:['images/hotel3/room3_1.jpg','images/hotel3/room3_2.jpg','images/hotel3/room3_3.jpg','images/hotel3/room3_4.jpg'],
                  description:"5성급 트윈 객실. 스파 욕실과 최고급 어메니티.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - 프리미엄 뷔페", pricing:[{capacity:"최대 2인",price:1200000,unit:"원",remaining:"잔여 4개"}] },
                { grade:"트윈 베드룸", roomClass:"디럭스", features:['금연','오션뷰','최고급'],
                  images:['images/hotel3/room4_1.jpg','images/hotel3/room4_2.jpg','images/hotel3/room4_3.jpg','images/hotel3/room4_4.jpg'],
                  description:"최고급 디럭스 트윈. 모든 프리미엄 서비스 포함.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'자쿠지'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'🍾',label:'미니바'},{icon:'💆',label:'스파'}],
                  meal:"조식 포함 - VIP 뷔페", pricing:[{capacity:"최대 2인",price:1800000,unit:"원",remaining:"잔여 2개"}] },
                { grade:"패밀리 룸", roomClass:"스탠다드", features:['금연','시티뷰','킹사이즈'],
                  images:['images/hotel3/room5_1.jpg','images/hotel3/room5_2.jpg','images/hotel3/room5_3.jpg','images/hotel3/room5_4.jpg'],
                  description:"럭셔리 패밀리 스위트룸. 분리된 거실과 침실.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'욕실'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'☕',label:'커피머신'},{icon:'🧸',label:'아동용품'}],
                  meal:"조식 포함 - 프리미엄 일식/양식", pricing:[{capacity:"최대 5인",price:1800000,unit:"원",remaining:"잔여 2개"}] },
                { grade:"패밀리 룸", roomClass:"디럭스", features:['금연','시티뷰','킹사이즈','VIP'],
                  images:['images/hotel3/room6_1.jpg','images/hotel3/room6_2.jpg','images/hotel3/room6_3.jpg','images/hotel3/room6_4.jpg'],
                  description:"디럭스 패밀리. VIP 컨시어지 서비스와 전용 라운지.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'자쿠지'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'🍾',label:'미니바'},{icon:'🧸',label:'아동용품'}],
                  meal:"조식 포함 - VIP 프리미엄", pricing:[{capacity:"최대 5인",price:2500000,unit:"원",remaining:"잔여 1개"}] },
                { grade:"스위트룸", roomClass:"스위트", features:['금연','펜트하우스','전용버틀러'],
                  images:['images/hotel3/suite1_1.jpg','images/hotel3/suite1_2.jpg','images/hotel3/suite1_3.jpg','images/hotel3/suite1_4.jpg'],
                  description:"로열 스위트룸. 전용 버틀러 서비스와 리무진 픽업 포함.",
                  amenities:[{icon:'📺',label:'TV'},{icon:'🛁',label:'자쿠지'},{icon:'🌡️',label:'에어컨'},{icon:'🔒',label:'금고'},{icon:'🍾',label:'미니바'},{icon:'🚗',label:'리무진'}],
                  meal:"조식 포함 - 로열 서비스", pricing:[{capacity:"최대 4인",price:5000000,unit:"원",remaining:"잔여 1개"}] }
            ]
        }
    ];

    /* ════════════════════════════════════════════════════════
       앱 상태 변수
       ════════════════════════════════════════════════════════ */
    var selectedHotel    = null;           // 현재 선택된 호텔 객체
    var selectedCheckin  = null;           // 선택된 체크인 날짜 (Date 객체)
    var currentCalendarDate = new Date();  // 달력에 표시 중인 연/월
    var filteredHotels   = hotelData.slice(); // 검색 필터링된 호텔 목록
    var selectedRoomClass = '스탠다드';   // 선택된 객실 등급

    /* ════════════════════════════════════════════════════════
       유틸리티 함수
       ════════════════════════════════════════════════════════ */

    /**
     * Date 객체를 'YYYY-MM-DD' 문자열로 변환
     */
    function formatDate(date) {
        var y = date.getFullYear();
        var m = String(date.getMonth() + 1).padStart(2, '0');
        var d = String(date.getDate()).padStart(2, '0');
        return y + '-' + m + '-' + d;
    }

    /**
     * 'YYYY-MM-DD' 문자열을 로컬 시간 기준 Date 객체로 변환
     * (new Date(str) 는 UTC로 해석되어 한국에서 날짜가 하루 밀릴 수 있으므로 직접 파싱)
     */
    function parseLocalDate(str) {
        var p = str.split('-');
        return new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]));
    }

    /**
     * 오늘 날짜 (시간 제거된 Date 객체) 반환
     */
    function getToday() {
        var t = new Date();
        t.setHours(0, 0, 0, 0);
        return t;
    }

    /**
     * 이미지 슬롯 HTML 생성
     * - 실제 이미지 경로이면 <img> 태그로, 아니면 플레이스홀더로 렌더링
     * - 이미지 클릭 시 라이트박스로 확대 가능
     * @param {string} src        이미지 경로 또는 대체 텍스트
     * @param {string} label      alt 텍스트 / 플레이스홀더 라벨
     * @param {string} extraClass 추가 CSS 클래스
     * @param {string} styleStr   인라인 스타일 문자열
     */
    function imgSlot(src, label, extraClass, styleStr) {
        var isPath = src && (src.indexOf('/') !== -1 || /\.(jpg|jpeg|png|webp|gif)$/i.test(src));
        var inner = isPath
            ? '<img src="' + src + '" alt="' + label + '" class="zoomable"'
              + ' onclick="openLightbox(\'' + src.replace(/'/g, "\\'") + '\',\'' + label.replace(/'/g, "\\'") + '\')"'
              + ' style="width:100%;height:100%;object-fit:cover;display:block;">'
            : '<div style="width:100%;height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;'
              + 'color:#aaa;font-size:11px;gap:4px;background:#f0ece3;">'
              + '<span style="font-size:20px;">📷</span>' + label + '</div>';
        return '<div class="' + extraClass + '" style="' + styleStr + 'overflow:hidden;border-radius:4px;">' + inner + '</div>';
    }

    /* ════════════════════════════════════════════════════════
       객실 등급 선택
       ════════════════════════════════════════════════════════ */

    /**
     * 객실 등급 버튼 클릭 처리
     * - 선택된 버튼에 .selected 클래스 토글
     * - 예약 정보 박스 업데이트
     */
    function selectRoomClass(roomClass) {
        selectedRoomClass = roomClass;
        document.querySelectorAll('.room-class-btn').forEach(function(btn) {
            btn.classList.toggle('selected', btn.getAttribute('data-class') === roomClass);
        });
        document.getElementById('infoRoomClass').textContent = roomClass;
    }

    /* ════════════════════════════════════════════════════════
       예약 정보 박스 업데이트
       ════════════════════════════════════════════════════════ */

    /**
     * 사이드바 하단 예약 정보 요약 박스를 현재 입력값으로 갱신
     */
    function updateInfoBox() {
        document.getElementById('infoNights').textContent    = document.getElementById('nights').value;
        document.getElementById('infoRooms').textContent     = document.getElementById('rooms').value;
        document.getElementById('infoAdults').textContent    = document.getElementById('adults').value;
        document.getElementById('infoChildren').textContent  = document.getElementById('children').value;
        document.getElementById('infoRoomClass').textContent = selectedRoomClass;

        // 체크아웃 날짜 = 체크인 + 숙박일수
        if (selectedCheckin) {
            var co = new Date(selectedCheckin);
            co.setDate(co.getDate() + parseInt(document.getElementById('nights').value));
            document.getElementById('infoCheckout').textContent = formatDate(co);
        }
    }

    /* ════════════════════════════════════════════════════════
       숫자 카운터 (숙박일수 / 방 수 / 성인 / 어린이)
       ════════════════════════════════════════════════════════ */

    /**
     * +/− 버튼으로 숫자 입력 필드 값 변경
     * @param {string} id    대상 input 요소 id
     * @param {number} delta 변경량 (+1 또는 -1)
     * @param {number} min   최솟값
     * @param {number} max   최댓값
     */
    function changeCount(id, delta, min, max) {
        var input = document.getElementById(id);
        var val = parseInt(input.value) + delta;
        if (val >= min && val <= max) {
            input.value = val;
            updateInfoBox();
        }
    }

    /* ════════════════════════════════════════════════════════
       호텔 목록 검색 & 렌더링
       ════════════════════════════════════════════════════════ */

    /** 검색어로 hotelData 필터링 후 목록 재렌더링 */
    function searchHotels() {
        var term = document.getElementById('hotelSearchInput').value.toLowerCase().trim();
        filteredHotels = term
            ? hotelData.filter(function(h) { return h.name.toLowerCase().indexOf(term) !== -1; })
            : hotelData.slice();
        renderHotelList();
    }

    /** 검색어 초기화 후 전체 목록 재렌더링 */
    function clearHotelSearch() {
        document.getElementById('hotelSearchInput').value = '';
        filteredHotels = hotelData.slice();
        renderHotelList();
    }

    /** filteredHotels 배열을 #hotelList 에 HTML로 렌더링 */
    function renderHotelList() {
        var hotelList = document.getElementById('hotelList');
        if (filteredHotels.length === 0) {
            hotelList.innerHTML = '<div style="padding:10px;color:#999;text-align:center;font-size:13px;">검색 결과 없음</div>';
            return;
        }
        hotelList.innerHTML = filteredHotels.map(function(hotel) {
            var sel = (selectedHotel && selectedHotel.id === hotel.id) ? ' selected' : '';
            return '<div class="hotel-option' + sel + '" data-id="' + hotel.id + '">'
                 + '<div class="hotel-option-name">' + hotel.name + '</div>'
                 + '<div class="hotel-option-info">'
                 + '<span>⭐ ' + hotel.rating + '/5.0</span>'
                 + '<span>🏨 ' + hotel.rooms.length + '가지 객실</span>'
                 + '</div></div>';
        }).join('');

        // 클릭 이벤트: 이벤트 위임으로 처리
        hotelList.onclick = function(e) {
            var option = e.target.closest('.hotel-option');
            if (!option) return;
            selectHotel(parseInt(option.getAttribute('data-id')));
        };
    }

    /**
     * 호텔 선택 처리
     * - 목록에서 선택된 항목 강조
     * - 예약 정보 박스의 호텔명 업데이트
     */
    function selectHotel(hotelId) {
        selectedHotel = hotelData.find(function(h) { return h.id === hotelId; });
        if (!selectedHotel) return;
        document.querySelectorAll('.hotel-option').forEach(function(el) {
            el.classList.toggle('selected', parseInt(el.getAttribute('data-id')) === hotelId);
        });
        document.getElementById('infoHotelName').textContent = selectedHotel.name;
        updateInfoBox();
    }

    /* ════════════════════════════════════════════════════════
       커스텀 달력 (체크인 날짜 선택)
       ════════════════════════════════════════════════════════ */

    /** 달력 초기화: 이벤트 리스너 등록 */
    function initCalendar() {
        renderCalendar();
        var input = document.getElementById('checkinDate');
        var cal   = document.getElementById('checkinCalendar');

        // 날짜 입력창 클릭 → 달력 토글
        input.addEventListener('click', function(e) {
            e.stopPropagation();
            cal.classList.toggle('active');
        });
        // 달력 내부 클릭 시 이벤트 버블링 차단 (외부 클릭 닫힘 방지)
        cal.addEventListener('click', function(e) { e.stopPropagation(); });
        // 달력 외부 클릭 시 닫기
        document.addEventListener('click', function() { cal.classList.remove('active'); });
    }

    /**
     * 달력 HTML 렌더링
     * - currentCalendarDate 기준으로 해당 월의 날짜 그리드 생성
     * - 과거 날짜 / 다른 달 날짜는 비활성화(disabled)
     */
    function renderCalendar() {
        var cal      = document.getElementById('checkinCalendar');
        var year     = currentCalendarDate.getFullYear();
        var month    = currentCalendarDate.getMonth();
        var today    = getToday();
        var firstDay = new Date(year, month, 1);

        // 달력의 첫 번째 칸은 해당 월 1일의 요일에 맞춰 이전 달 날짜부터 시작
        var startDate = new Date(firstDay);
        startDate.setDate(startDate.getDate() - firstDay.getDay());

        var html = '<div class="calendar-header">'
            + '<button type="button" onclick="previousMonth()">← 이전</button>'
            + '<h3>' + year + '년 ' + (month + 1) + '월</h3>'
            + '<button type="button" onclick="nextMonth()">다음 →</button>'
            + '</div>'
            + '<div class="weekdays"><div>일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div></div>'
            + '<div class="days">';

        // 6주(42칸) 렌더링
        for (var i = 0; i < 42; i++) {
            var date = new Date(startDate);
            date.setDate(startDate.getDate() + i);

            var isPast       = date < today;
            var isOtherMonth = date.getMonth() !== month;
            var isSelected   = selectedCheckin && date.toDateString() === selectedCheckin.toDateString();
            var cls = 'day' + (isPast || isOtherMonth ? ' disabled' : '') + (isSelected ? ' selected' : '');

            if (isPast || isOtherMonth) {
                // 선택 불가 날짜: data-date 없음
                html += '<div class="' + cls + '">' + date.getDate() + '</div>';
            } else {
                // 선택 가능 날짜: data-date 속성 포함
                html += '<div class="' + cls + '" data-date="' + formatDate(date) + '">' + date.getDate() + '</div>';
            }
        }
        html += '</div>';
        cal.innerHTML = html;

        // 날짜 클릭 이벤트: 이벤트 위임으로 처리
        cal.querySelector('.days').onclick = function(e) {
            var day = e.target.closest('.day');
            if (!day || day.classList.contains('disabled')) return;
            var ds = day.getAttribute('data-date');
            if (ds) selectDate(ds);
        };
    }

    /**
     * 날짜 선택 처리
     * - selectedCheckin 업데이트
     * - 입력창 및 예약 정보 박스 갱신
     * - 달력 닫기
     */
    function selectDate(dateStr) {
        selectedCheckin = parseLocalDate(dateStr);
        document.getElementById('checkinDate').value   = dateStr;
        document.getElementById('infoCheckin').textContent = dateStr;
        updateInfoBox();
        document.getElementById('checkinCalendar').classList.remove('active');
        renderCalendar(); // 선택 표시 갱신
    }

    /** 달력 이전 달로 이동 */
    function previousMonth() {
        currentCalendarDate.setMonth(currentCalendarDate.getMonth() - 1);
        renderCalendar();
    }
    /** 달력 다음 달로 이동 */
    function nextMonth() {
        currentCalendarDate.setMonth(currentCalendarDate.getMonth() + 1);
        renderCalendar();
    }

    /* ════════════════════════════════════════════════════════
       객실 필터링
       ════════════════════════════════════════════════════════ */

    /**
     * 선택한 등급과 인원수 조건에 맞는 객실만 반환
     * - 싱글 베드룸은 (방 수 = 성인 수) && (어린이 0명) 인 경우에만 표시
     * @param {Array}  rooms     호텔의 전체 객실 배열
     * @param {string} roomClass 선택된 등급 ('스탠다드' | '디럭스' | '스위트')
     */
    function filterRooms(rooms, roomClass) {
        var adults    = parseInt(document.getElementById('adults').value);
        var children  = parseInt(document.getElementById('children').value);
        var roomCount = parseInt(document.getElementById('rooms').value);
        var showSingle = (roomCount === adults && children === 0);

        return rooms.filter(function(r) {
            if (r.roomClass !== roomClass) return false;
            if (!showSingle && r.grade === '싱글 베드룸') return false;
            return true;
        });
    }

    /* ════════════════════════════════════════════════════════
       검색 결과 렌더링
       ════════════════════════════════════════════════════════ */

    /**
     * 검색 버튼 클릭 시 호텔 상세 + 객실 목록을 오른쪽 콘텐츠 영역에 렌더링
     */
    function displaySearchResults() {
        if (!selectedHotel)   { alert('호텔 지점을 선택해주세요.');  return; }
        if (!selectedCheckin) { alert('체크인 날짜를 선택해주세요.'); return; }

        var hotel  = selectedHotel;
        var hid    = hotel.id;
        var nights = parseInt(document.getElementById('nights').value);
        var filteredRooms = filterRooms(hotel.rooms, selectedRoomClass);

        // 해당 등급 객실이 없는 경우 안내 메시지
        if (filteredRooms.length === 0) {
            document.getElementById('results').innerHTML = '<div class="no-results">선택한 객실 등급에 해당하는 객실이 없습니다.</div>';
            document.getElementById('resultsContainer').style.display = 'block';
            document.getElementById('initialMessage').style.display = 'none';
            return;
        }

        // 호텔 갤러리 (첫 3장: 대표 1장 + 보조 2장 + "전체 사진 보기" 버튼)
        var galleryHtml = '<div class="hotel-gallery">';
        for (var gi = 0; gi < 3; gi++) {
            var isMain = (gi === 0);
            var cls = 'gallery-item' + (isMain ? ' main' : '');
            var sty = isMain ? 'height:196px;' : 'height:90px;';
            galleryHtml += imgSlot(hotel.images[gi] || ('사진' + (gi + 1)), hotel.images[gi] || ('사진' + (gi + 1)), cls, sty);
        }
        galleryHtml += '<div class="gallery-item see-all">전체 사진 보기</div></div>';

        // 호텔 상세 카드 HTML 조립
        var html = '<div class="hotel-detail-card">'
            + '<div class="detail-title">' + hotel.name + '</div>'
            + '<div class="detail-header-section">'
            + galleryHtml
            + '<div class="detail-info">'

            // 어메니티 아이콘 그리드
            + '<div class="amenities-icons">'
            + hotel.amenities.map(function(a) {
                return '<div class="amenity-icon">'
                     + '<div style="font-size:20px">' + a.icon + '</div>'
                     + '<div class="amenity-label">' + a.label + '</div>'
                     + '</div>';
              }).join('')
            + '</div>'

            // 위치 섹션
            + '<div class="detail-section">'
            + '<div class="section-label">위치</div>'
            + '<div class="section-content">' + hotel.cities + '</div>'
            + '</div>'

            // 호텔 특징 (접기/펼치기)
            + '<div class="detail-section">'
            + '<div class="section-label">호텔 특징</div>'
            + '<div class="section-content expandable" id="feat-' + hid + '"><p>' + hotel.features + '</p></div>'
            + '<div class="expand-btn" onclick="toggleExpand(\'feat-' + hid + '\')">더보기 ▼</div>'
            + '</div>'

            // 식사 안내 (접기/펼치기)
            + '<div class="detail-section">'
            + '<div class="section-label">식사 안내</div>'
            + '<div class="section-content expandable" id="meal-' + hid + '"><p>' + hotel.meal + '</p></div>'
            + '<div class="expand-btn" onclick="toggleExpand(\'meal-' + hid + '\')">더보기 ▼</div>'
            + '</div>'

            // 교통 안내
            + '<div class="detail-section">'
            + '<div class="section-label">교통 안내</div>'
            + '<div class="section-content">'
            + hotel.access.map(function(item) {
                return '<div class="access-item">'
                     + '<div class="access-icon">' + item.icon + '</div>'
                     + '<div class="access-text">' + item.text + '</div>'
                     + '</div>';
              }).join('')
            + '</div></div>'
            + '</div></div>'

            // 객실 선택 섹션 시작
            + '<div class="rooms-section">'
            + '<div class="rooms-section-title">객실 선택 — ' + selectedRoomClass + ' 등급</div>';

        // 필터링된 각 객실 카드 렌더링
        filteredRooms.forEach(function(room) {
            // 객실 사진 4장 썸네일
            var roomGallery = '<div class="room-gallery">';
            for (var ri = 0; ri < 4; ri++) {
                roomGallery += imgSlot(
                    room.images[ri] || ('사진' + (ri + 1)),
                    room.images[ri] || ('사진' + (ri + 1)),
                    'room-image', 'height:80px;'
                );
            }
            roomGallery += '</div>';

            // 특징 태그 (등급 태그 + 기타 특징)
            var featuresHtml = '<span class="feature-tag room-class">' + room.roomClass + '</span>';
            room.features.forEach(function(f) {
                featuresHtml += '<span class="feature-tag">' + f + '</span>';
            });

            // 가격 계산 (1박 단가 × 숙박일수)
            var total = room.pricing[0].price * nights;
            var p     = room.pricing[0];

            html += '<div class="room-type-container">'
                  + '<div class="room-type-content">'

                  // 왼쪽: 등급명 + 태그 + 사진
                  + '<div class="room-left">'
                  + '<div class="room-grade">' + room.grade + '</div>'
                  + '<div class="room-features">' + featuresHtml + '</div>'
                  + roomGallery
                  + '</div>'

                  // 오른쪽: 설명 + 어메니티 + 식사 + 가격/예약
                  + '<div class="room-right">'
                  + '<div class="room-description">' + room.description + '</div>'
                  + '<div class="room-amenities">'
                  + room.amenities.map(function(a) {
                        return '<div class="room-amenity">'
                             + '<div>' + a.icon + '</div>'
                             + '<div class="room-amenity-label">' + a.label + '</div>'
                             + '</div>';
                    }).join('')
                  + '</div>'
                  + '<div class="room-meal">'
                  + '<div class="room-meal-title">식사 안내</div>'
                  + '<div>' + room.meal + '</div>'
                  + '</div>'
                  + '<div class="room-pricing"><div class="room-price-item">'
                  + '<div class="room-type-label">' + p.capacity + ' · ' + nights + '박</div>'
                  + '<div class="price-display">'
                  + '<span class="price-amount">₩' + total.toLocaleString() + '</span>'
                  + '<span class="price-unit">' + p.unit + '</span>'
                  + '</div>'
                  + '<div class="remaining">' + p.remaining + '</div>'
                  + '<button class="btn-book-room" onclick="bookRoom(\''
                  + room.grade + '\',\'' + p.capacity + '\',' + total + ',\'' + hotel.name + '\',\'' + room.roomClass
                  + '\')">예약하기</button>'
                  + '</div></div>'
                  + '</div></div></div>';
        });

        html += '</div></div>';

        // 결과 영역에 렌더링
        document.getElementById('results').innerHTML = html;
        document.getElementById('resultsContainer').style.display = 'block';
        document.getElementById('initialMessage').style.display   = 'none';
        document.getElementById('resultsContainer').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    /**
     * 텍스트 접기/펼치기 토글
     * @param {string} id 대상 요소 id
     */
    function toggleExpand(id) {
        var el = document.getElementById(id);
        el.classList.toggle('expanded');
        el.nextElementSibling.textContent = el.classList.contains('expanded') ? '접기 ▲' : '더보기 ▼';
    }

    /* ════════════════════════════════════════════════════════
       예약하기 → test01-2.jsp 로 POST 전송
       ════════════════════════════════════════════════════════
       전달 파라미터 (test01-2.jsp 에서 사용):
         hotelName     : 호텔 지점명
         roomGrade     : 객실 등급명
         roomClass     : 스탠다드 | 디럭스 | 스위트
         capacity      : 최대 인원
         basePrice     : 1박 단가 (JS 금액 계산용)
         totalPrice    : nights × basePrice (사이드바 표시용)
         checkin       : 체크인 날짜 (YYYY-MM-DD)
         checkout      : 체크아웃 날짜 (YYYY-MM-DD)
         checkinLabel  : 체크인 한국어 표시 (예: 2026년 6월 10일)
         checkoutLabel : 체크아웃 한국어 표시
         nights        : 숙박 일수
         rooms         : 방 수
         adults        : 성인 수
         children      : 어린이 수
       ════════════════════════════════════════════════════════ */

    /**
     * 예약하기 버튼 클릭 처리
     * - 체크아웃 날짜 / 한국어 라벨 계산
     * - 동적 form 생성 후 POST 제출
     */
    function bookRoom(roomGrade, capacity, price, hotelName, roomClass) {
        var checkin  = document.getElementById('checkinDate').value;
        var nights   = parseInt(document.getElementById('nights').value);
        var rooms    = parseInt(document.getElementById('rooms').value);
        var adults   = parseInt(document.getElementById('adults').value);
        var children = parseInt(document.getElementById('children').value);

        var checkout      = '';
        var checkinLabel  = '';
        var checkoutLabel = '';

        if (checkin) {
            var p  = checkin.split('-');
            var ci = new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]));
            var co = new Date(ci);
            co.setDate(co.getDate() + nights);

            // ISO 형식 체크아웃 날짜
            checkout = co.getFullYear() + '-'
                     + String(co.getMonth() + 1).padStart(2, '0') + '-'
                     + String(co.getDate()).padStart(2, '0');

            // 한국어 표시용 날짜 라벨
            checkinLabel  = ci.getFullYear() + '년 ' + (ci.getMonth() + 1) + '월 ' + ci.getDate() + '일';
            checkoutLabel = co.getFullYear() + '년 ' + (co.getMonth() + 1) + '월 ' + co.getDate() + '일';
        }

        // 1박 단가 (총액 ÷ 숙박일수)
        var basePrice  = Math.round(price / nights);
        var totalPrice = price;

        // 숨김 input 으로 구성된 form 을 동적으로 생성 후 제출
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = 'hotelreservation.jsp';

        var fields = {
            hotelName    : hotelName,
            roomGrade    : roomGrade,
            roomClass    : roomClass,
            capacity     : capacity,
            basePrice    : basePrice,
            totalPrice   : totalPrice,
            checkin      : checkin,
            checkout     : checkout,
            checkinLabel : checkinLabel,
            checkoutLabel: checkoutLabel,
            nights       : nights,
            rooms        : rooms,
            adults       : adults,
            children     : children
        };

        Object.keys(fields).forEach(function(key) {
            var input   = document.createElement('input');
            input.type  = 'hidden';
            input.name  = key;
            input.value = fields[key];
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
    }

    /* ════════════════════════════════════════════════════════
       라이트박스 (이미지 전체화면 보기)
       ════════════════════════════════════════════════════════ */

    /** 이미지 클릭 시 라이트박스 열기 */
    function openLightbox(src, alt) {
        document.getElementById('lightboxImg').src = src;
        document.getElementById('lightboxImg').alt = alt || '';
        document.getElementById('lightboxOverlay').classList.add('active');
        document.body.style.overflow = 'hidden'; // 배경 스크롤 방지
    }

    /** 라이트박스 닫기 */
    function closeLightbox() {
        document.getElementById('lightboxOverlay').classList.remove('active');
        document.body.style.overflow = '';
    }

    // ESC 키로 라이트박스 닫기
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeLightbox();
    });

    /* ════════════════════════════════════════════════════════
       초기화 (DOMContentLoaded)
       ════════════════════════════════════════════════════════ */
    document.addEventListener('DOMContentLoaded', function() {
        renderHotelList();   // 호텔 목록 렌더링
        initCalendar();      // 달력 초기화
        updateInfoBox();     // 예약 정보 박스 초기값 설정

        // 검색 버튼 클릭 이벤트
        document.getElementById('btnSearch').addEventListener('click', displaySearchResults);

        // 호텔 검색 입력창 엔터 키 이벤트
        document.getElementById('hotelSearchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') searchHotels();
        });
    });