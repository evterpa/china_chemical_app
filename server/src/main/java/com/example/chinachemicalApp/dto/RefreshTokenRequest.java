package com.example.chinachemicalApp.dto;


import lombok.Data;

@Data
public class RefreshTokenRequest {

    private String refreshToken;

    public RefreshTokenRequest() {

    }

    public RefreshTokenRequest(String refreshToken) {
        this.refreshToken = refreshToken;
    }


    public String getRefreshToken() {
        return refreshToken;
    }
    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }


}
