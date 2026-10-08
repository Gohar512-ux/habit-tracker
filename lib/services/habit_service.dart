import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/habit.dart';

class HabitService {
  HabitService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.habitsCollection);

  Stream<List<Habit>> watchHabits(String uid) => _col(uid)
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => snap.docs.map(Habit.fromDoc).toList());

  Future<void> addHabit(String uid, Habit habit) =>
      _col(uid).add({...habit.toMap(), 'completedDates': <String>[]});

  Future<void> updateHabit(String uid, Habit habit) =>
      _col(uid).doc(habit.id).update(habit.toMap());

  Future<void> deleteHabit(String uid, String habitId) =>
      _col(uid).doc(habitId).delete();

  Future<void> setCompletion(
    String uid,
    String habitId,
    String dateKey,
    bool done,
  ) =>
      _col(uid).doc(habitId).update({
        'completedDates': done
            ? FieldValue.arrayUnion([dateKey])
            : FieldValue.arrayRemove([dateKey]),
      });
}
