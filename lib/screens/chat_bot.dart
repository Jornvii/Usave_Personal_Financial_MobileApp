import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

const apiKey = "AIzaSyDVxpqdwdpaP2lfWVF8XfNCv9fAcvxwmS8";

class ChatBotTab extends StatefulWidget {
  const ChatBotTab({super.key});

  @override
  State<ChatBotTab> createState() => _ChatBotTabState();
}

class _ChatBotTabState extends State<ChatBotTab> {
  bool loading = false;
  final List<Map<String, String>> textChat = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final gemini = GoogleGemini(apiKey: apiKey);

  void fromText({required String query}) {
    setState(() {
      loading = true;
      textChat.add({"role": "user", "text": query});
      _textController.clear();
    });
    scrollToTheEnd();

    gemini.generateFromText(query).then((value) {
      setState(() {
        loading = false;
        final cleanText = value.text.replaceAll(RegExp(r'\*+'), '');
        textChat.add({"role": "bot", "text": cleanText, "animated": "true"});
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({"role": "bot", "text": error.toString(), "animated": "false"});
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final errorColor = theme.colorScheme.error;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: textChat.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final isUser = textChat[index]["role"] == "user";
                final isAnimated = textChat[index]["animated"] == "true";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? primaryColor.withOpacity(0.2) : secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? "You" : "Bot",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUser ? primaryColor : secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        isUser
                            ? Text(
                                textChat[index]["text"] ?? "",
                                style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium!.color),
                              )
                            : isAnimated
                                ? AnimatedTextKit(
                                    isRepeatingAnimation: false,
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        textChat[index]["text"] ?? "",
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          color: theme.textTheme.bodyMedium!.color,
                                        ),
                                        speed: const Duration(milliseconds: 50),
                                      ),
                                    ],
                                    onFinished: () {
                                      setState(() {
                                        textChat[index]["animated"] = "false";
                                      });
                                    },
                                  )
                                : Text(
                                    textChat[index]["text"] ?? "",
                                    style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium!.color),
                                  ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: theme.colorScheme.secondary.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: loading
                      ? null
                      : () {
                          if (_textController.text.trim().isNotEmpty) {
                            fromText(query: _textController.text);
                          }
                        },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: loading ? errorColor : primaryColor,
                    child: loading
                        ? CircularProgressIndicator(color: theme.scaffoldBackgroundColor)
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
