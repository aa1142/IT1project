<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="modal fade" id="customerMemoModal" tabindex="-1" aria-labelledby="customerMemoModalLabel" aria-hidden="true">
   <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow-lg">
         
         <div class="modal-header text-white" style="background-color: #2c3e50;">
            <h5 class="modal-title fw-bold" id="customerMemoModalLabel">顧客メモ管理</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
         </div>

         <form id="memoForm" onsubmit="return false;">
            <div class="modal-body bg-light p-4">
               
               <div class="p-3 bg-white rounded shadow-sm mb-3 border-start border-secondary border-4">
                  <div class="d-flex justify-content-between">
                     <span class="text-muted small">顧客名: <strong id="memoModalGuestName" class="text-dark">-</strong></span>
                     <span class="text-muted small">連絡先: <strong id="memoModalPhone" class="text-dark">-</strong></span>
                  </div>
               </div>

               <div class="card border-0 shadow-sm p-3 bg-white mb-3">
                  <label class="form-label fw-bold text-secondary small mb-2">管理者入力メモ</label>
                  <textarea id="newMemoText" name="memoContent" class="form-control mb-2" rows="3" placeholder="顧客応対内容や管理記録を入力してください。"></textarea>
                  <div class="text-end">
                     <input type="button" class="btn btn-sm btn-primary px-3 fw-bold" onclick="saveCustomerMemo()" value="メモ登録">
                  </div>
               </div>

               <h6 class="fw-bold text-dark mb-2 small">登録済みのメモ履歴</h6>
               <div id="memoHistoryList" class="d-flex flex-column gap-2" style="max-height: 200px; overflow-y: auto;">
                  <div class="text-center text-muted py-3 small" id="noMemoText">登録されたメモがありません。</div>
               </div>
            </div>

            <div class="modal-footer bg-light">
               <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">閉じる</button>
            </div>
         </form>

      </div>
   </div>
</div>

<script>
    // 전역 변수로 부트스트랩 모달 객체를 담아 중복 생성을 방지합니다.
    let memoBootstrapModal = null;

    // 🎯 1. 메인 페이지의 연락처 클릭 시 호출되는 함수
    function openMemoModal(bootName, bootPhone) {
        // 상단 정보 바인딩
        document.getElementById('memoModalGuestName').innerText = bootName;
        document.getElementById('memoModalPhone').innerText = bootPhone;
        
        // 폼 초기화
        document.getElementById('newMemoText').value = "";
        
        // 기존 메모 내역 가져오기 실행
        loadMemoHistory(bootPhone);
        
        // 모달 띄우기 (없으면 새로 생성, 있으면 기존 객체 활용)
        if (!memoBootstrapModal) {
            memoBootstrapModal = new bootstrap.Modal(document.getElementById('customerMemoModal'));
        }
        memoBootstrapModal.show();
    }

    // 🎯 2. 특정 고객의 기존 메모 내역을 비동기로 긁어오는 함수
    function loadMemoHistory(phone) {
        $.ajax({
            url: '${pageContext.request.contextPath}/admin/getMemoList.do',
            type: 'GET',
            data: { memoPhone: phone },
            dataType: 'json',
            success: function(res) {
                const listContainer = $('#memoHistoryList');
                listContainer.empty(); // 이전 데이터 청소
                
                if (res && res.length > 0) {
                    res.forEach(memo => {
                        // DB에서 꺼내온 데이터를 바탕으로 깔끔한 쪽지 형태의 HTML 동적 생성
                        let memoBox = `
                            <div class="p-2 bg-white rounded shadow-sm border border-light-subtle">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="fw-bold text-secondary small">✍️ \${memo.adminName || '管理者'}</span>
                                    <span class="text-muted" style="font-size: 11px;">\${memo.memoDate}</span>
                                </div>
                                <p class="mb-0 text-dark small" style="word-break: break-all; white-space: pre-wrap;">\${memo.memoContent}</p>
                            </div>
                        `;
                        listContainer.append(memoBox);
                    });
                } else {
                    listContainer.append('<div class="text-center text-muted py-3 small" id="noMemoText">登録されたメモがありません。</div>');
                }
            },
            error: function() {
                console.log("メモ履歴の読み込みに失敗しました。");
            }
        });
    }

    // 🎯 3. 새 메모를 등록하는 함수
    function saveCustomerMemo() {
        const phone = document.getElementById('memoModalPhone').innerText;
        const name = document.getElementById('memoModalGuestName').innerText;
        const content = document.getElementById('newMemoText').value;

        if (!content || content.trim() === "") {
            alert("メモ内容を入力してください。");
            document.getElementById('newMemoText').focus();
            return;
        }

        // 서버로 메모 추가 요청 전송
        $.ajax({
            url: '${pageContext.request.contextPath}/admin/insertMemo.do',
            type: 'POST',
            data: {
                memoPhone: phone,
                memoName: name,
                memoContent: content
            },
            dataType: 'json',
            success: function(res) {
                if (res.status === "success") {
                    alert("メモ가 정상적으로 등록되었습니다.");
                    document.getElementById('newMemoText').value = ""; // 입력창 비우기
                    loadMemoHistory(phone); // 등록 성공 후 리스트 즉시 갱신!
                } else {
                    alert("メモの登録に失敗しました: " + res.message);
                }
            },
            error: function() {
                alert("サーバーとの通信中にエラーが発生しました。");
            }
        });
    }
</script>