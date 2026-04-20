import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/log_anonymizer.dart';

class StyleData {
  final String topEmojis;
  final String sentenceTone;
  final String favoriteSlangs;

  StyleData({
    required this.topEmojis,
    required this.sentenceTone,
    required this.favoriteSlangs,
  });
}

class StyleLearningScreen extends StatefulWidget {
  const StyleLearningScreen({super.key});

  @override
  State<StyleLearningScreen> createState() => _StyleLearningScreenState();
}

class _StyleLearningScreenState extends State<StyleLearningScreen> {
  final _logController = TextEditingController();
  bool _isAnalyzing = false;
  StyleData? _analyzedData;

  Future<void> _analyzeStyle() async {
    if (_logController.text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // 1. Locally filter logs (Email, Phone, Address)
    final anonymizedLogs = LogAnonymizer.filter(_logController.text);
    debugPrint("FanSync AI: Logs anonymized for secure processing.");

    // 2. Simulate AI Analysis (Passing anonymized text to AI)
    await Future.delayed(const Duration(seconds: 3));

    // For now, we simulate extraction. In a real app, this would call Gemini.
    setState(() {
      _isAnalyzing = false;
      _analyzedData = StyleData(
        topEmojis: "✨ 💞 💋 🤫",
        sentenceTone: "친근하고 애교 섞인 반말 (부드러운 타메구치)",
        favoriteSlangs: "Slay, Bestie, ~나노, ~카시라",
      );
    });

    // Auto-redirect to analysis results
    if (mounted) {
      Navigator.pushNamed(context, '/style-analysis');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Style analysis complete! Tokens applied to AI.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Chat Style Learning', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildLogInput(),
                const SizedBox(height: 32),
                if (_isAnalyzing)
                  _buildAnalyzingIndicator()
                else if (_analyzedData != null)
                  _buildStyleSummary(_analyzedData!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Clone: Replicate Your Voice',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload 50-100 previous chat messages to let the AI learn your unique emoji density, sentence length, and favorite slang.',
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLogInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          TextField(
            controller: _logController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Paste your chat logs here (Fans vs You)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeStyle,
                    icon: const Icon(Icons.bolt),
                    label: Text('Analyze & Update Style', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {}, // File Picker Logic
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import JSON/CSV'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    foregroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          Text('AI is extracting your linguistic patterns...', style: GoogleFonts.inter(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStyleSummary(StyleData data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.blue.shade50]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.purple, size: 32),
              const SizedBox(width: 16),
              Text('Style Analysis Summary', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _summaryTile('Top Emojis', data.topEmojis, Icons.emoji_emotions_outlined),
          _summaryTile('Sentence Tone', data.sentenceTone, Icons.record_voice_over_outlined),
          _summaryTile('Favorite Slang', data.favoriteSlangs, Icons.short_text_rounded),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.purple.shade300),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
