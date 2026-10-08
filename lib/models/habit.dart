import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/date_helpers.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.iconIndex,
    required this.colorIndex,
    required this.weekdays,
    required this.completedDates,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final int iconIndex;
  final int colorIndex;

  /// ISO weekdays the habit is scheduled on (1 = Monday ... 7 = Sunday).
  final List<int> weekdays;

  /// Completed days stored as `yyyy-MM-dd` keys.
  final Set<String> completedDates;
  final DateTime createdAt;

  factory Habit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return Habit(
      id: doc.id,
      name: (d['name'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      iconIndex: (d['iconIndex'] as num?)?.toInt() ?? 0,
      colorIndex: (d['colorIndex'] as num?)?.toInt() ?? 0,
      weekdays: List<int>.from(d['weekdays'] ?? const [1, 2, 3, 4, 5, 6, 7]),
      completedDates: Set<String>.from(d['completedDates'] ?? const []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Metadata only. Completions are written separately so that editing a habit
  /// can never overwrite check-ins.
  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'iconIndex': iconIndex,
        'colorIndex': colorIndex,
        'weekdays': weekdays,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Habit copyWith({
    String? name,
    String? description,
    int? iconIndex,
    int? colorIndex,
    List<int>? weekdays,
  }) =>
      Habit(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        iconIndex: iconIndex ?? this.iconIndex,
        colorIndex: colorIndex ?? this.colorIndex,
        weekdays: weekdays ?? this.weekdays,
        completedDates: completedDates,
        createdAt: createdAt,
      );

  bool isScheduledOn(DateTime d) => weekdays.contains(d.weekday);
  bool isDoneOn(DateTime d) => completedDates.contains(DateHelpers.key(d));

  DateTime get _firstTrackedDay {
    var first = DateHelpers.dateOnly(createdAt);
    for (final k in completedDates) {
      final d = DateHelpers.parseKey(k);
      if (d.isBefore(first)) first = d;
    }
    return first;
  }

  int get totalCheckIns => completedDates.length;

  /// Consecutive scheduled days completed, ending today (or yesterday if today
  /// is still pending, so an unfinished day never breaks the streak).
  int get currentStreak {
    final today = DateHelpers.today();
    var day = today;
    if (isScheduledOn(today) && !isDoneOn(today)) {
      day = DateHelpers.addDays(today, -1);
    }
    var streak = 0;
    for (var i = 0; i < 3650; i++) {
      if (isScheduledOn(day)) {
        if (isDoneOn(day)) {
          streak++;
        } else {
          break;
        }
      }
      day = DateHelpers.addDays(day, -1);
    }
    return streak;
  }

  int get bestStreak {
    final today = DateHelpers.today();
    var day = _firstTrackedDay;
    var run = 0;
    var best = 0;
    while (!day.isAfter(today)) {
      if (isScheduledOn(day)) {
        if (isDoneOn(day)) {
          run++;
          if (run > best) best = run;
        } else if (!DateHelpers.isSameDay(day, today)) {
          run = 0;
        }
      }
      day = DateHelpers.addDays(day, 1);
    }
    return best;
  }

  /// Share of scheduled days completed over the last [days] days (0..1).
  double completionRate({int days = 30}) {
    final today = DateHelpers.today();
    final start = _firstTrackedDay;
    var scheduled = 0;
    var done = 0;
    for (var i = 0; i < days; i++) {
      final day = DateHelpers.addDays(today, -i);
      if (day.isBefore(start) || !isScheduledOn(day)) continue;
      if (isDoneOn(day)) {
        scheduled++;
        done++;
      } else if (!DateHelpers.isSameDay(day, today)) {
        scheduled++;
      }
    }
    return scheduled == 0 ? 0 : done / scheduled;
  }
}
