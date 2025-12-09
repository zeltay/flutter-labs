class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.note,
    this.completedToday = false,
  });

  final String id;
  final String title;
  final String note;
  final bool completedToday;

  Habit copyWith({
    String? id,
    String? title,
    String? note,
    bool? completedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      completedToday: completedToday ?? this.completedToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'completedToday': completedToday,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      note: json['note'] as String,
      completedToday: json['completedToday'] as bool? ?? false,
    );
  }
}

