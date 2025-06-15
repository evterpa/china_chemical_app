package com.example.chinachemicalApp.config;


import com.example.chinachemicalApp.util.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    //регистрация энкодера
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    //разрешаеие запросов без токена(отключение защиты csrf )
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthFilter jwtAuthFilter) throws Exception {
        http
                .csrf(csrf->csrf.disable())
                        .authorizeHttpRequests(auth ->auth.requestMatchers("/api/auth/**").permitAll()
                                .requestMatchers("/api/products/**").permitAll()
                                .requestMatchers("/api/categories/**").permitAll()
                                .requestMatchers("/api/send-mail").permitAll()
                                // Swagger разрешенные пути:
                                .requestMatchers(
                                        "/v3/api-docs/**",
                                        "/swagger-ui/**",
                                        "/swagger-ui.html",
                                        "/swagger-resources/**",
                                        "/webjars/**"
                                ).permitAll()
                                .anyRequest().authenticated()
                        )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
