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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Developer Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
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
          child: const Column(
            children: [
              ProfessorProfile(),
              Divider(thickness: 1, height: 30),
              DeveloperProfile(),
            ],
          ),
        ),
      ),
    );
  }
}

// Professor Profile Widget
class ProfessorProfile extends StatelessWidget {
  const ProfessorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Developed Under The Giudance Of',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 12),
        ProfileImage(imagePath: 'assets/images/professor.jpg', radius: 60),
        SizedBox(height: 12),
        Text(
          'Dr. SOMMAI KHANTONG',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        SizedBox(height: 4),
        Text(
          'Director, Computer Center MSU',
          style: TextStyle(color: Colors.blueGrey, fontSize: 18),
        ),
      ],
    );
  }
}

// Developer Profile Widget (Your Profile)
class DeveloperProfile extends StatelessWidget {
  const DeveloperProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ProfileImage(imagePath: 'assets/images/profile.jpg', radius: 40),
        SizedBox(height: 12),
        Text(
          'CHIVORN KANG',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 6),
        LocationText(),
        SizedBox(height: 6),
        ProjectDescription(),
      ],
    );
  }
}

// Profile Image Widget
class ProfileImage extends StatelessWidget {
  final String imagePath;
  final double radius;

  const ProfileImage({super.key, required this.imagePath, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: AssetImage(imagePath),
          onBackgroundImageError: (_, __) =>
              const Icon(Icons.person, size: 60, color: Colors.white),
        ),
      ),
    );
  }
}

// Location Text Widget
class LocationText extends StatelessWidget {
  const LocationText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'I\'m from',
            style: TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
          TextSpan(
            text: ' BC64 (MBS MSU)',
            style: TextStyle(
                color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Project Description Widget
class ProjectDescription extends StatelessWidget {
  const ProjectDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: RichText(
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
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  ', a Personal Financial Management Mobile Application that helps users to note, track and manage their finances efficiently.\n',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            TextSpan(
              text: 'iSAVE',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  ' is my final project for my bachelor’s degree and represents my dedication to creating practical, user-friendly solutions, aiming to make financial management accessible and effective for everyone.',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
