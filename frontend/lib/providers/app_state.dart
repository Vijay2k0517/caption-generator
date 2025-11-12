import 'dart:io';

import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' or 'bot'
  final String text;

  ChatMessage({required this.id, required this.role, required this.text});
}

class AppStateProvider extends ChangeNotifier {
  File? selectedImage;
  final List<ChatMessage> messages = [];
  final List<String> savedCaptions = [];

  void setImage(File? file) {
    selectedImage = file;
    notifyListeners();
  }

  void addUserMessage(String text) {
    messages.add(ChatMessage(id: UniqueKey().toString(), role: 'user', text: text));
    notifyListeners();
  }

  void addBotMessage(String text) {
    messages.add(ChatMessage(id: UniqueKey().toString(), role: 'bot', text: text));
    notifyListeners();
  }

  void saveCaption(String caption) {
    if (!savedCaptions.contains(caption)) {
      savedCaptions.add(caption);
      notifyListeners();
    }
  }

  void clearChat() {
    messages.clear();
    notifyListeners();
  }
}
