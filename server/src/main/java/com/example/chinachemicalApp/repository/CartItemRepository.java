package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, UUID> {

    List<CartItem> findByCartId(UUID cartId);
    void deleteAllByCartId(UUID cartId);
}
