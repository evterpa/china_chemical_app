package com.example.chinachemicalApp.controller;


import com.example.chinachemicalApp.dto.LoginRequest;
import com.example.chinachemicalApp.dto.LoginResponse;
import com.example.chinachemicalApp.dto.RefreshTokenRequest;
import com.example.chinachemicalApp.dto.RegistrationRequest;
import com.example.chinachemicalApp.entity.User;
import com.example.chinachemicalApp.repository.UserRepository;
import com.example.chinachemicalApp.service.AuthService;
import com.example.chinachemicalApp.service.TokenService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    private final UserRepository userRepository;
    private final TokenService tokenService;

    public AuthController(AuthService authService, UserRepository userRepository, TokenService tokenService) {
        this.authService = authService;
        this.userRepository = userRepository;
        this.tokenService = tokenService;
    }

    @PostMapping("/registration")
    public ResponseEntity<String> register(@RequestBody RegistrationRequest request) {
        try{
            authService.registerUser(request);
            return ResponseEntity.ok("User registered successfully");
        }catch (IllegalArgumentException e){
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try{
            authService.authenticateUser(request);
        }catch (IllegalArgumentException e){
            return ResponseEntity.badRequest().body(e.getMessage());
        }
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if(userOpt.isEmpty()){
            return ResponseEntity.status(404).body("User not found");
        }
        UUID userId = userOpt.get().getId();
        String refreshToken = tokenService.generateRefreshToken(userId);
        String accessToken = tokenService.generateAccessToken(refreshToken);

        LoginResponse response = new LoginResponse(accessToken, refreshToken);

        return ResponseEntity.ok(response);
    }



    @PostMapping("/refresh")

    public ResponseEntity<?> refreshAcessToken(@RequestBody RefreshTokenRequest request){
        String refreshToken = request.getRefreshToken();
        if(!tokenService.validateRefreshToken(refreshToken)){
            return ResponseEntity.badRequest().body("Invalid refresh token");
        }
        try {
            String newAccessToken = tokenService.generateAccessToken(request.getRefreshToken());
            return ResponseEntity.ok(Map.of("acessToken", newAccessToken));
        }catch (RuntimeException e){
            return ResponseEntity.badRequest().body("failed to refresh access token");
        }
    }

}
