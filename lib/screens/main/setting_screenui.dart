import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/sub/appearance_screen.dart';
import 'package:flutter_chat_bot/widgets/add_currency.dart';
import 'package:provider/provider.dart';
import '../../models/chat_db.dart';
import '../../models/transaction_db.dart';
import '../../provider/langguages_provider.dart';
import '../../models/profile_db.dart';
import '../sub/addcategory_screen.dart';
import '../sub/dev_pf.dart';
import '../sub/opensource_screen.dart';
import '../sub/trashbin_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 200,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logoapp.png'),
                  ),
                ),
                _buildAnimatedText()
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Card(
                    elevation: 5,
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ListTile(
                          leading: Icon(Icons.person,
                              color: Theme.of(context).iconTheme.color),
                          title: Text(
                            _username ??
                                languageProvider.translate('default_username'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontSize: 18),
                          ),
                          trailing: IconButton(
                            icon: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.7),
                              child: Icon(Icons.edit,
                                  color: Theme.of(context).iconTheme.color),
                            ),
                            onPressed: () => _showEditDialog(languageProvider),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                //  Grid Items
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1,
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
                        const Color.fromARGB(255, 61, 196, 65)),
                    _buildMenuItem(
                        context,
                        languageProvider,
                        Icons.delete,
                        'Trashbin',
                        () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TrashBinScreen()),
                            ),
                        Colors.red),
                  ],
                ),
                const SizedBox(height: 5),
                //  Grid Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _BuildSecMenuItem(
                            context,
                            Icons.tune,
                            languageProvider,
                            'appearance',
                            () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AppearanceScreen()),
                                ),
                            Colors.amber);
                      case 1:
                        return _BuildSecMenuItem(
                            context,
                            Icons.delete_forever,
                            languageProvider,
                            'delete_data',
                            () => _showDeleteOptionsDialog(
                                context, languageProvider),
                            const Color.fromARGB(255, 221, 25, 11));
                      // case 1:
                      //   return _BuildSecMenuItem(
                      //       context,
                      //       Icons.delete_forever,
                      //       languageProvider,
                      //       'delete_data',
                      //       () => _showDeleteOptionsDialog(
                      //           context, languageProvider),
                      //       const Color.fromARGB(255, 221, 25, 11));
                      case 2:
                        return _BuildSecMenuItem(
                            context,
                            Icons.code,
                            languageProvider,
                            'AboutMe',
                            () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DevPfScreen()),
                                ),
                            Colors.blueAccent);
                      case 3:
                        return _BuildSecMenuItem(
                            context,
                            Icons.error,
                            languageProvider,
                            'OpenSource',
                            () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const OpenSourceScreen()),
                                ),
                            const Color.fromARGB(255, 47, 111, 96));
                      default:
                        return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  List<MaterialColor> colorizeColors = [
    Colors.green,
    Colors.yellow,
  ];

  TextStyle colorizeTextStyle = const TextStyle(
    fontSize: 32,
  );

  Widget _buildAnimatedText() {
    return AnimatedTextKit(
      animatedTexts: [
        ColorizeAnimatedText(
          'iSAVE',
          textStyle: colorizeTextStyle.copyWith(fontWeight: FontWeight.bold),
          colors: colorizeColors,
        ),
      ],
      isRepeatingAnimation: true,
    );
  }

  Widget _BuildSecMenuItem(
    BuildContext context,
    IconData secicon,
    LanguageProvider languageProvider,
    String sectitle,
    VoidCallback onTap,
    Color secmenucolor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: secmenucolor.withOpacity(0.1),
              border: Border.all(
                width: 0.5,
                color: secmenucolor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(secicon, size: 20, color: secmenucolor),
              title: Text(
                languageProvider.translate(sectitle),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold
                    // color: Colors.black87,
                    ),
              ),
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
      elevation: 4, // Slightly higher elevation for better depth
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent border radius
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 0.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                menuColor.withOpacity(0.9),
                menuColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    languageProvider.translate(titleKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(languageProvider.translate('warning')),
                      content: Text(
                          languageProvider.translate('delete_forever_warning')),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _deleteAllData(context, languageProvider);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              languageProvider.translate('confirm_delete')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(languageProvider.translate('cancel')),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(languageProvider.translate('delete_all')),
            ),
            // TextButton(
            //   onPressed: () {
            //     _deleteChatData(context, languageProvider);
            //     Navigator.of(context).pop();
            //   },
            //   child: Text(languageProvider.translate('delete_chat')),
            // ),
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
    try {
      await TransactionDB().resetDatabase();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(languageProvider.translate('all_data_cleared'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(languageProvider.translate('error_deleting_data'))),
      );
    }
  }
}
