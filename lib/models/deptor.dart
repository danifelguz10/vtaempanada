class Debtor {
  final String id;
  final String name;
  double amount;
  bool isPaid;

  Debtor({
    required this.id,
    required this.name,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'isPaid': isPaid,
    };
  }
}
