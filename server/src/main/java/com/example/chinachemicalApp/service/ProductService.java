package com.example.chinachemicalApp.service;

import com.example.chinachemicalApp.dto.ProductPageResponse;
import com.example.chinachemicalApp.entity.Category;
import com.example.chinachemicalApp.entity.Product;
import com.example.chinachemicalApp.repository.CategoryRepository;
import com.example.chinachemicalApp.repository.ProductRepository;
import com.stripe.model.PaymentIntent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    public ProductPageResponse getProductsPage(int page, int size) {
        Page<Product> productsPage = productRepository.findAll(PageRequest.of(page, size));
        boolean hasNext = productsPage.hasNext();

        return new ProductPageResponse(
                productsPage.getContent(),
                productsPage.getTotalElements(),
                page,
                size,
                hasNext
        );
    }




    public ProductPageResponse searchProductsByName(String query, int page, int size) {
        var pageable = PageRequest.of(page, size);
        var productPage = productRepository.findByNameContainingIgnoreCase(query, pageable);

        return new ProductPageResponse(
                productPage.getContent(),
                productPage.getTotalElements(),
                page,
                size,
                productPage.hasNext()
        );
    }

    public ProductPageResponse getProductsByCategory(UUID categoryId, int page, int size) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + categoryId));

        Pageable pageable = PageRequest.of(page, size);
        Page<Product> productPage = productRepository.findByCategory(category, pageable);

        return new ProductPageResponse(
                productPage.getContent(),
                productPage.getTotalElements(),
                page,
                size,
                productPage.hasNext()
        );
    }


}
