package com.example.chinachemicalApp.util;

import com.example.chinachemicalApp.entity.User;
import com.example.chinachemicalApp.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    public JwtAuthFilter(JwtUtil jwtUtil, UserRepository userRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        if(jwtUtil.isTokenValid(token)) {
            String userId = jwtUtil.exctractUserId(token);
            UUID uuid = UUID.fromString(userId);

            User user = userRepository.findById(uuid)
                    .orElseThrow(()->new RuntimeException("User Not Found"));

            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    user.getId(), null, List.of(new SimpleGrantedAuthority("ROLE_"+user.getRole()))
            );

            SecurityContextHolder.getContext().setAuthentication(authToken);
        }

        System.out.println("TOKEN: " + token);
        System.out.println("VALID: " + jwtUtil.isTokenValid(token));
        System.out.println("USER_ID: " + jwtUtil.exctractUserId(token));

        filterChain.doFilter(request, response);
    }


    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        return path.startsWith("/api/auth/");
    }

}
