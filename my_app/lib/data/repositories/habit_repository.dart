import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/habit.dart';

class HabitRepository {
  static const String _key = 'habits';

  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Habit.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = habits.map((habit) => habit.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      // Ошибка сохранения - можно логировать
    }
  }

  Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit habit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == id);
    await saveHabits(habits);
  }
}

