class SavingGoal {
  final String id;
  final String goalName;
  final double goalPrice;

  final DateTime startDate;
  final double? targetDailySaving;

  SavingGoal({
    required this.id,
    required this.goalName,
    required this.goalPrice,
    required this.startDate,
    required this.targetDailySaving,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'goalName': goalName,
    'goalPrice': goalPrice,
    'startDate': startDate.toIso8601String(),
    'targetDailySaving': targetDailySaving,
  };

  static SavingGoal fromJson(Map<String, dynamic> json) => SavingGoal(
    id: json['id'] as String,
    goalName: json['goalName'] as String,
    goalPrice: (json['goalPrice'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate'] as String),
    targetDailySaving: (json['targetDailySaving'] as num?)?.toDouble(),
  );
}
