import 'dart:async';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'chat_api_service.dart';

class ChatViewModel {
  final Function onUpdate;
  final List<types.Message> messages = [];
  final types.User user = const types.User(id: 'user');
  final types.User assistant = const types.User(id: 'assistant');
  bool isTyping = false;
  String? errorMessage;
  final _uuid = const Uuid();
  StreamSubscription<String>? _streamSub;

  ChatViewModel({required this.onUpdate});

  void initConversation() {
    messages.clear();
    errorMessage = null;
    messages.add(types.TextMessage(
      id: _uuid.v4(),
      author: assistant,
      text: 'Welcome to AI Hotel Chat! How can I help you today?',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    onUpdate();
  }

  void restartChat() {
    _streamSub?.cancel();
    initConversation();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    errorMessage = null;
    final userMsg = types.TextMessage(
      id: _uuid.v4(),
      author: user,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    messages.insert(0, userMsg);
    isTyping = true;
    onUpdate();
    try {
      final history = messages.reversed.map((msg) => {
        'role': msg.author.id == 'user' ? 'user' : 'assistant',
        'content': (msg as types.TextMessage).text,
        'timestamp': DateTime.fromMillisecondsSinceEpoch(msg.createdAt!).toIso8601String(),
      }).toList();
      String assistantText = '';
      _streamSub = ChatApiService.sendMessageStream(
        query: text,
        conversationHistory: history,
        onData: (chunk) {
          if (chunk == '[DONE]') return;
          assistantText += chunk;
          if (messages.isNotEmpty && messages.first.author.id == 'assistant' && messages.first.id == 'streaming') {
            messages[0] = types.TextMessage(
              id: 'streaming',
              author: assistant,
              text: assistantText,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            );
          } else {
            messages.insert(0, types.TextMessage(
              id: 'streaming',
              author: assistant,
              text: assistantText,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
          }
          onUpdate();
        },
        onDone: () {
          isTyping = false;
          if (messages.isNotEmpty && messages.first.id == 'streaming') {
            messages[0] = types.TextMessage(
              id: _uuid.v4(),
              author: assistant,
              text: assistantText,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            );
          }
          onUpdate();
        },
        onError: (e) {
          isTyping = false;
          errorMessage = 'Network error: $e';
          onUpdate();
        },
      );
    } catch (e) {
      isTyping = false;
      errorMessage = 'Error: $e';
      onUpdate();
    }
  }

  void dispose() {
    _streamSub?.cancel();
  }
} 