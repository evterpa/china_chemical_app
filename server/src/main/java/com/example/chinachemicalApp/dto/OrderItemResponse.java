package com.example.chinachemicalApp.dto;

import java.math.BigDecimal;
import java.util.UUID;

public class OrderItemResponse {
    private UUID productId;
    private String productName;
    private int quantity;
    private BigDecimal price;

    public UUID getProductId() {
        return productId;
    }
    public void setProductId(UUID productId) {
        this.productId = productId;
    }
    public String getProductName() {
        return productName;
    }
    public void setProductName(String productName) {
        this.productName = productName;
    }
    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    public BigDecimal getPrice() {
        return price;
    }
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
}