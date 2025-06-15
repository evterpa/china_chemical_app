package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.PurchaseItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PurchaseItemRepository extends JpaRepository<PurchaseItem, UUID> {
    // если нужно — допиши методы
}
