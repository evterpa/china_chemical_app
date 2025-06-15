package com.example.chinachemicalApp.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public class OrderResponse {
    private UUID orderId;
    private BigDecimal total;
    private String status;
    private List<OrderItemResponse> items;

    public UUID getOrderId() {
        return orderId;
    }
    public void setOrderId(UUID orderId) {
        this.orderId = orderId;
    }
    public BigDecimal getTotal() {
        return total;
    }
    public void setTotal(BigDecimal total) {
        this.total = total;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public List<OrderItemResponse> getItems() {
        return items;
    }
    public void setItems(List<OrderItemResponse> items) {
        this.items = items;
    }

}
