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
}