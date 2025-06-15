package com.example.chinachemicalApp.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class DecreaseToCartRequest {
    private UUID productId;
    private int quantity;

    public UUID getProductId() {
        return productId;
    }
    public int getQuantity() {
        return quantity;
    }
}
