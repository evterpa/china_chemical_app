package com.example.chinachemicalApp.service;


import com.example.chinachemicalApp.entity.RefreshToken;
import com.example.chinachemicalApp.entity.User;
import com.example.chinachemicalApp.repository.RefreshTokenRepository;
import com.example.chinachemicalApp.repository.UserRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.sql.Ref;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class TokenService {

    @Value("${jwt.secret}")
    private String secretKeyStr;

    private final  long refreshTokenValidityMs = 7*24*60*60*1000;//секунды
    private final long accessTokenValidityMs = 60*15;//секунды

    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;

    public TokenService(RefreshTokenRepository refreshTokenRepository, UserRepository userRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
        this.userRepository = userRepository;
    }

    public String generateRefreshToken(UUID userId) {
        Instant now = Instant.now();
        Instant expiryDate = now.plusSeconds(refreshTokenValidityMs);
        System.out.println("Secret length: " + secretKeyStr.length()); // должен быть ≥ 32

        SecretKey secretKey = Keys.hmacShaKeyFor(secretKeyStr.getBytes(StandardCharsets.UTF_8));
        System.out.println("Secret byte key: " + secretKey.toString()+ "LEN: " + secretKey.getEncoded().length);
        String token = Jwts.builder().setSubject(userId.toString())  //связка с юзером
                .setIssuedAt(Date.from(now))                 //время создания
                .setExpiration(Date.from(expiryDate))        //время истечения
                .claim("type","refresh")               //для удобства
                .signWith(secretKey)                         // подпись
                .compact();

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(token);
        refreshToken.setExpiryDate(expiryDate);

        refreshTokenRepository.save(refreshToken);
        return token;
    }

    public boolean validateRefreshToken(String token) {
        RefreshToken refToken= refreshTokenRepository.findByToken(token)
                .orElseThrow(()->new RuntimeException("Token not found"));

        if(refToken.getExpiryDate().isBefore(Instant.now())){
            return false;
        }
        return true;
    }


    public String generateAccessToken(String refreshToken) {
        RefreshToken refToken = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(()->new RuntimeException("Token not found"));


        if(Date.from(refToken.getExpiryDate()).before(new Date())){
            throw new RuntimeException("Token is expired");
        };
        User user = refToken.getUser();

        return generateAccessToken(user);
    }

    public String generateAccessToken(User user) {
        Date now = Date.from(Instant.now());
        Date expiryDate = Date.from(Instant.now().plusSeconds(accessTokenValidityMs));
        SecretKey secretKey = Keys.hmacShaKeyFor(secretKeyStr.getBytes(StandardCharsets.UTF_8));
        return Jwts.builder()
                .setSubject(user.getId().toString())
                .claim("email", user.getEmail())
                .claim("role", user.getRole())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(secretKey)
                .compact();
    }


}
