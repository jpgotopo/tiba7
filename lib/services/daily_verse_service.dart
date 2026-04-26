import 'package:shared_preferences/shared_preferences.dart';
import 'bible_api_service.dart';

class DailyVerseService {
  static final DailyVerseService _instance = DailyVerseService._();
  factory DailyVerseService() => _instance;
  DailyVerseService._();

  static const _prefVerseText = 'daily_verse_text';
  static const _prefVerseRef = 'daily_verse_ref';
  static const _prefVerseDate = 'daily_verse_date';

  // Curated list of encouraging verses (Indonesian Bible references)
  static const List<String> _verses = [
    'Yoh 3:16',
    'Fil 4:13',
    'Rm 8:28',
    'Mzm 23:1',
    'Yer 29:11',
    'Yes 40:31',
    'Mat 6:33',
    'Yos 1:9',
    'Ams 3:5-6',
    'Mzm 119:105',
    'Rm 12:2',
    'Gal 2:20',
    'Ef 2:8-9',
    'Flp 4:6-7',
    'Mzm 46:2',
    '1Kor 10:13',
    'Ibr 11:1',
    'Yak 1:2-3',
    '1Ptr 5:7',
    'Mat 11:28',
    'Yoh 14:6',
    'Mzm 27:1',
    'Yes 41:10',
    'Rm 5:8',
    'Ef 6:10',
    'Kol 3:23',
    '2Tim 1:7',
    'Mzm 34:8',
    'Mat 5:6',
    'Yoh 16:33',
    'Rm 8:37',
    'Mzm 37:4',
    'Ams 18:10',
    'Yes 43:2',
    'Flp 1:6',
    'Ibr 12:1-2',
    'Mzm 91:1',
    '1Yoh 4:4',
    'Nah 1:7',
    'Mat 28:20',
    'Yoh 10:10',
    'Rm 15:13',
    'Mzm 143:8',
    'Ams 16:3',
    'Yes 26:3',
    'Luk 1:37',
    'Yoh 8:32',
    'Ef 3:20',
    'Mzm 55:23',
    'Mat 7:7',
    'Yoh 15:5',
    'Rm 10:9',
    'Mzm 42:2',
    'Ams 4:23',
    'Yes 55:8-9',
    'Mat 22:37',
    'Yoh 11:25',
    'Rm 1:16',
    'Mzm 150:6',
    'Ams 22:6',
    'Yes 53:5',
    'Mat 5:14',
    'Yoh 17:17',
    'Ef 4:32',
    'Mzm 16:8',
    'Ams 11:2',
    'Yes 58:11',
    'Luk 6:38',
    'Yoh 3:30',
    'Rm 6:23',
    'Mzm 73:26',
    'Ams 27:17',
  ];

  Future<({String reference, String text})> getVerseOfDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final cachedDate = prefs.getString(_prefVerseDate);
    if (cachedDate == today) {
      final ref = prefs.getString(_prefVerseRef) ?? '';
      final text = prefs.getString(_prefVerseText) ?? '';
      if (ref.isNotEmpty && text.isNotEmpty) {
        return (reference: ref, text: text);
      }
    }

    // Pick verse based on day of year so it changes daily
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final ref = _verses[dayOfYear % _verses.length];

    final fetched = await BibleApiService.getPassage(ref);
    final text = fetched ?? '';

    if (text.isNotEmpty && !text.startsWith('Error')) {
      await prefs.setString(_prefVerseDate, today);
      await prefs.setString(_prefVerseRef, ref);
      await prefs.setString(_prefVerseText, text);
    }

    return (reference: ref, text: text);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
