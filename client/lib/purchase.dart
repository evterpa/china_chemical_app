import 'product.dart';
class Purchase {
  final String id;
  final List<PurchaseItem> items;

  Purchase({required this.id, required this.items});

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => PurchaseItem.fromJson(item))
          .toList(),
    );
  }
}

class PurchaseItem {
  final String id;
  final Product product;
  final int quantity;

  PurchaseItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}