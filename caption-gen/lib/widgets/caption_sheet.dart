import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';

class CaptionSheet extends StatelessWidget {
  final String caption;
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;
  const CaptionSheet({super.key, required this.caption, required this.onRegenerate, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Generated Caption', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(caption, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.copy_all_rounded,
                    label: 'Copy',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: caption));
                      onCopy();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caption copied')));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Regenerate',
                    onTap: onRegenerate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.ios_share_rounded,
                    label: 'Share',
                    gradient: AppTheme.instagramGradient,
                    foregroundOnGradient: true,
                    onTap: () async {
                      await Share.share(caption, subject: 'Instagram Caption');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final bool foregroundOnGradient;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient,
    this.foregroundOnGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: gradient == null ? Colors.grey.shade100 : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: foregroundOnGradient ? Colors.white : Colors.black87),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: foregroundOnGradient ? Colors.white : Colors.black)),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}
