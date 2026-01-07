import '../domain/model/saving_goal.dart';
import '../domain/model/user_finance.dart';
import 'json_storage_io.dart';

class SavingGoalData {
  static const String _file = 'saving_goal.json';

  Future<void> savePlan({
    required SavingGoal goal,
    required UserFinance finance,
    required int totalPlannedDays,
  }) async {
    await JsonStorage.writeObject(_file, {
      'goal': goal.toJson(),
      'finance': finance.toJson(),
      'totalPlannedDays': totalPlannedDays,
    });
  }

  Future<SavingGoal?> loadGoal() async {
    final obj = await JsonStorage.readObject(_file);
    final raw = obj['goal'];
    if (raw is! Map) return null;
    return SavingGoal.fromJson(raw.cast<String, dynamic>());
  }

  Future<UserFinance?> loadFinance() async {
    final obj = await JsonStorage.readObject(_file);
    final raw = obj['finance'];
    if (raw is! Map) return null;
    return UserFinance.fromJson(raw.cast<String, dynamic>());
  }

  Future<int?> loadTotalPlannedDays() async {
    final obj = await JsonStorage.readObject(_file);
    final v = obj['totalPlannedDays'];
    if (v is num) return v.toInt();
    return null;
  }

  Future<void> clear() async {
    await JsonStorage.writeObject(_file, <String, dynamic>{});
  }
}
