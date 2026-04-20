import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyleAnalysisScreen extends StatelessWidget {
  const StyleAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('AI Style Insight', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLearningProgressCard(),
                const SizedBox(height: 32),
                Text('Linguistic Breakdown', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildStyleInsightGrid(),
                const SizedBox(height: 32),
                _buildEmojiFrequency(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningProgressCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Style Mirroring Accuracy', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('92%', style: GoogleFonts.outfit(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.92,
              minHeight: 12,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The AI has successfully replicated your unique writing patterns with high fidelity. It is ready to respond on your behalf.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleInsightGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _insightTile('Sentence Length', 'Short & Punchy', Icons.short_text),
        _insightTile('Tone and Manner', 'Tsundere / Teasing', Icons.favorite_border_rounded),
        _insightTile('Target Region', 'Japan (Tokyo Slang)', Icons.language_rounded),
        _insightTile('Response Speed', 'Instant-Sync Active', Icons.bolt_rounded),
      ],
    );
  }

  Widget _insightTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmojiFrequency() {
    final emojis = ['✨', '💖', '😜', '🎀', '🤫', '🔥', '💎', '🍬'];
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habituated Emojis', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: emojis.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(e, style: const TextStyle(fontSize: 24)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
