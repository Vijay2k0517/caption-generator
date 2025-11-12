import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/caption_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isGenerating = false;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      context.read<AppStateProvider>().setImage(File(picked.path));
    }
  }

  Future<void> _showSourceSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SourceButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
                _SourceButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateCaption(BuildContext context) async {
    final app = context.read<AppStateProvider>();
    if (app.selectedImage == null) return;
    setState(() => _isGenerating = true);
    try {
      final captions = await ApiService.generateCaptions(app.selectedImage!);
      final generated =
          captions.isNotEmpty ? captions.first : 'No caption generated';
      setState(() => _isGenerating = false);

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => CaptionSheet(
          caption: generated,
          onCopy: () {},
          onRegenerate: () {
            Navigator.pop(context);
            _generateCaption(context);
          },
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate: $e')),
      );
    }
  }

  // Removed mock generator; now using backend

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('Create your perfect caption',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showSourceSheet(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                  gradient: app.selectedImage == null
                      ? AppTheme.instagramGradient
                      : null,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: app.selectedImage == null
                        ? Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppTheme.instagramGradient,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 48, color: Colors.white),
                                SizedBox(height: 8),
                                Text('Upload image',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : Image.file(app.selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: _isGenerating ? 'Generating…' : 'Generate Caption',
              onPressed: app.selectedImage == null || _isGenerating
                  ? null
                  : () => _generateCaption(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
