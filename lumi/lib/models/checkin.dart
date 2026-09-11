/// Represents a single row in the Appwrite "stress_entries" table.
/// A quick stress/energy check-in, per your Core Feature Set.
class CheckIn {
  final String? id; // Appwrite document/row ID, null until saved
  final int stressLevel; // 1 (low) – 5 (high)
  final int energyLevel; // 1 (low) – 5 (high)
  final DateTime date;
  final String userId;

  const CheckIn({
    this.id,
    required this.stressLevel,
    required this.energyLevel,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map[r'$id'] as String?,
      stressLevel: (map['stressLevel'] as num?)?.toInt() ?? 3,
      energyLevel: (map['energyLevel'] as num?)?.toInt() ?? 3,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      userId: map['userId'] as String? ?? '',
    );
  }
}