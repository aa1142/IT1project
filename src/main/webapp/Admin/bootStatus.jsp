<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
            padding: 8px 4px;
            font-size: 0.9rem;
        }
        .calendar-active {
            background-color: #0f172a;
            color: #fff;
            border-radius: 50%;
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
    </style>



    <div class="container py-4">
        
        <h6 class="fw-bold mb-3 text-secondary">오늘현황</h6>
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card card-custom p-3">
                    <div class="text-summary-title">오늘 체크인</div>
                    <div class="text-summary-value">5실</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom p-3">
                    <div class="text-summary-title">오늘 체크아웃</div>
                    <div class="text-summary-value">5실</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom p-3">
                    <div class="text-summary-title">오늘 예약</div>
                    <div class="text-summary-value">7실</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-custom p-3">
                    <div class="text-summary-title text-danger">오늘 특이</div>
                    <div class="text-summary-value text-danger">1건</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card card-custom p-3 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <button class="btn btn-sm btn-light">&lt;</button>
                        <span class="fw-bold">2024년 5월</span>
                        <button class="btn btn-sm btn-light">&gt;</button>
                    </div>
                    <table class="table table-borderless calendar-table">
                        <thead>
                            <tr class="text-muted">
                                <th class="text-danger">일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th class="text-primary">토</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td></td><td></td><td></td><td>1</td><td>2</td><td>3</td><td>4</td>
                            </tr>
                            <tr>
                                <td class="text-danger">5</td><td>6</td><td>7</td><td>8</td><td>9</td><td>10</td><td>11</td>
                            </tr>
                            <tr>
                                <td class="text-danger">12</td><td>13</td><td>14</td><td>15</td><td>16</td><td>17</td><td>18</td>
                            </tr>
                            <tr>
                                <td class="text-danger">19</td><td class="calendar-active">19</td><td>21</td><td>22</td><td>23</td><td>24</td><td>25</td>
                            </tr>
                            <tr>
                                <td class="text-danger">26</td><td>27</td><td>28</td><td>29</td><td>30</td><td></td><td></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="col-md-8">
                <div class="card card-custom p-4 h-100">
                    <h6 class="fw-bold mb-3">예약 현황 목록 <span class="text-muted fs-7 fw-normal">(2024-05-10)</span></h6>
                    <div class="table-responsive">
                        <table class="table table-custom align-middle">
                            <thead>
                                <tr>
                                    <th>시간</th><th>이름</th><th>예약번호</th><th>객실</th><th>객실종류</th><th>투숙</th><th>상태</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>16:00</td><td>최민현</td><td>K345010-0001</td><td>디럭스</td><td>스탠다드</td><td>2명</td>
                                    <td><span class="badge bg-primary-subtle text-primary rounded-pill px-3 py-2">체크인 가능</span></td>
                                </tr>
                                <tr>
                                    <td>18:00</td><td>서리연</td><td>K345010-0002</td><td>디럭스</td><td>디럭스</td><td>2명</td>
                                    <td><span class="badge bg-warning-subtle text-warning rounded-pill px-3 py-2">체크아웃 진행</span></td>
                                </tr>
                                <tr>
                                    <td>12:00</td><td>박민주</td><td>K342010-0003</td><td>화석견</td><td>스탠다드</td><td>2명</td>
                                    <td><span class="badge bg-success-subtle text-success rounded-pill px-3 py-2">제3금융 제공</span></td>
                                </tr>
                                <tr>
                                    <td>16:00</td><td>제미</td><td>K345010-0005</td><td>다강선</td><td>스탠다드</td><td>2명</td>
                                    <td><span class="badge bg-danger-subtle text-danger rounded-pill px-3 py-2">세차 방문</span></td>
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
            <div class="col-md-4">
                <div class="card card-custom p-4">
                    <div class="d-flex align-items-center mb-3">
                        <span class="p-2 bg-primary rounded-circle me-2"></span>
                        <h6 class="fw-bold mb-0">스탠다드</h6>
                    </div>
                    <div class="mb-2">
                        <label class="form-label text-muted small mb-1">1박 가격</label>
                        <input type="text" class="form-control" value="120,000 원">
                    </div>
                    <button class="btn btn-success w-100 btn-save">저장</button>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom p-4">
                    <div class="d-flex align-items-center mb-3">
                        <span class="p-2 bg-success rounded-circle me-2"></span>
                        <h6 class="fw-bold mb-0">디럭스</h6>
                    </div>
                    <div class="mb-2">
                        <label class="form-label text-muted small mb-1">1박 가격</label>
                        <input type="text" class="form-control" value="180,000 원">
                    </div>
                    <button class="btn btn-success w-100 btn-save">저장</button>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom p-4">
                    <div class="d-flex align-items-center mb-3">
                        <span class="p-2 bg-warning rounded-circle me-2"></span>
                        <h6 class="fw-bold mb-0">스위트</h6>
                    </div>
                    <div class="mb-2">
                        <label class="form-label text-muted small mb-1">1박 가격</label>
                        <input type="text" class="form-control" value="350,000 원">
                    </div>
                    <button class="btn btn-success w-100 btn-save">저장</button>
                </div>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // 저장 버튼 클릭 시 작동 예시
            $(".btn-save").click(function() {
                alert("가격 정보가 성공적으로 반영되었습니다!");
            });
        });
    </script>



<%@ include file="/adminTem/footTem.jsp" %>