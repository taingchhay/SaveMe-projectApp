class TrackingEachDay {
  final DateTime date;
  final double? newSavingAmount;
  final double? suggestedSavingAmount;
  List<DailySpending> dailyItems;

  TrackingEachDay({
    required this.date,
    this.newSavingAmount,
    this.suggestedSavingAmount,
    required this.dailyItems,
  });

  double get totalDailySpending =>
      dailyItems.fold<double>(0, (sum, item) => sum + item.amount);

  double? get newSavingAmountOrNull =>
      newSavingAmount ?? suggestedSavingAmount;

  double get actualSavingAmount => newSavingAmountOrNull ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'newSavingAmount': newSavingAmount,
      'suggestedSavingAmount': suggestedSavingAmount,
      'dailyItems': dailyItems.map((item) => item.toJson()).toList(),
    };
  }

  factory TrackingEachDay.fromJson(Map<String, dynamic> json) {
    return TrackingEachDay(
      date: DateTime.parse(json['date'] as String),
      newSavingAmount: json['newSavingAmount'] as double?,
      suggestedSavingAmount: json['suggestedSavingAmount'] as double?,
      dailyItems: (json['dailyItems'] as List)
          .map((item) => DailySpending.fromJson(item))
          .toList(),
    );
  }
}

enum Category { food, drink, entertainment, shopping, transport }

class DailySpending {
  final String name;
  final double amount;
  Category category;

  DailySpending({
    required this.name,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'category': category.name,
    };
  }

  factory DailySpending.fromJson(Map<String, dynamic> json) {
    return DailySpending(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: Category.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => Category.food,
      ),
    );
  }
}