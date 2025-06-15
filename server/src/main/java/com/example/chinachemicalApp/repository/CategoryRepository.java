package com.example.chinachemicalApp.repository;

import com.example.chinachemicalApp.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CategoryRepository extends JpaRepository <Category, UUID>{
}
