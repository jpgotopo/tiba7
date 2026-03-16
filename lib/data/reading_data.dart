import '../models/reading_plan.dart';

List<MonthData> getReadingPlans() {
  final monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  return List.generate(12, (monthIndex) {
    final monthName = monthNames[monthIndex];
    final numDays = daysInMonth[monthIndex];
    final days = List.generate(numDays, (dayIndex) {
      final dayNum = dayIndex + 1;
      return Day(
        number: dayNum,
        passageTexts: [
          'Kejadian $dayNum', // AT placeholder
          'Matius $dayNum', // NT
          'Mazmur ${10 + dayIndex % 150 + 1}', // Salmo
          'Amsal $dayNum', // Proverbios
        ],
      );
    });
    return MonthData(name: monthName, number: monthIndex + 1, days: days);
  });
}
