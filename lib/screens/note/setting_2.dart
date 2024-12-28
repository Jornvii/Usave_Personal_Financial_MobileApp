import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/sub/saving_goal_screen.dart';
import 'package:flutter_chat_bot/widgets/add_currency.dart';
import 'package:provider/provider.dart';
import '../../models/chat_db.dart';
import '../../models/transaction_db.dart';
import '../../provider/langguages_provider.dart';
import '../../provider/theme_provider.dart';
import '../../models/profile_db.dart';
import '../../widgets/lsit_summary.dart';
import '../sub/category_screen.dart';

class Setting2Screen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  const Setting2Screen({super.key, required this.transactions});

  @override
  State<Setting2Screen> createState() => _Setting2ScreenState();
}

class _Setting2ScreenState extends State<Setting2Screen> {
  String? _username;
  final UserDB _userDB = UserDB();
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = TransactionDB();
    final data = await db.getTransactions();
    setState(() {
      transactions = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _loadUserProfile() async {
    final userProfile = await _userDB.fetchUserProfile();
    if (userProfile != null) {
      setState(() {
        _username = userProfile['username'];
      });
    }
  }

  Future<void> _showEditDialog(LanguageProvider languageProvider) async {
    final TextEditingController usernameController =
        TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('edit_user_name')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('username'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUsername = usernameController.text.trim();
                await _userDB.saveOrUpdateUserProfile(updatedUsername);
                await _loadUserProfile();
                setState(() {
                  _username = updatedUsername;
                });

                Navigator.of(context).pop();
                _showSuccessSnackbar(languageProvider);
              },
              child: Text(languageProvider.translate('save')),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(LanguageProvider languageProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.translate('profile_updated')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteOptionsDialog(
      BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('delete_data')),
          content: Text(languageProvider.translate('choose_delete_option')),
          actions: [
            TextButton(
              onPressed: () {
                _deleteAllData(context, languageProvider);
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('delete_all')),
            ),
            TextButton(
              onPressed: () {
                _deleteChatData(context, languageProvider);
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('delete_chat')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageProvider.translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _deleteChatData(
      BuildContext context, LanguageProvider languageProvider) async {
    final chatDatabase = ChatDB();
    await chatDatabase.clearMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.translate('chat_data_cleared'))),
    );
  }

  void _deleteAllData(
      BuildContext context, LanguageProvider languageProvider) async {
    final transactionDb = TransactionDB();
    await transactionDb.clearTransactions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.translate('all_data_cleared'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          languageProvider.translate('settings'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/logoapp.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              "iSAVE",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blue, width: 1),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    _username ?? languageProvider.translate('default_username'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(languageProvider),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              children: [
                _buildMenuItem(
                  context,
                  languageProvider,
                  Icons.category,
                  'category',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoryScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  languageProvider,
                  Icons.paid,
                  'currency',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CurrencyScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  languageProvider,
                  Icons.savings,
                  'savingGoal',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SavingGoalScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  languageProvider,
                  Icons.leaderboard,
                  'summary',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListSummaryScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, LanguageProvider languageProvider,
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              languageProvider.translate(label),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
