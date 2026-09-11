import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../models/commitment.dart';
import '../services/appwrite_client.dart';
import '../services/commitment_service.dart';
import 'success_dialog.dart';

class AddCommitmentScreen extends StatefulWidget {
  const AddCommitmentScreen({super.key});

  @override
  State<AddCommitmentScreen> createState() => _AddCommitmentScreenState();
}

class _AddCommitmentScreenState extends State<AddCommitmentScreen> {
  static const _primary = Color(0xFF7C6FE0);
  static const _primaryDark = Color(0xFF5B4FCF);

  final _taskNameController = TextEditingController();
  final _durationController = TextEditingController();

  String _category = CommitmentOptions.categories.first;
  String _priority = CommitmentOptions.priorities[1]; // Medium
  String _effort = CommitmentOptions.efforts[1]; // Medium
  bool _isFlexible = true;
  DateTime _date = DateTime.now();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _taskNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final taskName = _taskNameController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (taskName.isEmpty) {
      setState(() => _errorMessage = 'Please enter a task name.');
      return;
    }
    if (duration == null || duration <= 0) {
      setState(() => _errorMessage = 'Please enter a valid duration in minutes.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = (await Appwrite.account.get()).$id;

      final commitment = Commitment(
        taskName: taskName,
        category: _category,
        date: _date,
        durationMinutes: duration,
        priority: _priority,
        effort: _effort,
        isFlexible: _isFlexible,
        userId: userId,
      );

      await CommitmentService.createCommitment(commitment);

      if (!mounted) return;
      await showSuccessDialog(context, message: 'Commitment added successfully!');
      if (!mounted) return;
      Navigator.of(context).pop(true); // signal caller to refresh the list
    } on AppwriteException catch (e) {
      // Surfacing the real message so we can see exactly what Appwrite
      // rejected (bad database/collection ID, permissions, bad column type, etc).
      setState(() => _errorMessage = 'Appwrite error: ${e.message ?? e.type ?? e.toString()}');
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _fieldDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  Widget _dropdownCard({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _fieldDecoration(label: label, icon: icon),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
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
                  'Add commitment',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _primaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log a task so Lumi can factor it into your weekly capacity.',
                  style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.55), height: 1.4),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _taskNameController,
                  decoration: _fieldDecoration(label: 'Task name', icon: Icons.edit_note_rounded),
                ),
                const SizedBox(height: 16),

                _dropdownCard(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  value: _category,
                  options: CommitmentOptions.categories,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: _fieldDecoration(label: 'Date', icon: Icons.calendar_today_rounded),
                    child: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 15.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(label: 'Duration (minutes)', icon: Icons.timer_outlined),
                ),
                const SizedBox(height: 16),

                _dropdownCard(
                  label: 'Priority',
                  icon: Icons.flag_outlined,
                  value: _priority,
                  options: CommitmentOptions.priorities,
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 16),

                _dropdownCard(
                  label: 'Effort',
                  icon: Icons.bolt_outlined,
                  value: _effort,
                  options: CommitmentOptions.efforts,
                  onChanged: (v) => setState(() => _effort = v!),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: _primary,
                    title: const Text('Flexible', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _isFlexible
                          ? 'Can be moved if your week gets overloaded'
                          : 'Fixed — Lumi will not suggest moving this',
                      style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55)),
                    ),
                    value: _isFlexible,
                    onChanged: (v) => setState(() => _isFlexible = v),
                  ),
                ),

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
                        BoxShadow(
                          color: _primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isLoading ? null : _save,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : const Text(
                                  'Save commitment',
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