import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/screens/setting_screen.dart';

class SettingUi extends StatefulWidget {
  const SettingUi({super.key});

  @override
  State<SettingUi> createState() => _SettingUiState();
}

class _SettingUiState extends State<SettingUi> {
  void _onMenuItemClick(String title) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Clicked: $title')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Setting',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        'Jii Vorn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(Icons.more_vert),
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
                    Icons.category,
                    'Category',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.lightBlue),
                _buildMenuItem(
                    context,
                    Icons.paid,
                    'Currency',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.green),
                _buildMenuItem(
                    context,
                    Icons.savings,
                    'Saving Goal',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.orange),
                _buildMenuItem(
                    context,
                    Icons.leaderboard,
                    'Data ',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.orange),
                _buildMenuItem(
                    context,
                    Icons.table_chart,
                    'Saved',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.pink.shade300),
                _buildMenuItem(
                    context,
                    Icons.delete_outline,
                    'Trash bin',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
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
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.red),
                _BuildSecMenuItem(
                    context,
                    Icons.delete_forever,
                    'Clear Data',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        ),
                    Colors.redAccent),
                _BuildSecMenuItem(
                    context,
                    Icons.code,
                    'About Me',
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap, Color menucolor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Colors.blue,
          width: 1 / 10,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: menucolor),
              const SizedBox(height: 8),
              Text(
                title,
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
