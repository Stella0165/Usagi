import 'package:flutter/material.dart';

import '../models/commitment.dart';
import '../services/commitment_service.dart';
import 'recovery_screen.dart';

class LoadBalancerScreen extends StatefulWidget {
  final int stressLevel;
  final int energyLevel;

  const LoadBalancerScreen({
    super.key,
    this.stressLevel = 3,
    this.energyLevel = 3,
  });

  @override
  State<LoadBalancerScreen> createState() => _LoadBalancerScreenState();
}

class _LoadBalancerScreenState extends State<LoadBalancerScreen> {
  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  // Same placeholder budget used by CapacityDashboardScreen. Keep these two
  // screens' numbers in sync until "Set Weekly Availability" is built.
  static const int _weeklyCapacityMinutesTotal = 40 * 60;
  static const int _categoryCount = 5;
  static const int _weeklyCapacityMinutesPerCategory = _weeklyCapacityMinutesTotal ~/ _categoryCount;

  static const _priorityRank = {'Low': 0, 'Medium': 1, 'High': 2};

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

  ({DateTime start, DateTime end}) _currentWeekRange(DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final monday = startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
    final sunday = monday.add(const Duration(days: 7));
    return (start: monday, end: sunday);
  }

  /// For each category that's over 100% of its weekly budget, returns the
  /// flexible commitments in that category sorted lowest-priority first —
  /// these are the ones we suggest moving to rebalance the week.
  Map<String, List<Commitment>> _suggestionsByCategory(List<Commitment> commitments) {
    final week = _currentWeekRange(DateTime.now());
    final thisWeek = commitments.where((c) => !c.date.isBefore(week.start) && c.date.isBefore(week.end)).toList();

    final minutesByCategory = <String, int>{};
    for (final c in thisWeek) {
      minutesByCategory[c.category] = (minutesByCategory[c.category] ?? 0) + c.durationMinutes;
    }

    final overloadedCategories = minutesByCategory.entries
        .where((e) => e.value > _weeklyCapacityMinutesPerCategory)
        .map((e) => e.key)
        .toSet();

    final suggestions = <String, List<Commitment>>{};
    for (final category in overloadedCategories) {
      final flexibleInCategory = thisWeek.where((c) => c.category == category && c.isFlexible).toList()
        ..sort((a, b) => _priorityRank[a.priority]!.compareTo(_priorityRank[b.priority]!));
      if (flexibleInCategory.isNotEmpty) {
        suggestions[category] = flexibleInCategory;
      }
    }
    return suggestions;
  }

  Future<void> _moveCommitment(Commitment commitment) async {
    // Simple rule: push it a week later, into a day that's currently empty
    // in that category. This is a placeholder scheduling rule — swap in
    // something smarter once you have real availability data.
    final newDate = commitment.date.add(const Duration(days: 7));
    await CommitmentService.updateCommitment(commitment.copyWith(date: newDate));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Moved "${commitment.taskName}" to next week.')),
    );
    _refresh();
  }

  void _goToRecovery() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecoveryScreen(
          stressLevel: widget.stressLevel,
          energyLevel: widget.energyLevel,
        ),
      ),
    );
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
                        'Could not load suggestions.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final commitments = snapshot.data ?? [];
                final suggestions = _suggestionsByCategory(commitments);

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
                            'Rebalance',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _primaryDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      suggestions.isEmpty
                          ? 'No overloaded categories this week — you\'re in good shape.'
                          : 'These categories are over budget. Here\'s what could move.',
                      style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.55), height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    if (suggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 48, color: _primary.withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text(
                                'All categories are within budget.',
                                style: TextStyle(color: Colors.black.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...suggestions.entries.map((entry) {
                        final category = entry.key;
                        final flexibleCommitments = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9534F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Over budget',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD9534F),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...flexibleCommitments.take(2).map((c) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.taskName,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${c.priority} priority • ${c.durationMinutes} min • flexible',
                                                style: TextStyle(fontSize: 12.5, color: Colors.black.withOpacity(0.5)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _moveCommitment(c),
                                          child: const Text('Move to next week'),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryDark,
                          side: const BorderSide(color: _primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _goToRecovery,
                        child: const Text("I've made my adjustments — see recovery tips"),
                      ),
                    ),
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