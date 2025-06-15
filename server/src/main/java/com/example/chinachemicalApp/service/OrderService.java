package com.example.chinachemicalApp.service;

import com.example.chinachemicalApp.dto.CheckoutRequest;
import com.example.chinachemicalApp.dto.OrderItemResponse;
import com.example.chinachemicalApp.dto.OrderResponse;
import com.example.chinachemicalApp.entity.*;
import com.example.chinachemicalApp.repository.CartRepository;
import com.example.chinachemicalApp.repository.OrderItemRepository;
import com.example.chinachemicalApp.repository.OrderRepository;
import com.example.chinachemicalApp.repository.ProductRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    @Autowired
    private CartService cartService;
    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private OrderRepository orderRepository;
    @Autowired
    private OrderItemRepository orderItemRepository;
    @Autowired
    private CartRepository cartRepository;
    @Transactional
    public OrderResponse checkout(UUID userId, CheckoutRequest request) {
        Cart cart = cartService.getUserCart(userId);
        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }

        Order order = new Order();
        // UUID генерировать вручную не обязательно, если настроена генерация @GeneratedValue
        //order.setId(UUID.randomUUID());  // можно убрать

        order.setUserId(userId);
        order.setStatus("PENDING");
        order.setCreatedAt(LocalDateTime.now());
        order.setDeliveryAddress(request.getDeliveryAddress());

        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();

        for (CartItem cartItem : cart.getItems()) {
            Product product = cartItem.getProduct();
            int quantity = cartItem.getQuantity();

            if (product.getStockQuantity() < quantity) {
                throw new RuntimeException("Insufficient stock for " + product.getName());
            }

            product.setStockQuantity(product.getStockQuantity() - quantity);
            productRepository.save(product);

            OrderItem orderItem = new OrderItem();
            //orderItem.setId(UUID.randomUUID()); // тоже не обязательно
            orderItem.setOrder(order);  // очень важно!
            orderItem.setProduct(product);
            orderItem.setQuantity(quantity);
            orderItem.setPrice(product.getPrice());
            orderItems.add(orderItem);

            total = total.add(product.getPrice().multiply(BigDecimal.valueOf(quantity)));
        }

        order.setTotal(total);
        order.setItems(orderItems);  // важно!

        orderRepository.save(order); // сохраняем Order с каскадом OrderItems

        cart.getItems().clear();
        cartRepository.save(cart);

        return toResponse(order, orderItems);
    }



    public List<OrderResponse> getOrdersForUser(UUID userId) {
        List<Order> orders = orderRepository.findByUserId(userId);
        return orders.stream()
                .map(order -> toResponse(order, order.getItems()))
                .collect(Collectors.toList());
    }

    private OrderResponse toResponse(Order order, List<OrderItem> items) {
        OrderResponse response = new OrderResponse();
        response.setOrderId(order.getId());
        response.setTotal(order.getTotal());
        response.setStatus(order.getStatus());

        List<OrderItemResponse> itemResponses = items.stream().map(item -> {
            OrderItemResponse r = new OrderItemResponse();
            r.setProductId(item.getProduct().getId());
            r.setProductName(item.getProduct().getName());
            r.setQuantity(item.getQuantity());
            r.setPrice(item.getPrice());
            return r;
        }).collect(Collectors.toList());

        response.setItems(itemResponses);
        return response;
    }
}
