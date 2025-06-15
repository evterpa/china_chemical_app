package com.example.chinachemicalApp.controller;

import com.example.chinachemicalApp.dto.ProductPageResponse;
import com.example.chinachemicalApp.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    // Получить страницу продуктов с параметрами page и size, например: /api/products?page=0&size=16
    @GetMapping
    public ProductPageResponse getProductsPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "2") int size) {
        return productService.getProductsPage(page, size);
    }

    @GetMapping("/search")
    public ResponseEntity<ProductPageResponse> searchProducts(
            @RequestParam String query,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "2") int size) {

        ProductPageResponse response = productService.searchProductsByName(query, page, size);
        return ResponseEntity.ok(response);
    }


    @GetMapping("/by-category")
    public ResponseEntity<ProductPageResponse> getProductsByCategory(
            @RequestParam UUID category,
            @RequestParam (defaultValue = "0")int page,
            @RequestParam (defaultValue = "2")int size) {
        return ResponseEntity.ok(productService.getProductsByCategory(category, page, size));
    }



}
