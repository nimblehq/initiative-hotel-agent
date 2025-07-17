import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:async';
import 'chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(onUpdate: () => setState(() {}));
    _viewModel.initConversation();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) {
    _viewModel.sendMessage(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hotel Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Chat',
            onPressed: () => _viewModel.restartChat(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Chat(
            key: _listKey,
            messages: _viewModel.messages,
            onSendPressed: _handleSendPressed,
            user: _viewModel.user,
            showUserAvatars: true,
            showUserNames: true,
            isAttachmentUploading: false,
            inputOptions: const InputOptions(),
          ),
          if (_viewModel.isTyping)
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text('Assistant is typing...'),
                ],
              ),
            ),
          if (_viewModel.errorMessage != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 