// lib/Screens/mentor_screen.dart
import 'dart:convert';
import 'package:career_guidance/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/mentor_service.dart';

class MentorScreen extends StatefulWidget {
  final String? initialMessage;
  final String? historyId;

  const MentorScreen({super.key, this.initialMessage, this.historyId});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  String get _chatKey => 'mentor_chat_history${widget.historyId != null ? "_${widget.historyId}" : ""}';

  @override
  void initState() {
    super.initState();
    _loadChatHistory();

    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessageFromInit(widget.initialMessage!.trim());
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_chatKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        debugPrint('[MentorScreen] no saved chat for key=$_chatKey');
        return;
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        debugPrint('[MentorScreen] saved chat is not a List: ${decoded.runtimeType}');
        return;
      }

      _messages.clear();
      for (final item in decoded) {
        if (item is Map) {
          final role = item['role']?.toString() ?? '';
          final content = item['content']?.toString() ?? '';
          if (role.isNotEmpty && content.isNotEmpty) {
            _messages.add({'role': role, 'content': content});
          }
        } else {
          debugPrint('[MentorScreen] skipping non-Map item in saved chat: ${item.runtimeType}');
        }
      }

      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      debugPrint('[MentorScreen] loaded ${_messages.length} messages');
    } catch (e, st) {
      debugPrint('[MentorScreen] failed to load chat: $e\n$st');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_messages);
      await prefs.setString(_chatKey, jsonString);
      debugPrint('[MentorScreen] saved ${_messages.length} messages for key=$_chatKey');
    } catch (e, st) {
      debugPrint('[MentorScreen] failed to save chat: $e\n$st');
    }
  }

  Future<void> _sendMessageFromInit(String text) async {
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    await _saveChatHistory();
    _scrollToBottom();

    final reply = await MentorService().getMentorReply(text);

    setState(() {
      if (reply != null) {
        _messages.add({'role': 'mentor', 'content': reply});
      } else {
        _messages.add({'role': 'mentor', 'content': 'Sorry — no reply received.'});
      }
      _isLoading = false;
    });
    await _saveChatHistory();
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _controller.clear();
    });
    await _saveChatHistory();
    _scrollToBottom();

    final reply = await MentorService().getMentorReply(text);

    setState(() {
      if (reply != null) {
        _messages.add({'role': 'mentor', 'content': reply});
      } else {
        _messages.add({'role': 'mentor', 'content': 'Sorry — no reply received.'});
      }
      _isLoading = false;
    });

    await _saveChatHistory();
    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatKey);
      setState(() => _messages.clear());
      debugPrint('[MentorScreen] cleared chat for key=$_chatKey');
    } catch (e, st) {
      debugPrint('[MentorScreen] failed to clear chat: $e\n$st');
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } catch (e) {
      }
    });
  }

  Future<void> printSavedRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey);
    debugPrint('[MentorScreen] raw saved ($_chatKey): $raw');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: isUser
              ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(3),
          )
              : const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(3),
          ),
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceLight,
      appBar: AppBar(
        title: const Text("Mentor Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: "Print saved JSON (debug)",
            onPressed: () => printSavedRaw(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear chat",
            onPressed: _isLoading
                ? null
                : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear chat?"),
                  content: const Text("This will delete your chat history."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Clear")),
                  ],
                ),
              );
              if (confirm == true) await _clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9.0, 9.0, 9.0, 18.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: null,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: "Ask something about this job...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading ? Colors.grey.shade400 : Colors.blueAccent,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
