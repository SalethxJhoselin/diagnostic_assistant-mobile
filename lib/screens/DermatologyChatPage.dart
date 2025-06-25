import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../components/customAppBar.dart';
import '../services/dermatologyChatService.dart';

class DermatologyChatPage extends StatefulWidget {
  const DermatologyChatPage({super.key});

  @override
  State<DermatologyChatPage> createState() => _DermatologyChatPageState();
}

class _DermatologyChatPageState extends State<DermatologyChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: const Uuid().v4(),
      text:
          'Hola 👋, soy tu asistente dermatológico. ¿En qué puedo ayudarte hoy?',
      sender: 'bot',
    ),
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final inputText = _controller.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(id: const Uuid().v4(), text: inputText, sender: 'user'),
      );
      _isLoading = true;
      _controller.clear();
    });

    final response = await DermatologyChatService.sendMessage(
      prompt: inputText,
    );

    setState(() {
      _messages.add(
        _ChatMessage(
          id: const Uuid().v4(),
          text:
              response ?? 'Lo siento, ocurrió un error al procesar tu mensaje.',
          sender: 'bot',
        ),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: const CustomAppBar(title1: 'Asistente Dermatológico'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.sender == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: msg.sender == 'user'
                          ? Colors.teal
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.sender == 'user'
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu consulta dermatológica...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String id;
  final String text;
  final String sender;

  _ChatMessage({required this.id, required this.text, required this.sender});
}
