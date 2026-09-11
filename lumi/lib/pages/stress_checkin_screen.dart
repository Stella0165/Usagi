import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../models/checkin.dart';
import '../services/checkin_service.dart';
import 'success_dialog.dart';
import 'load_balancer_screen.dart';
import 'recovery_screen.dart';

class StressCheckInScreen extends StatefulWidget {
  const StressCheckInScreen({super.key});

  @override
  State<StressCheckInScreen> createState() => _StressCheckInScreenState();
}

class _StressCheckInScreenState extends State<StressCheckInScreen> {
  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  double _stress = 3;
  double _energy = 3;

  bool _isLoading = false;
  String? _errorMessage;

  static const _stressLabels = ['Very calm', 'Calm', 'Neutral', 'Stressed', 'Very stressed'];
  static const _energyLabels = ['Drained', 'Low', 'Okay', 'Energized', 'Very energized'];

  /// Mirrors the "High Workload Detected?" decision in the user flow
  /// diagram: high stress on its own, or lower stress paired with low
  /// energy, both count as a high-workload signal worth acting on.
  bool get _isHighWorkload {
    final stress = _stress.round();
    final energy = _energy.round();
    return stress >= 4 || (stress >= 3 && energy <= 2);
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // userId is filled in by CheckInService.createCheckIn using the
      // currently logged-in account, so a placeholder is fine here.
      final checkIn = CheckIn(
        stressLevel: _stress.round(),
        energyLevel: _energy.round(),
        date: DateTime.now(),
        userId: '',
      );

      await CheckInService.createCheckIn(checkIn);

      if (!mounted) return;
      await showSuccessDialog(context, message: 'Check-in logged!');
      if (!mounted) return;

      // "High Workload Detected?" branch from the user flow diagram:
      //   Yes -> Load Balancer -> ... -> Recovery Suggestion -> End
      //   No  -> Return to Dashboard
      if (_isHighWorkload) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoadBalancerScreen(
              stressLevel: _stress.round(),
              energyLevel: _energy.round(),
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } on AppwriteException catch (e) {
      setState(() => _errorMessage = 'Appwrite error: ${e.message ?? e.type ?? e.toString()}');
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sliderCard({
    required String title,
    required IconData icon,
    required double value,
    required List<String> labels,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            labels[value.round() - 1],
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _primaryDark),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _primary,
              inactiveTrackColor: _primary.withOpacity(0.15),
              thumbColor: _primary,
              overlayColor: _primary.withOpacity(0.15),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: onChanged,
            ),
          ),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Quick check-in',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _primaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'How are you feeling right now?',
                  style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.55), height: 1.4),
                ),
                const SizedBox(height: 28),

                _sliderCard(
                  title: 'Stress',
                  icon: Icons.bolt_rounded,
                  value: _stress,
                  labels: _stressLabels,
                  onChanged: (v) => setState(() => _stress = v),
                ),
                const SizedBox(height: 16),

                _sliderCard(
                  title: 'Energy',
                  icon: Icons.battery_charging_full_rounded,
                  value: _energy,
                  labels: _energyLabels,
                  onChanged: (v) => setState(() => _energy = v),
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13.5)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFF8A7FF0), Color(0xFF6C5EE0)]),
                      boxShadow: [
                        BoxShadow(color: _primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading ? null : _submit,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : const Text(
                                  'Log check-in',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
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