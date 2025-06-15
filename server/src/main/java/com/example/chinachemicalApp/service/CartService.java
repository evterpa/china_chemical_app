package com.example.chinachemicalApp.service;

import com.example.chinachemicalApp.entity.Cart;
import com.example.chinachemicalApp.entity.CartItem;
import com.example.chinachemicalApp.entity.Product;
import com.example.chinachemicalApp.repository.CartItemRepository;
import com.example.chinachemicalApp.repository.CartRepository;
import com.example.chinachemicalApp.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class CartService {

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private ProductRepository productRepository;

    public Cart getUserCart(UUID userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart newCart = new Cart();
                    newCart.setUserId(userId);
                    return cartRepository.save(newCart);
                });
    }

    public void decreaseProductQuantity(UUID userId, UUID productId, int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity to decrease must be greater than zero");
        }

        Cart cart = getUserCart(userId);
        Optional<CartItem> itemOpt = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(productId))
                .findFirst();

        if (itemOpt.isPresent()) {
            CartItem item = itemOpt.get();
            int currentQuantity = item.getQuantity();
            int newQuantity = currentQuantity - quantity;

            if (newQuantity > 0) {
                item.setQuantity(newQuantity);
                cartItemRepository.save(item);
            } else {
                cart.getItems().remove(item);
                cartItemRepository.delete(item);
            }
            cartRepository.save(cart);
        } else {
            throw new RuntimeException("Product not found in cart");
        }
    }
    public Cart addProductToCart(UUID userId, UUID productId, int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Cart cart = getUserCart(userId);

        Optional<CartItem> existingItemOpt = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(productId))
                .findFirst();

        int totalQuantity = quantity;
        if (existingItemOpt.isPresent()) {
            totalQuantity += existingItemOpt.get().getQuantity();
        }

        if (product.getStockQuantity() < totalQuantity) {
            throw new RuntimeException("Not enough stock available");
        }

        if (existingItemOpt.isPresent()) {
            CartItem existingItem = existingItemOpt.get();
            existingItem.setQuantity(totalQuantity);
            cartItemRepository.save(existingItem);
        } else {
            CartItem newItem = new CartItem();
            newItem.setCart(cart);
            newItem.setProduct(product);
            newItem.setQuantity(quantity);
            cartItemRepository.save(newItem);
            cart.getItems().add(newItem);
        }

        return cartRepository.save(cart);
    }

    public void removeProductFromCart(UUID userId, UUID productId) {
        Cart cart = getUserCart(userId);
        Optional<CartItem> itemOpt = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(productId))
                .findFirst();

        if (itemOpt.isPresent()) {
            CartItem item = itemOpt.get();
            cart.getItems().remove(item);
            cartItemRepository.delete(item);
            cartRepository.save(cart);
        }
    }

    public void updateQuantity(UUID userId, UUID productId, int newQuantity) {
        if (newQuantity < 0) {
            throw new IllegalArgumentException("Quantity cannot be negative");
        }
        if (newQuantity == 0) {
            removeProductFromCart(userId, productId);
            return;
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        if (product.getStockQuantity() < newQuantity) {
            throw new RuntimeException("Not enough stock available");
        }

        Cart cart = getUserCart(userId);
        Optional<CartItem> itemOpt = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(productId))
                .findFirst();

        if (itemOpt.isPresent()) {
            CartItem item = itemOpt.get();
            item.setQuantity(newQuantity);
            cartItemRepository.save(item);
            cartRepository.save(cart);
        } else {
            throw new RuntimeException("Product not found in cart");
        }
    }

    public List<CartItem> getCartItems(UUID userId) {
        return getUserCart(userId).getItems();
    }

    public void clearCart(UUID userId) {
        Cart cart = getUserCart(userId);
        cartItemRepository.deleteAll(cart.getItems());
        cart.getItems().clear();
        cartRepository.save(cart);
    }
}
