class FixedExpense {
  final String name;
  final double amount;

  FixedExpense({required this.name, required this.amount});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }

  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
