package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.entity.Purchase;
import com.example.chinachemicalApp.service.PurchaseService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/purchases")
public class PurchaseController {

    private final PurchaseService purchaseService;

    public PurchaseController(PurchaseService purchaseService) {
        this.purchaseService = purchaseService;
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new RuntimeException("User not authenticated");
        }
        return UUID.fromString(authentication.getPrincipal().toString());
    }

    @GetMapping
    public List<Purchase> getAllPurchases() {
        return purchaseService.getAllPurchases();
    }

    @GetMapping("/my")
    public List<Purchase> getMyPurchases() {
        UUID userId = getCurrentUserId();
        return purchaseService.getPurchasesByUserId(userId);
    }

    @PostMapping("/create-from-cart")
    public Purchase createPurchaseFromCart() {
        UUID userId = getCurrentUserId();
        return purchaseService.createPurchaseFromCart(userId);
    }
}
