import 'package:flutter/material.dart';

class RecoveryScreen extends StatelessWidget {
  final int stressLevel;
  final int energyLevel;

  const RecoveryScreen({
    super.key,
    required this.stressLevel,
    required this.energyLevel,
  });

  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  String get _nudge {
    if (energyLevel <= 2) {
      return "Your energy is low and your week is heavy right now. Tonight's "
          "sleep matters more than pushing through one more task.";
    }
    return "Your workload is high this week. Block out at least one recovery "
        "slot — rest, a walk, or time with people you like — before taking "
        "on anything new.";
  }

  static const _suggestions = [
    (Icons.bedtime_rounded, "Protect tonight's sleep"),
    (Icons.directions_walk_rounded, "Take a 20-minute walk outside"),
    (Icons.groups_rounded, "Message a friend, get out of the house"),
    (Icons.spa_rounded, "Take a screen-free break this evening"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFEBFB), Color(0xFFF8F7FC)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.spa_rounded, size: 48, color: _primary),
                const SizedBox(height: 20),
                const Text(
                  'Recovery',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _primaryDark),
                ),
                const SizedBox(height: 14),
                Text(
                  _nudge,
                  style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                const Text('Try one of these', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                ..._suggestions.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(s.$1, color: _primaryDark),
                          const SizedBox(width: 14),
                          Expanded(child: Text(s.$2, style: const TextStyle(fontSize: 14.5))),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to dashboard', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}