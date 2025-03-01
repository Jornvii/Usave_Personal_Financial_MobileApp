import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';



class BotBotScreen extends StatefulWidget {
  const BotBotScreen({super.key});

  @override
  _BotBotScreenState createState() => _BotBotScreenState();
}

class _BotBotScreenState extends State<BotBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  GenerativeModel? _model;
  ChatSession? _chat;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    const apiKey = 'AIzaSyDP9iwhVwLh0_32bdcoQI_obhsyJF9r5oE';
    if (apiKey.isEmpty) {
      stderr.writeln('No API key provided');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash-thinking-exp-01-21',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 65536,
        responseMimeType: 'text/plain',
      ),
    );
    _chat = _model!.startChat(history: []);
  }

  void _sendMessage(String message) async {
    if (_chat == null || message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
      _controller.clear();
    });

    final content = Content.text(message);
    try {
      final response = await _chat!.sendMessage(content);
      setState(() {
        _messages.add('Bot: ${response.text ?? "No response"}');
      });
    } catch (e) {
      setState(() {
        _messages.add('Bot: Error occurred');
      });
      stderr.writeln('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Chat Bot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
