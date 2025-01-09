import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

// google_gemini: ^0.1.2  google gimini api key
const apiKey = "AIzaSyDu8b8nBCg5ZzH0WNEGsLLn_Rb4oZYabVI";

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final gemini = GoogleGemini(apiKey: apiKey);
  bool loading = false;
  List<Map<String, String>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  String selectLanguage = 'English'; // Default language

  void _startChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildOptionsMenu(),
    );
  }

  Widget _buildOptionsMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.savings, color: Colors.green),
          title: const Text("Savings Plan"),
          onTap: () => _handleOptionSelection(
            "Savings Plan",
            ["Monthly Income", "Monthly Expenses", "Savings Goal"],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: Colors.blue),
          title: const Text("Income Planner"),
          onTap: () => _handleOptionSelection(
            "Income Planner",
            ["Target Income", "Current Income"],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.track_changes, color: Colors.orange),
          title: const Text("Expense Tracker"),
          onTap: () => _handleOptionSelection(
            "Expense Tracker",
            ["Monthly Income", "Fixed Expenses", "Variable Expenses"],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  void _handleOptionSelection(String title, List<String> fields) {
    Navigator.pop(context);
    _showInputForm(
        title: title,
        fields: fields,
        onSubmit: (inputs) {
          _generateResponse(title.toLowerCase(), inputs);
        });
  }

  void _showInputForm({
    required String title,
    required List<String> fields,
    required Function(Map<String, String> inputs) onSubmit,
  }) {
    final Map<String, TextEditingController> controllers = {
      for (var field in fields) field: TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: controllers[field],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: field,
                          prefixIcon: Icon(
                            Icons.input,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final inputs = {
                            for (var field in fields)
                              field: controllers[field]!.text.trim(),
                          };
                          Navigator.pop(context);
                          onSubmit(inputs);
                        },
                        icon: const Icon(Icons.send),
                        label: const Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _generateResponse(String category, Map<String, String> inputs) async {
    setState(() {
      loading = true;
      chatMessages.add({
        "role": "user",
        "text": "I have $category which $inputs",
      });
    });

    final enrichedQuery = """
Category: $category
Inputs: $inputs
Let show the details, calculation...through $inputs to me reach my $category and give some tips list to help me reach my  $category and to improve it further through my $category.  and respond in $selectLanguage (respond in short and concise).
    """;

    try {
      final response = await gemini.generateFromText(enrichedQuery);
      setState(() {
        loading = false;
        chatMessages.add({
          "role": "bot",
          "text": _sanitizeResponse(response.text),
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
        chatMessages.add({
          "role": "bot",
          "text": "Error: ${e.toString()}",
        });
      });
    }

    _scrollToBottom();
  }

  String _sanitizeResponse(String text) {
    text = text.replaceAll(RegExp(r'\*+'), '');
    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith("#")) {
        lines[i] = lines[i].substring(1).trim();
      }
    }
    return lines.join('\n');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Chat Bot",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Text(selectLanguage),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value != 'Other') {
                    setState(() {
                      selectLanguage = value;
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'English',
                      child: Text('English'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Thai',
                      child: Text('Thai'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Khmer',
                      child: Text('Khmer'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Other',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter language',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectLanguage = value;
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (selectLanguage.isNotEmpty) {
                                Navigator.pop(context); // Close the menu
                                setState(() {
                                  // Finalize the selection
                                  selectLanguage = selectLanguage;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.green, // Green background
                                shape: BoxShape.circle, // Circular shape
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white, // White tick icon
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.language),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: chatMessages.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    final message = chatMessages[index];
                    final isUser = message["role"] == "user";

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color.fromARGB(255, 59, 131, 255)
                              : const Color.fromARGB(255, 170, 207, 251),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isUser ? 12 : 0),
                            topRight: Radius.circular(isUser ? 0 : 12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          message["text"] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (loading)
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator()),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FloatingActionButton.extended(
                  onPressed: _startChat,
                  label: const Text("Start Chat"),
                  icon: const Icon(Icons.play_arrow),
                  backgroundColor: const Color.fromARGB(255, 17, 215, 119),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
