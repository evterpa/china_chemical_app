package com.example.chinachemicalApp.dto;

import java.util.UUID;

public class UpdateCartRequest {
    private UUID productId;
    private int quantity;

    // геттеры и сеттеры
    public UUID getProductId() {
        return productId;
    }
    public void setProductId(UUID productId) {
        this.productId = productId;
    }
    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
