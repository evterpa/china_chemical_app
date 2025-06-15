package com.example.chinachemicalApp.dto;

import lombok.Data;

/**
 * DTO для оформления заказа. Содержит только адрес доставки,
 * так как товары берутся из корзины пользователя.
 */
@Data
public class CheckoutRequest {
    /**
     * Адрес доставки заказа
     */
    private String deliveryAddress;

    public String getDeliveryAddress() {
        return deliveryAddress;
    }
}
