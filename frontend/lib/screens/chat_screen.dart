import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api.dart';
import '../services/auth_service.dart';
import 'conversation_history_screen.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' or 'bot'
  final String? text;
  final List<String>? captions;
  final File? image;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    this.text,
    this.captions,
    this.image,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final List<ChatMessage> _messages = [];

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadOrCreateConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrCreateConversation() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      // Create a new conversation
      await ApiService.createConversation(token);
      // Conversation created successfully
      setState(() {});
    } catch (e) {
      _showError('Failed to initialize conversation: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // Add user message with image
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          role: 'user',
          text: 'Generate captions for this image',
          image: imageFile,
        ));
      });

      _scrollToBottom();
      await _generateCaptions(imageFile);
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _generateCaptions(File imageFile) async {
    setState(() => _isGenerating = true);

    try {
      final captions = await ApiService.generateCaptions(imageFile);

      // Add bot message with captions
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          role: 'bot',
          text: 'Here are your captions:',
          captions: captions,
        ));
        _isGenerating = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isGenerating = false);
      _showError('Failed to generate captions: $e');
    }
  }

  Future<void> _regenerateCaptions(File? imageFile) async {
    if (imageFile == null) {
      _showError('Image not found');
      return;
    }

    // Add a user message indicating regeneration
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        role: 'user',
        text: 'Regenerate captions',
      ));
    });

    _scrollToBottom();
    await _generateCaptions(imageFile);
  }

  Future<void> _saveCaption(String caption) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        _showError('Please login to save captions');
        return;
      }

      await ApiService.saveCaption(token, caption);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caption saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Failed to save caption: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  File? _getLastImage() {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].image != null) {
        return _messages[i].image;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caption Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConversationHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isGenerating && index == _messages.length) {
                        return _buildLoadingMessage();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an image to generate captions',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  message.image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (message.text != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.text!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (message.captions != null && message.captions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...message.captions!.map((caption) => _buildCaptionCard(caption)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _regenerateCaptions(_getLastImage()),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Regenerate'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionCard(String caption) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_outline, size: 20),
                onPressed: () => _saveCaption(caption),
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  // Copy to clipboard
                  Share.share(caption);
                },
                tooltip: 'Share',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Generating captions...'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
