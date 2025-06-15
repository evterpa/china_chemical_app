package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.entity.CartItem;
import com.example.chinachemicalApp.service.CartService;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import lombok.Data;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/payment")
public class StripePaymentController {

    private final CartService cartService;

    public StripePaymentController(CartService cartService) {
        this.cartService = cartService;
    }

    @PostMapping(value = "/create", produces = MediaType.APPLICATION_JSON_VALUE)
    public PaymentLinkResponse createPaymentLink() throws StripeException {
        UUID userId = getCurrentUserId();
        List<CartItem> cartItems = cartService.getCartItems(userId);

        if (cartItems.isEmpty()) {
            throw new RuntimeException("Корзина пуста");
        }

        final BigDecimal EXCHANGE_RATE = BigDecimal.valueOf(79); // курс рубль -> доллар

        SessionCreateParams.Builder paramsBuilder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl("https://example.com/success")
                .setCancelUrl("https://example.com/cancel");

        for (CartItem item : cartItems) {
            BigDecimal priceRub = item.getProduct().getPrice();
            // Перевод в доллары с округлением до 2 знаков
            BigDecimal priceUsd = priceRub.divide(EXCHANGE_RATE, 2, BigDecimal.ROUND_HALF_UP);

            long unitAmount = priceUsd.multiply(BigDecimal.valueOf(100)).longValueExact();

            paramsBuilder.addLineItem(
                    SessionCreateParams.LineItem.builder()
                            .setQuantity((long) item.getQuantity())
                            .setPriceData(
                                    SessionCreateParams.LineItem.PriceData.builder()
                                            .setCurrency("usd")
                                            .setUnitAmount(unitAmount)
                                            .setProductData(
                                                    SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                            .setName(item.getProduct().getName())
                                                            .build()
                                            )
                                            .build()
                            )
                            .build()
            );
        }

        Session session = Session.create(paramsBuilder.build());

        return new PaymentLinkResponse(session.getUrl());
    }

    private UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getPrincipal() == null) {
            throw new RuntimeException("User not authenticated");
        }
        return UUID.fromString(authentication.getPrincipal().toString());
    }

    public static class PaymentLinkResponse {
        private final String url;

        public PaymentLinkResponse(String url) {
            this.url = url;
        }

        public String getUrl() {
            return url;
        }
    }

}
