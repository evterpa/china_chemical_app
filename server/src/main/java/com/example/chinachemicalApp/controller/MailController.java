package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.service.EmailService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class MailController {

    private final EmailService emailService;

    public MailController(EmailService emailService) {
        this.emailService = emailService;
    }

    // DTO класс для данных письма
    public static class MailRequest {
        private String subject;
        private String text;

        // Геттеры и сеттеры
        public String getSubject() {
            return subject;
        }
        public void setSubject(String subject) {
            this.subject = subject;
        }
        public String getText() {
            return text;
        }
        public void setText(String text) {
            this.text = text;
        }
    }

    @PostMapping("/send-mail")
    public ResponseEntity<String> sendMail(@RequestBody MailRequest mailRequest) {
        try {
            emailService.sendMail(mailRequest.getSubject(), mailRequest.getText());
            return ResponseEntity.ok("Письмо отправлено успешно");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Ошибка при отправке письма: " + e.getMessage());
        }
    }
}
