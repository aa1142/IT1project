package com.hotel.mail;

import java.util.Properties;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class MailService {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    private static final String MAIL_ID = "rkfqo12@gmail.com";
    private static final String MAIL_APP_PASSWORD = "ijnbbvlnrgwglpgs";

    /**
     * 카카오페이 승인 완료 후 사용자의 이메일로 예약 확정 영수증 메일을 발송합니다.
     */
    public void sendReservationCompleteMail(
            String toEmail,
            String bookerName,
            String reservationCode,
            String partnerOrderId, // KakaoReady에서 bootNo를 바인딩했으므로 실제 bootNo 값이 들어옵니다.
            int amount) throws Exception {

        if (toEmail == null || toEmail.trim().isEmpty()) {
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MAIL_ID, MAIL_APP_PASSWORD);
            }
        });
        
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(MAIL_ID, "JYP HOTEL", "UTF-8"));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        message.setSubject("[JYP HOTEL] 예약(BOOT) 및 결제가 완료되었습니다.", "UTF-8");

        String html =
            "<div style='font-family:Arial, sans-serif; padding:24px; color:#222;'>"
          + "  <h2 style='color:#9a772e;'>JYP HOTEL 예약 완료 안내</h2>"
          + "  <p>안녕하세요, <strong>" + escape(bookerName) + "</strong>님.</p>"
          + "  <p>호텔 객실 예약 및 결제가 정상적으로 완료되었습니다.</p>"
          + "  <hr style='border: 0; border-top: 1px solid #eee; margin: 20px 0;'>"
          + "  <p><strong>예약 식별번호(BOOT_NO):</strong> " + escape(partnerOrderId) + "</p>"
          + "  <p><strong>통신용 고유코드:</strong> " + escape(reservationCode) + "</p>"
          + "  <p><strong>최종 결제금액:</strong> " + String.format("%,d", amount) + "원</p>"
          + "  <hr style='border: 0; border-top: 1px solid #eee; margin: 20px 0;'>"
          + "  <p>예약 내역 조회는 <strong>통신용 고유코드</strong>와 예약 시 입력하신 <strong>전화번호 또는 이메일</strong>로 확인하실 수 있습니다.</p>"
          + "  <p style='color:#777; margin-top:30px;'>JYP HOTEL RESIDENCE</p>"
          + "</div>";

        message.setContent(html, "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
    
    
    
    
    
  //현장결제용 이메일
    public void sendOnsiteConfirmMail(
            String toEmail,
            String bookerName,
            String reservationCode,
            String roomGrade,
            String roomType
            ) throws Exception {

        if (toEmail == null || toEmail.trim().isEmpty()) {
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication("rkfqo12@gmail.com", "ijnbbvlnrgwglpgs");
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress("rkfqo12@gmail.com", "JYP HOTEL", "UTF-8"));
        toEmail="tsk511@naver.com";
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        
        // 제목 변경
        message.setSubject("[JYP HOTEL] 요청하신 객실 예약이 확정되었습니다. (현장결제 건)", "UTF-8");

        // 현장결제 및 방 배정 안내 컨셉의 HTML 템플릿
        String html =
                "<div style='font-family:Arial, sans-serif; padding:24px; color:#222; max-width:600px; border:1px solid #eee;'>"
              + "  <h2 style='color:#9a772e; border-bottom:2px solid #9a772e; padding-bottom:10px;'>【JYP HOTEL】ご予約確定のお知らせ</h2>"
              + "  <p><strong>" + escape(bookerName) + "</strong> 様</p>"
              + "  <p>この度は、JYP HOTELをご利用いただき誠にありがとうございます。</p>"
              + "  <p>お客様よりお申し込みいただきましたオンラインご予約について、担当者の確認および<strong>客室の割り当て</strong>が完了いたしましたのでご案内申し上げます。</p>"
              + "  "
              + "  <div style='background-color:#f8f9fa; padding:15px; border-radius:4px; margin:20px 0;'>"
              + "    <p style='margin:5px 0;'><strong>🏢 予約番号:</strong> " + escape(reservationCode) + "</p>"
              + "    <p style='margin:5px 0;'><strong>🛏️ 客室グレード:</strong> " + escape(roomGrade) + "</p>"
              + "    <p style='margin:5px 0;'><strong>🛋️ 部屋タイプ:</strong> " + escape(roomType) + "</p>"
              + "  </div>"
              + "  "
              + "  <p>本ご予約は<strong>【現地決済】</strong>となります。代金はチェックインの際、フロントデスクにてお支払いください。</p>"
              + "  <p>ご来館の際は、上記の<strong>予約番号</strong>または<strong>通信用固有コード</strong>をフロントにてご提示ください。</p>"
              + "  <hr style='border: 0; border-top: 1px solid #eee; margin: 20px 0;'>"
              + "  <p style='color:#777; font-size:12px;'>※ ご予約의キャンセルや日程のご変更は、ご宿泊日の3日前までにカスタマーセンターまでご連絡をお願いいたします。</p>"
              + "  <p style='color:#9a772e; margin-top:30px; font-weight:bold;'>JYP HOTEL RESIDENCE</p>"
              + "</div>";

        message.setContent(html, "text/html; charset=UTF-8");

        Transport.send(message);
    }
}







