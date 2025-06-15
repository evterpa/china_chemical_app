package com.example.chinachemicalApp.dto;

import com.example.chinachemicalApp.entity.Product;
import java.util.List;

public class ProductPageResponse {

    private List<Product> products;
    private long totalProducts;
    private int page;
    private int size;
    private boolean hasNext;

    public ProductPageResponse() {
    }

    public ProductPageResponse(List<Product> products, long totalProducts, int page, int size, boolean hasNext) {
        this.products = products;
        this.totalProducts = totalProducts;
        this.page = page;
        this.size = size;
        this.hasNext = hasNext;
    }

    public List<Product> getProducts() {
        return products;
    }

    public void setProducts(List<Product> products) {
        this.products = products;
    }

    public long getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(long totalProducts) {
        this.totalProducts = totalProducts;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public void setHasNext(boolean hasNext) {
        this.hasNext = hasNext;
    }
}
