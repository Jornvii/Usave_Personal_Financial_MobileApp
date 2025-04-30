import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_db.dart';
import '../provider/langguages_provider.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  @override
  _UserProfileWidgetState createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  String? _username;
  final UserDB _userDB = UserDB();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/logoapp.png'),
                ),
              ),
              Text("Usave",style: TextStyle(    fontWeight: FontWeight.w900,fontSize: 24),)
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.account_box),
          title: Text(languageProvider.translate('name')),
          subtitle: Text(
            _username ?? languageProvider.translate('default_username'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showEditDialog(languageProvider),
          ),
        ),
      ],
    );
  }
}
