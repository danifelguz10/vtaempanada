class SaleProduct {
  final String productId;
  final String name;
  final double price;
  int quantity;

  SaleProduct({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}
