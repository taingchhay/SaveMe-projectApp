import '../domain/logic/date_generator.dart';
import '../domain/model/daily_record.dart';
import 'json_storage_io.dart';

class DailyRecordData {
  static const String _file = 'daily_records.json';

  Future<List<DailyRecord>> loadAll() async {
    final list = await JsonStorage.readList(_file);
    final out = <DailyRecord>[];
    for (final e in list) {
      try {
        if (e is! Map) continue;
        out.add(DailyRecord.fromJson(e.cast<String, dynamic>()));
      } catch (_) {}
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  Future<void> saveAll(List<DailyRecord> items) async {
    await JsonStorage.writeList(_file, items.map((e) => e.toJson()).toList());
  }

  Future<void> upsertByDate(DailyRecord record) async {
    final items = await loadAll();
    final key = DateGenerator.dateKey(record.date);
    final idx = items.indexWhere((r) => DateGenerator.dateKey(r.date) == key);
    if (idx >= 0) {
      items[idx] = record;
    } else {
      items.add(record);
    }
    await saveAll(items);
  }

  Future<DailyRecord?> loadByDate(DateTime date) async {
    final items = await loadAll();
    final key = DateGenerator.dateKey(date);
    final idx = items.indexWhere((r) => DateGenerator.dateKey(r.date) == key);
    if (idx < 0) return null;
    return items[idx];
  }

  Future<void> removeByDate(DateTime date) async {
    final items = await loadAll();
    final key = DateGenerator.dateKey(date);
    items.removeWhere((r) => DateGenerator.dateKey(r.date) == key);
    await saveAll(items);
  }

  Future<void> clear() async {
    await JsonStorage.writeList(_file, <dynamic>[]);
  }
}
