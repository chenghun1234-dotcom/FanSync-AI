import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class ContentStudioScreen extends StatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen> {
  html.File? _selectedFile;
  String? _imageUrl;
  final _watermarkController = TextEditingController(text: 'FanSync AI');
  bool _isAnalyzing = false;
  String _analysisResult = '';

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    if (input.files!.isNotEmpty) {
      setState(() {
        _selectedFile = input.files![0];
        _imageUrl = html.Url.createObjectUrlFromBlob(_selectedFile!);
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageUrl == null) return;
    setState(() {
      _isAnalyzing = true;
      _analysisResult = 'AI is analyzing your content...';
    });

    // In a real scenario, this would communicate with background.js or Gemini API directly
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isAnalyzing = false;
      _analysisResult = """
[INSTAGRAM]
Caption: Capturing the perfect moment. ✨ #aesthetic #lifestyle #creator
Hashtags: #trending #viral #photography #onlyfansmodel #contentcreator...
Suggested Music: "Midnight City" - M83

[X]
Hook: You won't believe what happens next. 🤫
Keywords: #Exclusive #Trending #Spicy

[ONLYFANS]
Teaser: A little something special just for you...
Suggested PPV: \$15.00
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Content Studio & Watermark', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Row(
        children: [
          _buildEditorArea(),
          const VerticalDivider(width: 1),
          _buildAnalysisArea(),
        ],
      ),
    );
  }

  Widget _buildEditorArea() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1. Media Preview', 'Upload your image to apply watermarks'),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _imageUrl == null
                    ? _buildUploadPlaceholder()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(_imageUrl!, fit: Colors.contain),
                          _buildWatermarkOverlay(),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildWatermarkControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return InkWell(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blue[300]),
          const SizedBox(height: 16),
          Text('Click to upload image', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('JPG, PNG up to 10MB', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWatermarkOverlay() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _watermarkController.text,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWatermarkControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _watermarkController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Watermark Text',
                hintText: 'e.g. @Username',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: () {}, // Save/Download logic
            icon: const Icon(Icons.download),
            label: const Text('Save Protected Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisArea() {
    return Expanded(
      flex: 2,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('2. AI Content Analysis', 'Platform-ready captions & metadata'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _imageUrl == null || _isAnalyzing ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008FDB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[200],
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Analyze Multi-Platform Content'),
              ),
            ),
            const SizedBox(height: 32),
            if (_analysisResult.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _analysisResult,
                    style: GoogleFonts.firaCode(fontSize: 14, height: 1.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}
