import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  String _selectedPersona = 'Friendly & Flirty';
  String _selectedLanguage = 'Japanese';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // In a real browser extension, we might use chrome.storage.local
    // but for the Flutter dashboard, we'll use Supabase or local storage.
    // For now, let's assume we're managing the 'Model' profile.
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    // Logic to save to Supabase and sync with Extension
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('AI Persona Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure your AI Brain',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your Gemini API key and choose how the AI interacts with your fans.',
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                _buildLabel('Gemini API Key'),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  decoration: _inputDecoration('Enter your API Key'),
                ),
                const SizedBox(height: 24),
                _buildLabel('AI Persona'),
                _buildDropdown(
                  ['Friendly & Flirty', 'Professional', 'Tsundere (Japanese Only)', 'Playful'],
                  _selectedPersona,
                  (val) => setState(() => _selectedPersona = val!),
                ),
                const SizedBox(height: 24),
                _buildLabel('Target Language'),
                _buildDropdown(
                  ['Japanese', 'English (Slang Optimized)', 'Korean'],
                  _selectedLanguage,
                  (val) => setState(() => _selectedLanguage = val!),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008FDB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Save Configuration', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }
}
