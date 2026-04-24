import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/login_screeen.dart';
import 'package:instagram_clone/screens/profilescreen/saved_posts_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // Saved Posts Row
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SavedPostsScreen()),
            ),
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Saved'),
          ),
          const Divider(),
          // Logout Row
          ListTile(
            onTap: () async {
              await AuthMethods().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreeen()),
                  (route) => false,
                );
              }
            },
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
