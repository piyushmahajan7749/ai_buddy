import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/secure_storage.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:settings_ui/settings_ui.dart';

class Preferences extends StatefulWidget {
  const Preferences({
    super.key,
  });
  @override
  // ignore: library_private_types_in_public_api
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SecureStorage secureStorage = SecureStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: buildSettingsList(secureStorage)),
    );
  }

  SettingsSection? getSecuritySections() {
    return SettingsSection(
      title: Text(
        'Legal Information',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      tiles: [
        SettingsTile(
          title: Text(
            'Terms of use',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          leading: const Icon(LineIcons.fileInvoice),
          trailing: const SizedBox(),
          onPressed: (context) {
            launchInWebViewOrVC(
              Uri(
                scheme: 'https',
                host: 'www.apple.com',
                path: '/legal/internet-services/itunes/dev/stdeula/',
              ),
            );
          },
        ),
        SettingsTile(
          title: Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          leading: const Icon(LineIcons.fileInvoice),
          trailing: const SizedBox(),
          onPressed: (context) {
            launchInWebViewOrVC(
              Uri(
                scheme: 'https',
                host: 'www.9roof.ai',
                path: '/privacy/',
              ),
            );
          },
        ),
      ],
    );
  }

  SettingsSection? getAccountSections(SecureStorage secureStorage) {
    return SettingsSection(
      title: Text(
        'Account',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      tiles: [
        SettingsTile(
          title: Text(
            'Sign out',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          trailing: const SizedBox(),
          leading: const Icon(LineIcons.alternateSignOut),
          onPressed: (context) async {
            await secureStorage.deleteApiKey();
            // ignore: use_build_context_synchronously
            AppRoute.welcome.go(context);
          },
        ),
      ],
    );
  }

  Widget buildSettingsList(SecureStorage secureStorage) {
    return SettingsList(
      sections: [
        getAccountSections(secureStorage)!,
        getSecuritySections()!,
        CustomSettingsSection(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Lottie.asset(
                    AssetConstants.onboardingAnimation,
                    height: 40,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const Text(
                  'Version: 1.0.1',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
