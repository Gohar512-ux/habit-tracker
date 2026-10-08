import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/utils/date_helpers.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  HabitProvider(this._service);

  final HabitService _service;
  StreamSubscription<List<Habit>>? _sub;
  String? _uid;

  List<Habit> _habits = const [];
  bool _loading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get loading => _loading;
  String? get error => _error;

  void bindUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _habits = const [];
    _error = null;

    if (uid == null) {
      _loading = false;
    } else {
      _loading = true;
      _sub = _service.watchHabits(uid).listen(
        (list) {
          _habits = list;
          _loading = false;
          _error = null;
          notifyListeners();
        },
        onError: (_) {
          _loading = false;
          _error = 'Could not load your habits. Check your connection.';
          notifyListeners();
        },
      );
    }
    // Called from a provider update during build, so defer the notification.
    Future.microtask(notifyListeners);
  }

  Habit? byId(String id) {
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  List<Habit> habitsFor(DateTime date) =>
      _habits.where((h) => h.isScheduledOn(date)).toList();

  ({int done, int total}) progressFor(DateTime date) {
    final scheduled = habitsFor(date);
    final done = scheduled.where((h) => h.isDoneOn(date)).length;
    return (done: done, total: scheduled.length);
  }

  Future<void> add(Habit habit) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.addHabit(uid, habit);
  }

  Future<void> update(Habit habit) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.updateHabit(uid, habit);
  }

  Future<void> delete(String habitId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.deleteHabit(uid, habitId);
  }

  Future<void> toggle(Habit habit, DateTime date) async {
    final uid = _uid;
    if (uid == null) return;
    if (date.isAfter(DateHelpers.today())) return;
    await _service.setCompletion(
      uid,
      habit.id,
      DateHelpers.key(date),
      !habit.isDoneOn(date),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
