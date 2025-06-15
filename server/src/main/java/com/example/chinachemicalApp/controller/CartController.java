package com.example.chinachemicalApp.controller;


import com.example.chinachemicalApp.dto.AddToCartRequest;
import com.example.chinachemicalApp.dto.DecreaseToCartRequest;
import com.example.chinachemicalApp.dto.UpdateCartRequest;
import com.example.chinachemicalApp.entity.CartItem;
import com.example.chinachemicalApp.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    // Добавить товар в корзину
    @PostMapping("/add")
    public ResponseEntity<String> addToCart(@RequestBody AddToCartRequest request) {
        UUID userId = getCurrentUserId();

        cartService.addProductToCart(userId, request.getProductId(), request.getQuantity());
        return ResponseEntity.ok("Product added to cart");
    }


    @PostMapping("/decrease")
    public ResponseEntity<String> decreaseCartItemQuantity(@RequestBody DecreaseToCartRequest request) {
        UUID userId = getCurrentUserId();
        cartService.decreaseProductQuantity(userId, request.getProductId(), request.getQuantity());
        return ResponseEntity.ok("Product decreased from cart");
    }
    // Получить содержимое корзины
    @GetMapping
    public ResponseEntity<List<CartItem>> getCartItems() {
        UUID userId = getCurrentUserId();

        List<CartItem> cartItems = cartService.getCartItems(userId);
        return ResponseEntity.ok(cartItems);
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new RuntimeException("User not authenticated");
        }
        return UUID.fromString(authentication.getPrincipal().toString());
    }


    // Удалить товар из корзины
    @DeleteMapping("/remove")
    public ResponseEntity<String> removeFromCart(@RequestParam UUID productId) {
        UUID userId = getCurrentUserId();
        cartService.removeProductFromCart(userId, productId);
        return ResponseEntity.ok("Product removed from cart");
    }

    // Обновить количество товара в корзине
    @PutMapping("/update")
    public ResponseEntity<String> updateCartItem(@RequestBody UpdateCartRequest request) {
        UUID userId = getCurrentUserId();
        cartService.updateQuantity(userId, request.getProductId(), request.getQuantity());
        return ResponseEntity.ok("Cart updated");
    }

    // Очистить корзину
    @DeleteMapping("/clear")
    public ResponseEntity<String> clearCart() {
        UUID userId = getCurrentUserId();
        cartService.clearCart(userId);
        return ResponseEntity.ok("Cart cleared");
    }


}
