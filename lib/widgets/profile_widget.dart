import 'package:flutter/material.dart';
import '../models/profile_db.dart';

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

  Future<void> _showEditDialog() async {
    TextEditingController _usernameController =
        TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUsername = _usernameController.text.trim();
                await _userDB.saveOrUpdateUserProfile(updatedUsername);

                // Update local state immediately after saving
                setState(() {
                  _username = updatedUsername;
                });

                Navigator.of(context).pop();
                _showSuccessSnackbar();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show success message
  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/logoapp.png'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(
              _username ?? 'Username',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert), // Three-dot menu icon
              onPressed: _showEditDialog,
            )),
      ],
    );
  }
}
