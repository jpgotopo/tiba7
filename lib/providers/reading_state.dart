import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_plan.dart';
import '../data/reading_data.dart';

class ReadingState extends ChangeNotifier {
  int _currentStreak = 0;
  int _selectedMonthIndex = 0;
  Map<String, bool> _completions = {}; // key: '1_1_0' for month1 day1 passage0
  bool _isLoading = false;

  int get currentStreak => _currentStreak;
  int get selectedMonthIndex => _selectedMonthIndex;
  List<MonthData> get months => getReadingPlans();
  MonthData get selectedMonth => months[_selectedMonthIndex];
  Map<String, bool> get completions => _completions;
  bool get isLoading => _isLoading;

  ReadingState() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    final completionsStr = prefs.getString('completions');
    if (completionsStr != null) {
      _completions = Map<String, bool>.from(json.decode(completionsStr));
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setString('completions', json.encode(_completions));
  }

  bool isPassageCompleted(int monthIdx, int dayNum, int passageIdx) {
    final key = '${monthIdx}_${dayNum}_$passageIdx';
    return _completions[key] ?? false;
  }

  Future<void> togglePassage(int monthIdx, int dayNum, int passageIdx) async {
    final key = '${monthIdx}_${dayNum}_$passageIdx';
    _completions[key] = !(_completions[key] ?? false);
    await _saveData();

    // Check if all passages for day completed
    bool dayComplete = true;
    for (int i = 0; i < 4; i++) {
      if (!isPassageCompleted(monthIdx, dayNum, i)) {
        dayComplete = false;
        break;
      }
    }
    if (dayComplete) {
      _currentStreak++;
      await _saveData();
    }
    notifyListeners();
  }

  void setSelectedMonth(int index) {
    _selectedMonthIndex = index;
    notifyListeners();
  }

  Future<void> completeAllForDay(int monthIdx, int dayNum) async {
    for (int i = 0; i < 4; i++) {
      await togglePassage(monthIdx, dayNum, i);
    }
    notifyListeners();
  }
}
