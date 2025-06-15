package com.example.chinachemicalApp.entity;


import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
@Data
public class User {


    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @Column(length = 255, nullable = false, unique = true)
    private String email;

    @Column(length = 255, nullable = false, name="password_hash")
    private String passwordHash;

    @Column(name = "created_at", updatable = false, insertable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private String role;


    public User() {

    }
    public User(UUID id) {
        this.id = id;
    }


    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    public UUID getId() {
        return id;
    }
    public String getPasswordHash() {
        return passwordHash;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }


}
