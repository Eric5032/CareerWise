import 'dart:convert';
import 'package:career_guidance/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/mentor_service.dart';

class MentorScreen extends StatefulWidget {
  final String? jobName;
  final String? initialMessage;
  final String? historyId;

  const MentorScreen({super.key, this.jobName, this.initialMessage, this.historyId});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String get _chatKey => 'mentor_chat_history${widget.historyId != null ? "_${widget.historyId}" : ""}';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      print(" THIS IS THE INITIAL MESSAGE: ${widget.initialMessage}");
      _sendMessageFromInit(widget.jobName!, widget.initialMessage!.trim());
    } else {
      _loadChatHistory();
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

  Future<void> _sendMessageFromInit(String jobName, String text) async {
    print("THIS IS THE TEXT INSIDE SENDMESS FROM INIT: $text");
    await _loadChatHistory();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final reply = await MentorService().getMentorReply(jobName, text);

    setState(() {
      if (reply != null) {
        _messages.add({'role': 'mentor', 'content': reply});
      } else {
        _messages.add({'role': 'mentor', 'content': 'Sorry — no reply received.'});
      }
      _isLoading = false;
    });
    await _saveChatHistory();
    await _loadChatHistory();
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

    final reply = await MentorService().getMentorReply("", text);

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
            colors: [Colors.lightBlue.shade600, Colors.lightBlue.shade700],
          )
              : LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade50],
          ),
          borderRadius: isUser
              ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(4),
          )
              : const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: (isUser ? Colors.lightBlue : Colors.grey).withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.grey.shade800,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade100],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.lightBlue.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Start a Conversation",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Ask anything about your career path, job prospects, or any questions you have!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: kSurfaceLight,
        appBar: AppBar(
          title: Text(
            "Mentor",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          backgroundColor: kSurfaceLight,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [

            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Clear chat",
              onPressed: _isLoading
                  ? null
                  : () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      "Clear chat?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      "This will delete your chat history permanently.",
                      style: TextStyle(height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) await _clearChat();
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue.shade600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Thinking...",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightBlue.shade50,
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                              decoration: InputDecoration(
                                hintText: "Ask something about this job...",
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isLoading
                                    ? [Colors.grey.shade300, Colors.grey.shade400]
                                    : [Colors.lightBlue.shade600, Colors.lightBlue.shade700],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (!_isLoading)
                                  BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded),
                              color: Colors.white,
                              iconSize: 20,
                              onPressed: _isLoading ? null : _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}