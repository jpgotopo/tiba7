import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_plan.dart';
import '../data/reading_data.dart';

class ReadingState extends ChangeNotifier {
  int _currentStreak = 0;
  int _selectedMonthIndex = 0;
  Map<String, bool> _completions = {}; // key: 'monthIdx_dayNum_passageIdx'
  bool _isLoading = false;

  int get currentStreak => _currentStreak;
  int get selectedMonthIndex => _selectedMonthIndex;
  List<MonthData> get months => getReadingPlans();
  MonthData get selectedMonth => months[_selectedMonthIndex];
  Map<String, bool> get completions => _completions;
  bool get isLoading => _isLoading;

  int get totalDaysInYear {
    return months.fold(0, (sum, month) => sum + month.days.length);
  }

  int get completedDaysCount {
    int count = 0;
    for (int m = 0; m < months.length; m++) {
      for (int d = 1; d <= months[m].days.length; d++) {
        if (_isDayFullyCompleted(m, d, months[m])) count++;
      }
    }
    return count;
  }

  double get completionPercentage {
    if (totalDaysInYear == 0) return 0.0;
    return (completedDaysCount / totalDaysInYear) * 100;
  }

  int get completedDaysInCurrentMonth {
    int count = 0;
    for (int d = 1; d <= selectedMonth.days.length; d++) {
      if (_isDayFullyCompleted(_selectedMonthIndex, d, selectedMonth)) count++;
    }
    return count;
  }

  double get currentMonthCompletionPercentage {
    if (selectedMonth.days.isEmpty) return 0.0;
    return (completedDaysInCurrentMonth / selectedMonth.days.length) * 100;
  }

  bool _isDayFullyCompleted(int monthIdx, int dayNum, MonthData month) {
    final day = month.days.firstWhere(
      (d) => d.number == dayNum,
      orElse: () => Day(number: dayNum, passageTexts: []),
    );
    if (day.passages.isEmpty) return false;
    for (int p = 0; p < day.passages.length; p++) {
      if (!isPassageCompleted(monthIdx, dayNum, p)) return false;
    }
    return true;
  }

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

    // Default to current month on first load
    final savedMonthIndex = prefs.getInt('selectedMonthIndex');
    if (savedMonthIndex == null) {
      final now = DateTime.now();
      _selectedMonthIndex = (now.month - 1).clamp(0, 11);
    } else {
      _selectedMonthIndex = savedMonthIndex.clamp(0, 11);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setString('completions', json.encode(_completions));
    await prefs.setInt('selectedMonthIndex', _selectedMonthIndex);
  }

  bool isPassageCompleted(int monthIdx, int dayNum, int passageIdx) {
    final key = '${monthIdx}_${dayNum}_$passageIdx';
    return _completions[key] ?? false;
  }

  Future<void> togglePassage(int monthIdx, int dayNum, int passageIdx) async {
    final key = '${monthIdx}_${dayNum}_$passageIdx';
    _completions[key] = !(_completions[key] ?? false);
    notifyListeners();
    await _saveData();
    _updateStreak();
  }

  void setSelectedMonth(int index) {
    _selectedMonthIndex = index.clamp(0, 11);
    _saveData();
    notifyListeners();
  }

  /// Marks all passages in a day as complete (or un-marks if all are already complete).
  Future<void> completeAllForDay(int monthIdx, int dayNum) async {
    final month = months[monthIdx];
    final day = month.days.firstWhere(
      (d) => d.number == dayNum,
      orElse: () => Day(number: dayNum, passageTexts: []),
    );
    final allCurrentlyDone = _isDayFullyCompleted(monthIdx, dayNum, month);

    for (int i = 0; i < day.passages.length; i++) {
      final key = '${monthIdx}_${dayNum}_$i';
      _completions[key] = !allCurrentlyDone;
    }
    notifyListeners();
    await _saveData();
    _updateStreak();
  }

  /// Recalculates current streak based on consecutive completed days ending today.
  void _updateStreak() {
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // Walk back day by day while we find completed days
    while (true) {
      final mIdx = checkDate.month - 1;
      final dNum = checkDate.day;
      final month = months[mIdx];
      if (_isDayFullyCompleted(mIdx, dNum, month)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
      // Safety: don't look back more than 366 days
      if (streak > 366) break;
    }

    if (streak != _currentStreak) {
      _currentStreak = streak;
      _saveData();
      notifyListeners();
    }
  }
}
