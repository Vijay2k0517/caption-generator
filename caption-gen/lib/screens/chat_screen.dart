import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/gradient_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _style = 'Default';
  bool _sending = false;

  final List<String> _styles = const ['Funny', 'Aesthetic', 'Trending', 'Motivational'];

  void _send(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final app = context.read<AppStateProvider>();
    app.addUserMessage(text);
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 700));
    app.addBotMessage(_mockResponse(text));
    setState(() => _sending = false);
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _mockResponse(String text) {
    return '${_style == 'Default' ? '' : '($_style) '}Here are some caption ideas for "$text":\n'
        '- Living in the moment ✨\n'
        '- Vibes immaculate 💫\n'
        '- Details that matter 📸';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: app.messages.length,
              itemBuilder: (context, index) {
                final m = app.messages[index];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.black : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('Default'),
                  selected: _style == 'Default',
                  onSelected: (_) => setState(() => _style = 'Default'),
                ),
                const SizedBox(width: 8),
                ..._styles.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: _style == s,
                        onSelected: (_) => setState(() => _style = s),
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask for a caption…',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: GradientButton(
                    label: _sending ? '...' : 'Send',
                    onPressed: _sending ? null : () => _send(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
