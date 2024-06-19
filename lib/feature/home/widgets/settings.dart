import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/config/type_of_bot.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/secure_storage.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/home/provider/chat_bot_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:uuid/uuid.dart';

class Preferences extends ConsumerStatefulWidget {
  const Preferences({
    super.key,
  });
  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends ConsumerState<Preferences> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  bool _isBuildingChatBot = false;
  String currentState = '';
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    ref.read(chatBotListProvider.notifier).fetchChatBots();
  }

  Widget _buildLoadingIndicator(String currentState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AssetConstants.onboardingAnimation,
            height: 120,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 8),
          Text(currentState, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Future<void> _onUploadPressed() async {
    setState(() {
      _isBuildingChatBot = true;
      currentState = 'Uploading files...';
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: true,
    );
    if (result != null) {
      final filePaths =
          result.paths.where((path) => path != null).cast<String>().toList();
      if (filePaths.isNotEmpty) {
        try {
          await ref.read(chatBotListProvider.notifier).uploadFiles(filePaths);

          setState(() {
            currentState = 'Files uploaded successfully!';
          });

          final chatBot = ChatBot(
            messagesList: [],
            id: uuid.v4(),
            title: 'Chat assistant',
            typeOfBot: TypeOfBot.pdf,
            attachmentPath: filePaths.join(', '), // Store all file paths
          );

          await ref.read(chatBotListProvider.notifier).saveChatBot(chatBot);
          setState(() {
            currentState = 'Chat files uploaded. You can now chat!';
          });

          await Fluttertoast.showToast(
            msg: 'Files Uploaded successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            // ignore: use_build_context_synchronously
            textColor: Theme.of(context).colorScheme.background,
            fontSize: 16,
          );

          // AppRoute.chat.push(context);
        } catch (e) {
          if (kDebugMode) {
            print('File upload error: $e');
          }
          setState(() {
            currentState = 'File upload error!';
          });

          await Fluttertoast.showToast(
            msg: 'File upload error!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            // ignore: use_build_context_synchronously
            textColor: Theme.of(context).colorScheme.background,
            fontSize: 16,
          );
        } finally {
          setState(() {
            _isBuildingChatBot = false;
          });
        }
      }
    }
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
      body: _isBuildingChatBot
          ? _buildLoadingIndicator(currentState)
          : SafeArea(child: buildSettingsList(secureStorage)),
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
          leading: const Icon(CupertinoIcons.doc_plaintext),
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
          leading: const Icon(CupertinoIcons.doc_richtext),
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

  SettingsSection? getAppSettingsSections(SecureStorage secureStorage) {
    return SettingsSection(
      title: Text(
        'Settings',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      tiles: [
        SettingsTile(
          title: Text(
            'Indore',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
                ),
          ),
          trailing: const SizedBox(),
          leading: Icon(
            CupertinoIcons.location_solid,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
          ),
          onPressed: (context) async {},
        ),
        SettingsTile(
          title: Text(
            'Upload chats',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          trailing: const SizedBox(),
          leading: const Icon(CupertinoIcons.cloud_upload),
          onPressed: (context) async {
            await _onUploadPressed();
          },
        ),
      ],
    );
  }

  Widget buildSettingsList(SecureStorage secureStorage) {
    return SettingsList(
      applicationType: ApplicationType.both,
      sections: [
        getAppSettingsSections(secureStorage)!,
        getAccountSections(secureStorage)!,
        getSecuritySections()!,
        CustomSettingsSection(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Lottie.asset(
                  AssetConstants.onboardingAnimation,
                  height: 40,
                  fit: BoxFit.fitHeight,
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
