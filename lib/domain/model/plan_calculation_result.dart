class PlanCalculationResult {
  final bool canSave;
  final String? message;
  final double? dailySaving;
  final int? totalPlannedDays;
  final DateTime? endDate;

  const PlanCalculationResult._({
    required this.canSave,
    this.message,
    this.dailySaving,
    this.totalPlannedDays,
    this.endDate,
  });

  factory PlanCalculationResult.failure({required String message}) =>
      PlanCalculationResult._(canSave: false, message: message);

  factory PlanCalculationResult.success({
    required double dailySaving,
    required int totalPlannedDays,
    required DateTime endDate,
  }) =>
      PlanCalculationResult._(
        canSave: true,
        dailySaving: dailySaving,
        totalPlannedDays: totalPlannedDays,
        endDate: endDate,
      );
}
