class DateGenerator {
  static const Duration oneDay = Duration(days: 1);

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String dateKey(DateTime d) => dateOnly(d).toIso8601String();

  static List<DateTime> generateInclusive(DateTime start, DateTime end) {
    final s = dateOnly(start);
    final e = dateOnly(end);
    final out = <DateTime>[];
    for (var cur = s; !cur.isAfter(e); cur = cur.add(oneDay)) {
      out.add(cur);
    }
    return out;
  }
}
