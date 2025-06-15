class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}

class ProductResponse {
  final List<Product> products;
  final int totalProducts;
  final int page;
  final int size;
  final bool hasNext;

  ProductResponse({
    required this.products,
    required this.totalProducts,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as List;
    List<Product> productsList = productsJson.map((p) => Product.fromJson(p)).toList();

    return ProductResponse(
      products: productsList,
      totalProducts: json['totalProducts'],
      page: json['page'],
      size: json['size'],
      hasNext: json['hasNext'],
    );
  }
}