import 'package:flutter/material.dart';
import '../Services/mentor_service.dart';

class MentorScreen extends StatefulWidget {
  final String? initialMessage;

  const MentorScreen({super.key, this.initialMessage});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty)
      _sendMessageFromInit(widget.initialMessage!.trim());


  }

  Future<void> _sendMessageFromInit(String text) async {
    setState(() {
      _messages.add({'role' : 'user', 'content' : text});
      _isLoading = true;
    });

    final reply = await MentorService().getMentorReply(text);

    setState(() {
      if (reply != null) {
        _messages.add({'role': 'mentor', 'content': reply});
      }
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _controller.clear();
    });

    final reply = await MentorService().getMentorReply(text);

    setState(() {
      if (reply != null) {
        _messages.add({'role': 'mentor', 'content': reply});
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentor Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: isUser ? BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(3))
                          : BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(3)),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9.0,9.0, 9.0, 18.0),
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
                      maxLines: null, // unlimited but capped by parent
                      decoration: const InputDecoration(
                        hintText: "Ask something about this job...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                      ),
                    ),
                  ),

                  // 🚀 Submit Button

                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      shape:  BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: () {
                        _sendMessage();
                      },
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
