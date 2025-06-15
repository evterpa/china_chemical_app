package com.example.chinachemicalApp.service;

import com.example.chinachemicalApp.entity.Cart;
import com.example.chinachemicalApp.entity.CartItem;
import com.example.chinachemicalApp.entity.Purchase;
import com.example.chinachemicalApp.entity.PurchaseItem;
import com.example.chinachemicalApp.repository.CartRepository;
import com.example.chinachemicalApp.repository.PurchaseRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;
    private final CartRepository cartRepository;
    private final CartService cartService;

    public PurchaseService(PurchaseRepository purchaseRepository, CartRepository cartRepository, CartService cartService) {
        this.purchaseRepository = purchaseRepository;
        this.cartRepository = cartRepository;
        this.cartService = cartService;
    }

    public Purchase createPurchaseFromCart(UUID userId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));

        Purchase purchase = new Purchase();
        purchase.setUserId(userId);

        List<PurchaseItem> purchaseItems = new ArrayList<>();
        for (CartItem cartItem : cart.getItems()) {
            PurchaseItem purchaseItem = new PurchaseItem();
            purchaseItem.setPurchase(purchase);
            purchaseItem.setProduct(cartItem.getProduct());
            purchaseItem.setQuantity(cartItem.getQuantity());
            purchaseItems.add(purchaseItem);
        }

        purchase.setItems(purchaseItems);
        Purchase savedPurchase = purchaseRepository.save(purchase);
        cartService.clearCart(userId);
        return savedPurchase;
    }

    public List<Purchase> getAllPurchases() {
        return purchaseRepository.findAll();
    }

    public List<Purchase> getPurchasesByUserId(UUID userId) {
        return purchaseRepository.findByUserId(userId);
    }
}
