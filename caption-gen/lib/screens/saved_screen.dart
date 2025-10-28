import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<AppStateProvider>().savedCaptions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: saved.isEmpty
            ? const Center(child: Text('No saved captions yet'))
            : ListView.separated(
                itemCount: saved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: Text(saved[index]),
                  );
                },
              ),
      ),
    );
  }
}
