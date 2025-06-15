package com.example.chinachemicalApp.util;


import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

///access tokens
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secretKeyStr;

    private SecretKey getKey(){
        return Keys.hmacShaKeyFor(secretKeyStr.getBytes(StandardCharsets.UTF_8));
    }

    public boolean isTokenValid(String token){
        try{
            Jwts.parserBuilder().setSigningKey(getKey()).build().parseClaimsJws(token);
            return true;
        }catch(Exception e){
            return false;
        }
    }

    public String exctractUserId(String token){
        return Jwts.parserBuilder()
                .setSigningKey(getKey())
                .build().parseClaimsJws(token).getBody().getSubject();
    }

}
