import 'saleproduct.dart';

class Sale {
  final String id;
  final DateTime timestamp;
  final double totalAmount;
  final List<SaleProduct> products;

  Sale({
    required this.id,
    required this.timestamp,
    required this.totalAmount,
    required this.products,
  });
}
