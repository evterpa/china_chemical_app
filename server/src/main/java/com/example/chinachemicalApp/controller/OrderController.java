package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.dto.CheckoutRequest;
import com.example.chinachemicalApp.dto.OrderResponse;
import com.example.chinachemicalApp.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping("/checkout")
    public ResponseEntity<OrderResponse> checkout(@RequestBody CheckoutRequest request) {
        UUID userId = getCurrentUserId();
        OrderResponse response = orderService.checkout(userId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<OrderResponse>> getUserOrders() {
        UUID userId = getCurrentUserId();
        return ResponseEntity.ok(orderService.getOrdersForUser(userId));
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new RuntimeException("User not authenticated");
        }
        return UUID.fromString(authentication.getPrincipal().toString());
    }

}
