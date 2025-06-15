package com.example.chinachemicalApp.service;


import com.example.chinachemicalApp.dto.LoginRequest;
import com.example.chinachemicalApp.dto.RegistrationRequest;
import com.example.chinachemicalApp.entity.User;
import com.example.chinachemicalApp.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void registerUser(RegistrationRequest request) {
        if(userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("USER");
        userRepository.save(user);
    }


    public boolean authenticateUser(LoginRequest request) {
        String email = request.getEmail();
        String rawPassword = request.getPassword();
        Optional<User> userOpt = userRepository.findByEmail(email);
        if(userOpt.isEmpty()){
            return false;
        }
        User user = userOpt.get();
        return passwordEncoder.matches(rawPassword, user.getPasswordHash());
    }


}
