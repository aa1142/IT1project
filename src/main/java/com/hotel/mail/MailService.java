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

    public void sendReservationCompleteMail(
            String toEmail,
            String bookerName,
            String reservationCode,
            String partnerOrderId,
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
        message.setSubject("[JYP HOTEL] 예약 결제가 완료되었습니다.", "UTF-8");

        String html =
            "<div style='font-family:Arial, sans-serif; padding:24px; color:#222;'>"
          + "  <h2 style='color:#9a772e;'>JYP HOTEL 예약 완료</h2>"
          + "  <p>안녕하세요, <strong>" + escape(bookerName) + "</strong>님.</p>"
          + "  <p>호텔 예약금 결제가 정상적으로 완료되었습니다.</p>"
          + "  <hr>"
          + "  <p><strong>예약번호:</strong> " + escape(reservationCode) + "</p>"
          + "  <p><strong>주문번호:</strong> " + escape(partnerOrderId) + "</p>"
          + "  <p><strong>결제금액:</strong> ¥" + String.format("%,d", amount) + "</p>"
          + "  <hr>"
          + "  <p>예약 조회는 예약번호와 예약자 전화번호로 확인할 수 있습니다.</p>"
          + "  <p style='color:#777;'>JYP HOTEL</p>"
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