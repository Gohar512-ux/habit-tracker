import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime today() => dateOnly(DateTime.now());
  static DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
  static DateTime startOfWeek(DateTime d) => addDays(dateOnly(d), -(d.weekday - 1));
  static String key(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static DateTime parseKey(String k) => dateOnly(DateTime.parse(k));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
