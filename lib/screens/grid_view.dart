import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/appearance_screen.dart';
import 'package:flutter_chat_bot/screens/saving_goal_screen.dart';
import 'package:flutter_chat_bot/widgets/add_currency.dart';
import 'package:provider/provider.dart';
import '../models/chat_db.dart';
import '../models/transaction_db.dart';
import '../provider/langguages_provider.dart';
import '../provider/theme_provider.dart';
import '../models/profile_db.dart';
import '../widgets/lsit_summary.dart';
import '../widgets/table_transactions.dart';
import 'category_screen.dart';
import 'dev_pf.dart';
import 'trashbin_screen.dart';

class SettingScreenUi extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  const SettingScreenUi({super.key, required this.transactions});

  @override
  State<SettingScreenUi> createState() => _SettingScreenUiState();
}

class _SettingScreenUiState extends State<SettingScreenUi> {
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


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          languageProvider.translate('settings'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/logoapp.png'),
                    ),
                  ),
                  Text(
                    "iSAVE",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Padding(
            //   padding: const EdgeInsets.only(left: 15, right: 15),
            //   child: Container(
            //     decoration: BoxDecoration(
            //         border: Border.all(width: 0.8, color: Colors.grey),
            //         borderRadius: BorderRadius.circular(15)),
            //     child: const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: ListTile(
            //         leading: Icon(Icons.person),
            //         title: Text(
            //           'Jii Vorn',
            //           style:
            //               TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //         ),
            //         trailing: Icon(Icons.more_vert),
            //       ),
            //     ),
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      // title: Text(languageProvider.translate('name')),
                      title: Text(
                        _username ??
                            languageProvider.translate('default_username'),
                        style: const TextStyle(
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showEditDialog(languageProvider),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            //  Grid Items
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              padding: const EdgeInsets.all(8),
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
                  Colors.lightBlue,
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
                    Colors.green),
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
                    Colors.orange),
                _buildMenuItem(
                    context,
                    languageProvider,
                    Icons.leaderboard,
                    'datatotal',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListSummaryScreen()),
                        ),
                    Colors.orange),
                _buildMenuItem(
                    context,
                    languageProvider,
                    Icons.table_chart,
                    'dataTable',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DataTransactionTable(
                                transactions:
                                    transactions), // Pass the data here
                          ),
                        ),
                    Colors.pink.shade300),
                _buildMenuItem(
                    context,
                    languageProvider,
                    Icons.delete_outline,
                    'Trashbin',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TrashBinScreen()),
                        ),
                    Colors.red),
              ],
            ),
            const Divider(
              height: 20.0,
              thickness: 1 / 2,
              color: Color.fromARGB(255, 17, 215, 119),
              indent: 25.0,
              endIndent: 25.0,
            ),
            //  Grid Items
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              padding: const EdgeInsets.all(8),
              children: [
                _BuildSecMenuItem(
                    context,
                    Icons.tune,
                    'Appearance',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AppearanceScreen()),
                        ),
                    Colors.red),
                _BuildSecMenuItem(
                    context,
                    Icons.delete_forever,
                    'delete_data',
                    () => _showDeleteOptionsDialog(context, languageProvider),
                    Colors.redAccent),
                _BuildSecMenuItem(
                    context,
                    Icons.code,
                    'About Me',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DevPfScreen()),
                        ),
                    Colors.red),
              ],
            ),
            // const ListTile(
            //   leading: Icon(Icons.help_outline),
            //   title: Text('About Us'),
            //   trailing: Icon(Icons.arrow_forward_ios_outlined),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _BuildSecMenuItem(
    BuildContext context,
    IconData secicon,
    String sectitle,
    VoidCallback onTap,
    Color secmenucolor,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.blue,
          width: 0.1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: ListTile(
          leading: Icon(secicon, size: 25, color: secmenucolor),
          title: Text(
            sectitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    LanguageProvider languageProvider,
    IconData icon,
    String titleKey,
    VoidCallback onTap,
    Color menuColor,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.blue,
          width: 0.1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: menuColor),
              const SizedBox(height: 8),
              Text(
                languageProvider.translate(titleKey),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  // Clear all data from the database
  // await TransactionDB().clearTransactions();

// Show a confirmation message after clearing data
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(languageProvider.translate('all_data_cleared'))),
  );
}
