import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/models/chat_db.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_db.dart';
import '../../provider/langguages_provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  bool loading = false;
  List<Map<String, String>> chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  String selectLanguage = 'English';
  GenerativeModel? _model;
  ChatSession? _chat;
  final TransactionDB transactionDB = TransactionDB();
  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadChatMessages();
  }

  Future<void> _loadChatMessages() async {
    final messages = await ChatDB.instance.fetchChatMessages();
    setState(() {
      chatMessages = messages
          .map((msg) {
            return {
              "role": msg['role'] as String,
              "text": msg['text'] as String,
            };
          })
          .toList()
          .cast<Map<String, String>>();
    });
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

  void _startChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _showChatSelectionMenu(),
    );
  }

  Widget _showChatSelectionMenu() {
    final languageProvider = Provider.of<LanguageProvider>(context);
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
        Text(
          languageProvider.translate("pickChatBot"),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
          ListTile(
          leading:
              const Icon(Icons.account_balance_wallet, color: Colors.orange),
          title: Text(languageProvider.translate("analysisMyTransaction")),
          onTap: () {
            Navigator.pop(context);
            _checkMyTransaction();
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.chat, color: Colors.green),
        //   title: const Text("Ai Bot"),
        //   onTap: () {
        //     Navigator.pop(context); // Close the selection menu
        //     transactionchatBot(); 
        //   },
        // ),
        ListTile(
          leading: const Icon(Icons.lightbulb, color: Colors.blue),
          title: Text(languageProvider.translate("AdviceBot")),
          onTap: () {
            Navigator.pop(context); // Close previous modal
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => _buildOptionsMenu(),
            );
          },
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  void transactionchatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _showTransactionOptions(),
    );
  }

  Widget _showTransactionOptions() {
    final languageProvider = Provider.of<LanguageProvider>(context);
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
        Text(
          languageProvider.translate("GenerateFinanceAdvice"),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading:
              const Icon(Icons.account_balance_wallet, color: Colors.orange),
          title: Text(languageProvider.translate("analysisMyTransaction")),
          onTap: () {
            Navigator.pop(context);
            _checkMyTransaction();
          },
        ),
        ListTile(
          leading: const Icon(Icons.savings, color: Colors.green),
          title: Text(languageProvider.translate("CheckMySaving")),
          // "CheckMySaving"
          onTap: () {
            Navigator.pop(context);
            _checkMySaving();
          },
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Future<void> _checkMyTransaction() async {
    try {
      final transactions = await transactionDB.getTransactions();

      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      double totalSaving = 0.0;
      Map<String, double> categoryExpenses = {};

      for (var transaction in transactions) {
        final type = transaction['typeCategory'];
        final amount =
            (transaction['amount'] as num).toDouble(); // Ensure double
        final category = transaction['category'] ?? "Uncategorized";

        if (type == 'Income') {
          totalIncome += amount;
        } else if (type == 'Expense') {
          totalExpenses += amount;
          categoryExpenses[category] =
              (categoryExpenses[category] ?? 0) + amount;
        } else if (type == 'Saving') {
          totalSaving += amount;
        }
      }

      double balance = totalIncome - totalExpenses;

      // Convert categoryExpenses to String format
      String expenseDetails = categoryExpenses.entries
          .map((e) => "${e.key} \$${e.value.toStringAsFixed(2)}")
          .join(" ");

      // Create financial summary inputs
      Map<String, String> financialData = {
        "Total Income": "\$${totalIncome.toStringAsFixed(2)}",
        "Total Expenses": "\$${totalExpenses.toStringAsFixed(2)}",
        "Total Saving": "\$${totalSaving.toStringAsFixed(2)}",
        "Balance": "\$${balance.toStringAsFixed(2)}",
        "Key Expense Categories": expenseDetails,
      };

      // Call _generateResponse() correctly
      _generateResponse("Your financial summary", financialData);
    } catch (e) {
      print("Error checking transactions: $e");
    }
  }

  void _checkMySaving() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Your Savings"),
          content: const Text("Here is your current savings balance..."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

// ---------------------------------------
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
        const Text(
          "General Finance Advice",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

  void _generateResponse(String category, Map<String, String> inputs) async {
    setState(() {
      loading = true;
      chatMessages.add({
        "role": "user",
        "text":
            " $category with ${inputs.entries.map((e) => "${e.key}: ${e.value}").join(" ")}",
      });
    });

    final enrichedQuery = """
  $category which ${inputs.entries.map((e) => "${e.key}: ${e.value}").join(", ")}. Please provide calculations, suggestions, and improvement tips for my $category. Respond in $selectLanguage concisely.
  """;

    try {
      final content = Content.text(enrichedQuery);
      final response = await _chat!.sendMessage(content);
      final responseText = _sanitizeResponse(response.text ?? "No response");

      // Add the bot response to chatMessages
      setState(() {
        loading = false;
        chatMessages.add({
          "role": "bot",
          "text": responseText,
        });
      });

      // Save the conversation to the database
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await ChatDB.instance.insertChatMessage({
        'role': 'user',
        'text': enrichedQuery,
        'timestamp': currentTime,
      });
      await ChatDB.instance.insertChatMessage({
        'role': 'bot',
        'text': responseText,
        'timestamp': currentTime,
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
                                Navigator.pop(context);
                                setState(() {
                                  selectLanguage = selectLanguage;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
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
                          borderRadius: BorderRadius.circular(12),
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
