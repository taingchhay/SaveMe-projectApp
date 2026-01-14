import 'dart:convert';
import 'dart:io';
import 'package:saveme_project/domain/model/user_saving_plan.dart';

class SavingPlanRepository {
  static const String _fileName = 'saving_plans.json';

  Future<String> get _filePath async {
    const directory =
        r'D:\YEAR3\Term 1\MOBILE-DEVELOPMENT-FLUTTER\PROJECTS\Flutter Project\SaveMe-projectApp\lib\data';
    return '$directory\\$_fileName';
  }

  Future<void> saveAll(List<UserSavingPlan> plans) async {
    try {
      final path = await _filePath;
      final file = File(path);

      final jsonList = plans.map((plan) => plan.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await file.writeAsString(jsonString);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> save(UserSavingPlan plan) async {
    try {
      final plans = await loadAll();

      final existingIndex =
          plans.indexWhere((p) => p.goalName == plan.goalName);

      if (existingIndex >= 0) {
        plans[existingIndex] = plan;
      } else {
        plans.add(plan);
      }

      await saveAll(plans);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserSavingPlan>> loadAll() async {
    try {
      final path = await _filePath;
      final file = File(path);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();

      final jsonList = jsonDecode(jsonString) as List;
      final plans =
          jsonList.map((json) => UserSavingPlan.fromJson(json)).toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  Future<UserSavingPlan?> load(String goalName) async {
    try {
      final plans = await loadAll();
      return plans.firstWhere(
        (plan) => plan.goalName == goalName,
        orElse: () => throw Exception('Plan not found: $goalName'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String goalName) async {
    try {
      final plans = await loadAll();
      plans.removeWhere((plan) => plan.goalName == goalName);
      await saveAll(plans);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    try {
      final path = await _filePath;
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasData() async {
    try {
      final path = await _filePath;
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
