import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/environment.dart';
import 'commitment_service.dart';

/// Wraps a single ongoing Gemini chat session for the "Talk to Lumi" screen.
///
/// NOTE ON THE API KEY: this calls Gemini directly from the Flutter client,
/// which means GEMINI_API_KEY ships inside the compiled app and can be
/// extracted by anyone determined enough. That's an accepted trade-off for
/// a class project / hackathon build. If this ever needs to go to
/// production, move this call into an Appwrite Function instead, so the
/// key stays server-side and the app only ever talks to your own backend.
class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chat;

  GenerativeModel _getModel() {
    return _model ??= GenerativeModel(
      model: GEMINI_MODEL,
      apiKey: GEMINI_API_KEY,
      systemInstruction: Content.system(
        "You are Lumi, a warm, concise support companion inside a student "
        "workload app. You are talking to a university student who just "
        "logged a high-stress check-in. Keep replies short (2-4 sentences), "
        "practical, and validating — never clinical, never preachy. You can "
        "suggest small concrete actions (rescheduling a task, a short break, "
        "sleep) but you are not a therapist and should say so if the "
        "student describes anything serious like self-harm, and encourage "
        "them to reach out to a real person or professional in that case.",
      ),
    );
  }

  /// Builds a short summary of what's currently loading up the student's
  /// week, so Gemini's first reply can reference something real instead of
  /// speaking in the abstract. Fails silently (returns an empty string) if
  /// the commitments can't be loaded — the chat still works either way.
  Future<String> _buildContextSummary() async {
    try {
      final commitments = await CommitmentService.listCommitments();
      if (commitments.isEmpty) return '';

      final minutesByCategory = <String, int>{};
      for (final c in commitments) {
        minutesByCategory[c.category] = (minutesByCategory[c.category] ?? 0) + c.durationMinutes;
      }
      final topCategory = minutesByCategory.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final highPriorityCount = commitments.where((c) => c.priority == 'High').length;

      return "Context: the student has ${commitments.length} tracked commitments. "
          "${topCategory.key} is currently their heaviest category "
          "(${topCategory.value} minutes). $highPriorityCount are marked high priority.";
    } catch (_) {
      return '';
    }
  }

  Future<void> _ensureChatStarted({required int stressLevel, required int energyLevel}) async {
    if (_chat != null) return;
    final contextSummary = await _buildContextSummary();
    _chat = _getModel().startChat(history: [
      Content.text(
        "My latest check-in: stress $stressLevel/5, energy $energyLevel/5. $contextSummary",
      ),
    ]);
  }

  /// Sends a message in the ongoing chat, starting a new session (seeded
  /// with the student's stress/energy + workload context) on first call.
  Future<String> sendMessage(
    String userText, {
    required int stressLevel,
    required int energyLevel,
  }) async {
    await _ensureChatStarted(stressLevel: stressLevel, energyLevel: energyLevel);
    final response = await _chat!.sendMessage(Content.text(userText));
    return response.text?.trim().isNotEmpty == true
        ? response.text!.trim()
        : "I'm here, but I didn't quite catch a reply there — could you say that again?";
  }

  /// Resets the conversation (e.g. if the user opens the chat again later
  /// with a fresh check-in).
  void reset() {
    _chat = null;
  }
}