import 'package:flutter/material.dart';

import '../models/commitment.dart';
import '../services/commitment_service.dart';

class CapacityDashboardScreen extends StatefulWidget {
  const CapacityDashboardScreen({super.key});

  @override
  State<CapacityDashboardScreen> createState() => _CapacityDashboardScreenState();
}

class _CapacityDashboardScreenState extends State<CapacityDashboardScreen> {
  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  // TODO: replace with a real per-user value from the "Set Weekly Availability"
  // onboarding step once it's built. For now, assume a 40-hour week split
  // evenly across the 5 workload categories as a rough per-category budget.
  static const int _weeklyCapacityMinutesTotal = 40 * 60;
  static const int _categoryCount = 5;
  static const int _weeklyCapacityMinutesPerCategory = _weeklyCapacityMinutesTotal ~/ _categoryCount;

  late Future<List<Commitment>> _commitmentsFuture;

  @override
  void initState() {
    super.initState();
    _commitmentsFuture = CommitmentService.listCommitments();
  }

  Future<void> _refresh() async {
    setState(() {
      _commitmentsFuture = CommitmentService.listCommitments();
    });
    await _commitmentsFuture;
  }

  /// Returns the Monday..Sunday range containing [now].
  ({DateTime start, DateTime end}) _currentWeekRange(DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final monday = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final sunday = monday.add(const Duration(days: 7));
    return (start: monday, end: sunday);
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Mental':
        return const Color(0xFF8A7FF0);
      case 'Time':
        return const Color(0xFF5B4FCF);
      case 'Physical':
        return const Color(0xFF4FB0CF);
      case 'Social':
        return const Color(0xFFCF8F4F);
      case 'Errands':
        return const Color(0xFF4FCF7A);
      default:
        return _primary;
    }
  }

  Map<String, int> _minutesByCategory(List<Commitment> commitments) {
    final week = _currentWeekRange(DateTime.now());
    final totals = {for (final c in CommitmentOptions.categories) c: 0};

    for (final c in commitments) {
      final inThisWeek = !c.date.isBefore(week.start) && c.date.isBefore(week.end);
      if (inThisWeek) {
        totals[c.category] = (totals[c.category] ?? 0) + c.durationMinutes;
      }
    }
    return totals;
  }

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
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<Commitment>>(
              future: _commitmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        'Could not load your dashboard.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final commitments = snapshot.data ?? [];
                final minutesByCategory = _minutesByCategory(commitments);
                final totalMinutes = minutesByCategory.values.fold<int>(0, (a, b) => a + b);
                final overallPercent =
                    (_weeklyCapacityMinutesTotal == 0) ? 0.0 : (totalMinutes / _weeklyCapacityMinutesTotal * 100);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Your capacity',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _primaryDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    Text(
                      'How your week is looking, by category.',
                      style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.55)),
                    ),
                    const SizedBox(height: 28),
                    _OverallCapacityCard(percent: overallPercent, totalMinutes: totalMinutes),
                    const SizedBox(height: 24),
                    const Text(
                      'Load by category',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _primaryDark),
                    ),
                    const SizedBox(height: 14),
                    ...CommitmentOptions.categories.map((category) {
                      final minutes = minutesByCategory[category] ?? 0;
                      final percent = (_weeklyCapacityMinutesPerCategory == 0)
                          ? 0.0
                          : (minutes / _weeklyCapacityMinutesPerCategory).clamp(0.0, 1.5);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CategoryBar(
                          category: category,
                          color: _categoryColor(category),
                          minutes: minutes,
                          percentOfBudget: percent,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OverallCapacityCard extends StatelessWidget {
  const _OverallCapacityCard({required this.percent, required this.totalMinutes});

  final double percent;
  final int totalMinutes;

  Color _statusColor() {
    if (percent >= 100) return const Color(0xFFD9534F); // overloaded
    if (percent >= 75) return const Color(0xFFCF8F4F); // warning
    return const Color(0xFF4FCF7A); // healthy
  }

  String _statusLabel() {
    if (percent >= 100) return 'Overloaded';
    if (percent >= 75) return 'Getting busy';
    return 'On track';
  }

  @override
  Widget build(BuildContext context) {
    final hours = (totalMinutes / 60).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re at ${percent.toStringAsFixed(0)}% capacity this week',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF5B4FCF)),
                ),
                const SizedBox(height: 6),
                Text(
                  '$hours hrs logged this week',
                  style: TextStyle(fontSize: 13.5, color: Colors.black.withOpacity(0.55)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _statusColor()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (percent / 100).clamp(0.0, 1.0),
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(_statusColor()),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.color,
    required this.minutes,
    required this.percentOfBudget,
  });

  final String category;
  final Color color;
  final int minutes;
  final double percentOfBudget; // 0.0–1.5+, already clamped upstream

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              Text(
                '$minutes min',
                style: TextStyle(fontSize: 12.5, color: Colors.black.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentOfBudget.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}