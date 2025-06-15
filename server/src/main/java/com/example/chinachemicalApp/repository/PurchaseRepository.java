package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.Purchase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PurchaseRepository extends JpaRepository<Purchase, UUID> {
    List<Purchase> findByUserId(UUID userId);
}
