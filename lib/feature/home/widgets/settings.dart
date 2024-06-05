import 'package:ai_buddy/core/ui/dialog/confirmation_dialog.dart';
import 'package:ai_buddy/core/util/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class UserProfileSettings extends StatelessWidget {
  const UserProfileSettings({
    required this.profilePictureUrl,
    required this.userName,
    required this.email,
    super.key,
  });
  final String profilePictureUrl;
  final String userName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final SecureStorage secureStorage = SecureStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              height: 48,
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              onTap: () {
                // Handle notification settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Account Settings'),
              onTap: () {
                // Handle privacy settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet_rounded),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Handle privacy settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Terms of use'),
              onTap: () {
                // Handle privacy settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                ConfirmationDialog(
                  message: 'Are you sure you want to sign out of your account?',
                  title: 'Sign out',
                  confirmText: 'Yes',
                  isDestructive: true,
                  onConfirm: () async => secureStorage.deleteApiKey(),
                );

                // Handle log out action
              },
            ),
          ],
        ),
      ),
    );
  }
}
