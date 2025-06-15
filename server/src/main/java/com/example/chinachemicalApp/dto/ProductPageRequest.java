package com.example.chinachemicalApp.dto;


import lombok.Data;

@Data
public class ProductPageRequest {
    private int page;
    private int size;

    public ProductPageRequest() {

    }
    public ProductPageRequest(int page, int size) {
        this.page = page;
        this.size = size;
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
