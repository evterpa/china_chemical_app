package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.entity.User;
import com.example.chinachemicalApp.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
@RequestMapping("/api")

public class MeController {

    private final UserRepository userRepository;

    MeController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public UserInfo me() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new RuntimeException("User not authenticated");
        }

        // В твоём JwtAuthFilter principal — это UUID пользователя (user.getId())
        String userIdStr = authentication.getPrincipal().toString();

        User user = userRepository.findById(java.util.UUID.fromString(userIdStr))
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new UserInfo(user.getEmail(), user.getCreatedAt());
    }

    @Data
    private static class UserInfo {
        private String email;
        private Instant createdAt;

        public UserInfo(String email, Instant createdAt) {
            this.email = email;
            this.createdAt = createdAt;
        }

        public String getEmail() {
            return email;
        }
        public Instant getCreatedAt() {
            return createdAt;
        }
    }


}
