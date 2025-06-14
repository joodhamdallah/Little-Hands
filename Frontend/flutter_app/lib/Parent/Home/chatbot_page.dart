import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../pages/config.dart'; 

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": message});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final res = await http.post(
        Uri.parse('$url/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      final data = jsonDecode(res.body);
      final reply = data['reply'] ?? "لم أتمكن من الرد.";

      setState(() {
        _messages.add({"role": "bot", "text": reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "حدث خطأ أثناء الاتصال."});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFF600A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("مساعد Little Hands"),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: false,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(_messages[index]),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: CircularProgressIndicator(color: Color(0xFFFF600A)),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "اكتب سؤالك...",
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF600A)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
