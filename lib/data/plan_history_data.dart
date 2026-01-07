import '../domain/model/saving_goal.dart';
import '../domain/model/user_finance.dart';
import 'daily_record_data.dart';
import 'json_storage_io.dart';
import 'saving_goal_data.dart';

class PlanHistoryEntry {
  final String id;
  final SavingGoal goal;
  final UserFinance finance;
  final int totalPlannedDays;
  final double totalSaved;
  final int savedDays;
  final DateTime endDate;
  final DateTime archivedAt;

  const PlanHistoryEntry({
    required this.id,
    required this.goal,
    required this.finance,
    required this.totalPlannedDays,
    required this.totalSaved,
    required this.savedDays,
    required this.endDate,
    required this.archivedAt,
  });

  bool get isCompleted => totalSaved >= goal.goalPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal': goal.toJson(),
      'finance': finance.toJson(),
      'totalPlannedDays': totalPlannedDays,
      'totalSaved': totalSaved,
      'savedDays': savedDays,
      'endDate': endDate.toIso8601String(),
      'archivedAt': archivedAt.toIso8601String(),
    };
  }

  //AI Generated
  static PlanHistoryEntry fromJson(Map<String, dynamic> json) {
    return PlanHistoryEntry(
      id: (json['id'] as String?) ?? '',
      goal: SavingGoal.fromJson((json['goal'] as Map).cast<String, dynamic>()),
      finance: UserFinance.fromJson(
        (json['finance'] as Map).cast<String, dynamic>(),
      ),
      totalPlannedDays: (json['totalPlannedDays'] as num).toInt(),
      totalSaved: (json['totalSaved'] as num).toDouble(),
      savedDays: (json['savedDays'] as num).toInt(),
      endDate: DateTime.parse(json['endDate'] as String),
      archivedAt: DateTime.parse(json['archivedAt'] as String),
    );
  }
}

class PlanHistoryData {
  static const String _file = 'plan_history.json';

  Future<List<PlanHistoryEntry>> loadAll() async {
    final list = await JsonStorage.readList(_file);
    final entries = <PlanHistoryEntry>[];
    for (final e in list) {
      try {
        if (e is! Map) continue;
        entries.add(PlanHistoryEntry.fromJson(e.cast<String, dynamic>()));
      } catch (_) {}
    }
    entries.sort((a, b) => b.archivedAt.compareTo(a.archivedAt));
    return entries;
  }

  Future<void> saveAll(List<PlanHistoryEntry> entries) async {
    await JsonStorage.writeList(_file, entries.map((e) => e.toJson()).toList());
  }

  Future<void> add(PlanHistoryEntry entry) async {
    final items = await loadAll();
    items.insert(0, entry);
    await saveAll(items);
  }

  Future<void> deleteById(String id) async {
    final items = await loadAll();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  //AI Generated
  Future<void> saveCurrentPlanToHistory() async {
    final goal = await SavingGoalData().loadGoal();
    final finance = await SavingGoalData().loadFinance();
    final totalDays = await SavingGoalData().loadTotalPlannedDays();
    if (goal == null || finance == null || totalDays == null) return;

    final records = await DailyRecordData().loadAll();
    final saved = records.where((r) => r.isSaved).toList();
    final totalSaved =
        saved.fold<double>(0.0, (s, r) => s + r.savedAmountThisDay);
    final savedDays = saved.length;

    final start = DateTime(
      goal.startDate.year,
      goal.startDate.month,
      goal.startDate.day,
    );
    final end = start.add(Duration(days: totalDays - 1));

    await add(
      PlanHistoryEntry(
        id: goal.id,
        goal: goal,
        finance: finance,
        totalPlannedDays: totalDays,
        totalSaved: totalSaved,
        savedDays: savedDays,
        endDate: end,
        archivedAt: DateTime.now(),
      ),
    );
  }
}
