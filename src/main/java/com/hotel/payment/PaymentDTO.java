package com.hotel.payment;

public class PaymentDTO {
    private int paymentId;          // PK (payment_id)
    private String bootNo;          // [수정] FK (기존 int reservationId를 String bootNo로 변경)
    private String tid;             // 카카오페이 고유 거래번호 (tid)
    private String partnerOrderId;  // 예약 고유코드와 매핑 (partner_order_id)
    private String paymentMethod;   // 결제 수단 (KAKAOPAY 등)
    private int amount;             // 결제 금액 (amount)
    private String paymentStatus;   // 결제 상태 (PAID, CANCELLED 등)
    private String createdAt;

    public PaymentDTO() {}

    // Getter / Setter
    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }

    // [수정] KakaoApproveServlet의 빨간 줄을 없애주는 핵심 메서드 세트
    public String getBootNo() { return bootNo; }
    public void setBootNo(String bootNo) { this.bootNo = bootNo; }

    public String getTid() { return tid; }
    public void setTid(String tid) { this.tid = tid; }

    public String getPartnerOrderId() { return partnerOrderId; }
    public void setPartnerOrderId(String partnerOrderId) { this.partnerOrderId = partnerOrderId; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}