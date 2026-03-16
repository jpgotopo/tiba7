

class Passage {
  final String text;
  bool completed;

  Passage({required this.text, this.completed = false});

  Passage.copy(Passage other)
    : this(text: other.text, completed: other.completed);

  Map<String, dynamic> toJson() => {'text': text, 'completed': completed};

  factory Passage.fromJson(Map<String, dynamic> json) =>
      Passage(text: json['text'], completed: json['completed'] ?? false);
}

class Day {
  final int number;
  final List<Passage> passages; // 0: AT, 1: NT, 2: Salmo, 3: Proverbios
  bool get allCompleted => passages.every((p) => p.completed);

  Day({required this.number, required List<String> passageTexts})
    : passages = passageTexts.map((text) => Passage(text: text)).toList();

  Day.copy(Day other)
    : this(
        number: other.number,
        passageTexts: other.passages.map((p) => p.text).toList(),
      );

  Map<String, dynamic> toJson() => {
    'number': number,
    'passages': passages.map((p) => p.toJson()).toList(),
  };

  factory Day.fromJson(Map<String, dynamic> json) => Day(
    number: json['number'],
    passageTexts: (json['passages'] as List)
        .map<Passage>((p) => Passage.fromJson(p))
        .map((p) => p.text)
        .toList(),
  );
}

class MonthData {
  final String name;
  final int number;
  final List<Day> days;

  MonthData({required this.name, required this.number, required this.days});

  MonthData.copy(MonthData other)
    : this(
        name: other.name,
        number: other.number,
        days: other.days.map((d) => Day.copy(d)).toList(),
      );
}
