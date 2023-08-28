class Product {
  final String id;
  late String name;
  late double price;
  final String productId;
  int inventoryQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.inventoryQuantity,

    required this.productId,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      price: map['price'],

      productId: '',
      inventoryQuantity: map['inventoryQuantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'inventoryQuantity': inventoryQuantity,
    };
  }
}
