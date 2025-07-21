import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'chat_view_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  final TextEditingController _inputController = TextEditingController();

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

  void _sendUserMessage() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _viewModel.sendMessage(text);
      _inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerGradient = const LinearGradient(
      colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final bool showQuickSearches = _viewModel.messages.length == 1 &&
        _viewModel.messages.first.author.id == 'assistant' &&
        (_inputController.text.isEmpty);
    return Scaffold(
      backgroundColor: const Color(0xFF23293a),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: const Color(0xFF23293a),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: headerGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('🏨', style: TextStyle(fontSize: 32)),
                                SizedBox(width: 12),
                                Text(
                                  'Hotel Price Finder',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Find the cheapest hotel deals',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Quick Searches
                      if (showQuickSearches) ...[
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 16, left: 24, right: 24, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Quick searches:',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: _quickSearchButton(
                                          'Paris Next Weekend')),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child:
                                          _quickSearchButton('Tokyo December')),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child:
                                          _quickSearchButton('London Budget')),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child:
                                          _quickSearchButton('Orlando Family')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Conversation label and message list
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 16, left: 24, right: 24, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '💬 Conversation',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      // Message list should expand to fill available space
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: ListView.builder(
                            reverse: true,
                            itemCount: _viewModel.messages.length,
                            itemBuilder: (context, index) {
                              final message = _viewModel.messages[index];
                              final isAssistant =
                                  message.author.id == 'assistant';
                              if (isAssistant) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF23293a),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: MarkdownBody(
                                    data: (message as types.TextMessage).text,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      h2: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      strong: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      listBullet: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7F7FD5),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    (message as types.TextMessage).text,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      if (_viewModel.isTyping)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF7F7FD5),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Assistant is typing...',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      if (_viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Material(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
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
                      // Input and button always at the bottom
                      if (_viewModel.inputEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  onSubmitted: (value) {
                                    _sendUserMessage();
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Type your message...',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    filled: true,
                                    fillColor: const Color(0xFF23293a),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Color(0xFF7F7FD5), width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Color(0xFF7F7FD5), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  cursorColor: const Color(0xFF7F7FD5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send,
                                    color: Color(0xFF7F7FD5)),
                                onPressed: _sendUserMessage,
                              ),
                            ],
                          ),
                        ),
                      // Divider line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Divider(
                          color: Colors.white24,
                          thickness: 1,
                          height: 0,
                        ),
                      ),
                      // New Search button at the very bottom
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              _viewModel.restartChat();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7F7FD5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text('New Search',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickSearchButton(String label) {
    final pastelGradient = const LinearGradient(
      colors: [Color(0xFFa7ffeb), Color(0xFFffe0f7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        _viewModel.sendMessage(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: pastelGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF23293a),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
