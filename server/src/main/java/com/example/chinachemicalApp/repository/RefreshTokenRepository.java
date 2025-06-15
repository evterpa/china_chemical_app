package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.RefreshToken;
import com.example.chinachemicalApp.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID>{
    Optional<RefreshToken> findByUser(User user);
    Optional<RefreshToken> findByToken(String token);
}
