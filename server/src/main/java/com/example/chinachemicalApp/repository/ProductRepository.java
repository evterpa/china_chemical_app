package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.Category;
import com.example.chinachemicalApp.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {
    Page<Product> findByNameContainingIgnoreCase(String namePart, Pageable pageable);

    Page<Product> findByCategory(Category category, Pageable pageable);



}
