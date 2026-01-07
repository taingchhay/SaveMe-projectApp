class SpendingItem {
  final String spendingItemName;
  final String category;
  final double spendingItemAmount;

  SpendingItem({
    required this.spendingItemName,
    required this.category,
    required this.spendingItemAmount,
  });

  Map<String, dynamic> toJson() => {
        'spendingItemName': spendingItemName,
        'category': category,
        'spendingItemAmount': spendingItemAmount,
      };

  static SpendingItem fromJson(Map<String, dynamic> json) => SpendingItem(
        spendingItemName: (json['spendingItemName'] as String?) ?? '',
        category: (json['category'] as String?) ?? 'Other',
        spendingItemAmount:
            (json['spendingItemAmount'] as num?)?.toDouble() ?? 0.0,
      );
}

class DailyRecord {
  final DateTime date;

  final List<SpendingItem> spendingItems;
  final double totalSpending;

  final double suggestedSaving;

  final double savedAmountThisDay;
  final bool isSaved;
  final bool isMissed; 

  DailyRecord({
    required this.date,
    required this.spendingItems,
    required this.totalSpending,
    required this.suggestedSaving,
    required this.savedAmountThisDay,
    required this.isSaved,
    this.isMissed = false, 
  });

  DailyRecord copyWith({
    DateTime? date,
    List<SpendingItem>? spendingItems,
    double? totalSpending,
    double? suggestedSaving,
    double? savedAmountThisDay,
    bool? isSaved,
    bool? isMissed,
  }) {
    return DailyRecord(
      date: date ?? this.date,
      spendingItems: spendingItems ?? this.spendingItems,
      totalSpending: totalSpending ?? this.totalSpending,
      suggestedSaving: suggestedSaving ?? this.suggestedSaving,
      savedAmountThisDay: savedAmountThisDay ?? this.savedAmountThisDay,
      isSaved: isSaved ?? this.isSaved,
      isMissed: isMissed ?? this.isMissed,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'spendingItems': spendingItems.map((e) => e.toJson()).toList(),
        'totalSpending': totalSpending,
        'suggestedSaving': suggestedSaving,
        'savedAmountThisDay': savedAmountThisDay,
        'isSaved': isSaved,
        'isMissed': isMissed,
      };

  //AI Generated
  static DailyRecord fromJson(Map<String, dynamic> json) => DailyRecord(
        date: DateTime.parse(json['date'] as String),
        spendingItems: ((json['spendingItems'] as List?) ?? const [])
            .map((e) =>
                SpendingItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0.0,
        suggestedSaving: (json['suggestedSaving'] as num?)?.toDouble() ?? 0.0,
        savedAmountThisDay:
            (json['savedAmountThisDay'] as num?)?.toDouble() ?? 0.0,
        isSaved: (json['isSaved'] as bool?) ?? false,
        isMissed: (json['isMissed'] as bool?) ?? false,
      );
}
