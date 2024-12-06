import 'package:flutter/material.dart';

class DevPfScreen extends StatelessWidget {
  const DevPfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Developer Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CHIVORN KANG',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'I\'m from BC64 at MBS MSU',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
               RichText(
  textAlign: TextAlign.justify,
  text: const TextSpan(
    children: [
      TextSpan(
        text: 'I’m currently developing ',
        style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
      ),
      TextSpan(
        text: 'iSAVE',
        style: TextStyle(
          color: Colors.blue, 
          fontSize: 14,
          fontWeight: FontWeight.bold, 
        ),
      ),
      TextSpan(
        text: ', a Personal Financial Management Mobile Application that helps users track and manage their finances efficiently.\n'
            'iSave is my final project for my bachelor’s degree and represents my dedication to creating practical, user-friendly solutions. '
            'This project combines my technical skills and creativity, aiming to make financial management accessible and effective for everyone.',
        style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
      ),
    ],
  ),
)

              ],
            ),
          ),
          const SizedBox(height: 24),
          // Section Header
          sectionHeader('About Me'),
          const Divider(),
          buildListTile('My Projects', Icons.folder_special_outlined),
          buildListTile('Skills & Tools', Icons.engineering_outlined),
          buildListTile('Work Experience', Icons.work_outline),
          buildListTile('Education', Icons.school_outlined),
          buildListTileWithBadge(
              'Certifications', Icons.verified_outlined, Colors.green),
          const Divider(),
          // Developer Tools Section
          sectionHeader('Developer Tools'),
          const Divider(),
          buildListTile(
            'GitHub Profile',
            Icons.code,
            subtitle: 'View repositories',
          ),
          buildListTile(
            'LinkedIn',
            Icons.person_search,
            subtitle: 'Professional connections',
          ),
          buildListTile(
            'Stack Overflow',
            Icons.question_answer_outlined,
            subtitle: 'Q&A contributions',
          ),
          buildListTile(
            'Portfolio Website',
            Icons.web_outlined,
            subtitle: 'View my work',
          ),
        ],
      ),
    );
  }

  // Section Header Widget
  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Generic List Tile
  Widget buildListTile(String title, IconData icon, {String? subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  // List Tile with Badge
  Widget buildListTileWithBadge(String title, IconData icon, Color badgeColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }
}
