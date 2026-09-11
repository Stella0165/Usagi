import 'package:flutter/material.dart';

import '../models/commitment.dart';
import '../services/commitment_service.dart';
import '../services/appwrite_client.dart';

import 'add_commitment_screen.dart';
import 'capacity_dashboard_screen.dart';
import 'landing_screen.dart';

class CommitmentsListScreen extends StatefulWidget {
  const CommitmentsListScreen({super.key});

  @override
  State<CommitmentsListScreen> createState() =>
      _CommitmentsListScreenState();
}

class _CommitmentsListScreenState
    extends State<CommitmentsListScreen> {
  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  late Future<List<Commitment>> _commitmentsFuture;

  @override
  void initState() {
    super.initState();
    _commitmentsFuture =
        CommitmentService.listCommitments();
  }

  Future<void> _refresh() async {
    setState(() {
      _commitmentsFuture =
          CommitmentService.listCommitments();
    });

    await _commitmentsFuture;
  }

  Future<void> _openAddCommitment() async {
    final saved =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddCommitmentScreen(),
      ),
    );

    if (saved == true) {
      _refresh();
    }
  }

  Future<void> _openEditCommitment(
    Commitment commitment,
  ) async {
    final saved =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddCommitmentScreen(
          existing: commitment,
        ),
      ),
    );

    if (saved == true) {
      _refresh();
    }
  }

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CapacityDashboardScreen(),
      ),
    );
  }

  Future<bool> _confirmDelete(
    Commitment commitment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete commitment?',
        ),
        content: Text(
          'This will permanently remove '
          '"${commitment.taskName}".',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CommitmentService.deleteCommitment(
        commitment.id!,
      );

      return true;
    }

    return false;
  }

  Future<void> _signOut() async {
    try {
      await Appwrite.account.deleteSession(
        sessionId: 'current',
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LandingScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign out failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await _signOut();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F7FC),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: _primary,
        onPressed: _openAddCommitment,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFEBFB),
              Color(0xFFF8F7FC),
            ],
            stops: [0.0, 0.3],
          ),
        ),

        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,

            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    28,
                    24,
                    28,
                    8,
                  ),

                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Your commitments',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight.w800,
                                  color:
                                      _primaryDark,
                                ),
                              ),
                            ),

                            IconButton(
                              tooltip: 'Capacity dashboard',
                              onPressed: _openDashboard,
                              icon: const Icon(
                                Icons.donut_large_rounded,
                                color: _primaryDark,
                              ),
                            ),

                            IconButton(
                              tooltip: 'Sign out',
                              onPressed:
                                  _confirmSignOut,
                              icon: const Icon(
                                Icons.logout_rounded,
                                color:
                                    _primaryDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Everything you\'ve logged '
                          'this week.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black
                                .withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                FutureBuilder<List<Commitment>>(
                  future: _commitmentsFuture,

                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child:
                              CircularProgressIndicator(
                            color: _primary,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              28,
                            ),
                            child: Text(
                              'Could not load '
                              'commitments.\n'
                              '${snapshot.error}',
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final commitments =
                        snapshot.data ?? [];

                    if (commitments.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              28,
                            ),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .checklist_rtl_rounded,
                                  size: 48,
                                  color: _primary
                                      .withOpacity(0.4),
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                Text(
                                  'No commitments yet.\n'
                                  'Tap + to add your '
                                  'first one.',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black
                                        .withOpacity(
                                            0.5),
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        28,
                        12,
                        28,
                        100,
                      ),

                      sliver: SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, index) {
                            final c =
                                commitments[index];

                            return Dismissible(
                              key: ValueKey(c.id),

                              direction:
                                  DismissDirection
                                      .endToStart,

                              confirmDismiss: (_) =>
                                  _confirmDelete(c),

                              onDismissed: (_) =>
                                  _refresh(),

                              background: Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 12,
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment
                                    .centerRight,
                                decoration:
                                    BoxDecoration(
                                  color: Colors.red
                                      .withOpacity(
                                          0.85),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              16),
                                ),
                                child: const Icon(
                                  Icons
                                      .delete_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),

                              child: InkWell(
                                borderRadius:
                                    BorderRadius
                                        .circular(16),

                                onTap: () =>
                                    _openEditCommitment(
                                  c,
                                ),

                                child: Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),

                                  padding:
                                      const EdgeInsets
                                          .all(16),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                16),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                                0.04),
                                        blurRadius: 10,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ],
                                  ),

                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 40,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              _categoryColor(
                                            c.category,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            6,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 14,
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [
                                            Text(
                                              c.taskName,
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    15.5,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 4,
                                            ),

                                            Text(
                                              '${c.category} '
                                              '• ${c.priority} '
                                              'priority '
                                              '• ${c.durationMinutes} '
                                              'min',
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    12.5,
                                                color: Colors
                                                    .black
                                                    .withOpacity(
                                                        0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (c.isFlexible)
                                        Icon(
                                          Icons
                                              .sync_alt_rounded,
                                          size: 18,
                                          color: _primary
                                              .withOpacity(
                                                  0.5),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },

                          childCount:
                              commitments.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}