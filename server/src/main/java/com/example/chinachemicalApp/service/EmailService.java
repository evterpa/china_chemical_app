package com.example.chinachemicalApp.service;

import com.example.chinachemicalApp.config.MailProperties;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private final MailProperties mailProperties;

    public EmailService(JavaMailSender mailSender, MailProperties mailProperties) {
        this.mailSender = mailSender;
        this.mailProperties = mailProperties;
    }

    public void sendMail(String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailProperties.getSender());        // отправитель из application.properties
        message.setTo(mailProperties.getRecipient());       // получатель из application.properties
        message.setSubject(subject);
        message.setText(body);

        mailSender.send(message);
    }

    // добавь геттеры, если нужно
    public String getRecipient() {
        return mailProperties.getRecipient();
    }
}
