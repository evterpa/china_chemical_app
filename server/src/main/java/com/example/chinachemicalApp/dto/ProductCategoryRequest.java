package com.example.chinachemicalApp.dto;

public class ProductCategoryRequest {
    private String categoryName;
    private int page;
    private int size;

    public ProductCategoryRequest() {}

    public ProductCategoryRequest(String categoryName, int page, int size) {
        this.categoryName = categoryName;
        this.page = page;
        this.size = size;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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
}
