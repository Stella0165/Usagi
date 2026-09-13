
class Commitment {
  final String? id; // Appwrite document/row ID, null until saved
  final String taskName;
  final String category; // 'Mental' | 'Time' | 'Physical' | 'Social' | 'Errands'
  final DateTime date;
  final int durationMinutes;
  final String priority; // 'Low' | 'Medium' | 'High'
  final String effort; // 'Low' | 'Medium' | 'High'
  final bool isFlexible; // true = flexible, false = fixed
  final bool isDone;
  final String userId;

  const Commitment({
    this.id,
    required this.taskName,
    required this.category,
    required this.date,
    required this.durationMinutes,
    required this.priority,
    required this.effort,
    required this.isFlexible,
    this.isDone = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': taskName,
      'category': category,
      'date': date.toIso8601String(),
      'durationHours': durationMinutes,
      'priority': priority,
      'effort': effort,
      'isFlexible': isFlexible,
      'isDone': isDone,
    };
  }
  factory Commitment.fromMap(Map<String, dynamic> map) {
    return Commitment(
      id: map[r'$id'] as String?,
      taskName: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Time',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: (map['durationHours'] as num?)?.toInt() ?? 0,
      priority: map['priority'] as String? ?? 'Medium',
      effort: map['effort'] as String? ?? 'Medium',
      isFlexible: map['isFlexible'] as bool? ?? true,
      isDone: map['isDone'] as bool? ?? false,
      userId: '', // not stored; only used transiently when creating a row
    );
  }

  Commitment copyWith({
    String? id,
    String? taskName,
    String? category,
    DateTime? date,
    int? durationMinutes,
    String? priority,
    String? effort,
    bool? isFlexible,
    bool? isDone,
    String? userId,
  }) {
    return Commitment(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      category: category ?? this.category,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priority: priority ?? this.priority,
      effort: effort ?? this.effort,
      isFlexible: isFlexible ?? this.isFlexible,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
    );
  }
}

class CommitmentOptions {
  static const categories = ['Mental', 'Time', 'Physical', 'Social', 'Errands', 'Academic', 'Work', 'Personal', 'Financial', 'Health',];
  static const priorities = ['Low', 'Medium', 'High'];
  static const efforts = ['Low', 'Medium', 'High'];
}