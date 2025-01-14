// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/database/dbuser.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/auth.dart';
import 'package:ai_buddy/core/util/constants.dart';
import 'package:ai_buddy/core/util/secure_storage.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/home/provider/chat_bot_provider.dart';
import 'package:ai_buddy/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<Map<String, dynamic>> getUserData() async {
    final String? userId = AuthService().getCurrentUserId();
    if (userId == null) {
      return {};
    }
    return DbServiceUser(uid: userId).getUserData();
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

  void _showUpgradeDialog() {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upgrade to Pro'),
          content:
              const Text('Contact us on WhatsApp to upgrade your account.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Contact on WhatsApp'),
              onPressed: () {
                Navigator.of(context).pop();
                launchWhatsApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog() {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                await AuthService().deleteUser();
                Navigator.pop(context);
                AppRoute.login.go(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> launchWhatsApp() async {
    const contact = '+91-8818888870';
    const androidUrl =
        'whatsapp://send?phone=$contact&text=Hi, I would like to upgrade my 9Roof AI account to Pro.';
    final iosUrl =
        "https://wa.me/$contact?text=${Uri.parse('Hi, I would like to upgrade my 9Roof AI account to Pro.')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          content: const Text('Unable to open WhatsApp'),
        ),
      );
    }
  }

  // ignore: unused_element
  Future<void> _onUploadPressed() async {
    setState(() {
      _isBuildingChatBot = true;
      currentState = 'Uploading files...';
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
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

          await Fluttertoast.showToast(
            msg: 'Files Uploaded successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            textColor: Theme.of(context).colorScheme.surface,
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
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            textColor: Theme.of(context).colorScheme.surface,
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

  SettingsSection? getUserInfoSection() {
    return SettingsSection(
      title: Text(
        'Account Info',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      tiles: [
        SettingsTile(
          leading: const Icon(CupertinoIcons.person),
          trailing: const SizedBox(),
          title: FutureBuilder<Map<String, dynamic>>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              final String name = snapshot.data?['name'] as String;
              final userId = name;
              return Text(
                userId,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              );
            },
          ),
        ),
        SettingsTile(
          leading: const Icon(CupertinoIcons.star),
          title: FutureBuilder<Map<String, dynamic>>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              final bool isPro = snapshot.data?['is_pro'] as bool;
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPro ? "You're on the pro plan" : "You're on trial plan",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (!isPro) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _showUpgradeDialog,
                      child: Text(
                        'Upgrade',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        SettingsTile(
          title: Text(
            'Credits Left',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          leading: const Icon(CupertinoIcons.money_dollar_circle),
          trailing: FutureBuilder<Map<String, dynamic>>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              final creditsUsed = snapshot.data?['credits_used'] as int;
              final creditsLeft = maxCredits - creditsUsed;
              final bool isPro = snapshot.data?['is_pro'] as bool;

              return Text(
                isPro ? 'Unlimited' : '$creditsLeft',
                style: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
        ),
        SettingsTile(
          title: Text(
            'Location',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
                ),
          ),
          trailing: Text(
            'Indore',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
                ),
          ),
          leading: Icon(
            CupertinoIcons.location,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4),
          ),
          onPressed: (context) async {},
        ),
      ],
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
                host: '10970870-1215108.renderforestsites.com',
                path: '/terms/',
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
                host: '10970870-1215108.renderforestsites.com',
                path: '/privacy/',
              ),
            );
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
        // SettingsTile(
        //   title: Text(
        //     'Upload chats',
        //     style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        //           fontWeight: FontWeight.w500,
        //           color: Theme.of(context).colorScheme.onPrimary,
        //         ),
        //   ),
        //   trailing: const SizedBox(),
        //   leading: const Icon(CupertinoIcons.cloud_upload),
        //   onPressed: (context) async {
        //     await _onUploadPressed();
        //   },
        // ),
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
            await auth.signOut();
            AppRoute.welcome.go(context);
          },
        ),
        SettingsTile(
          title: Text(
            'Delete Account',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          leading: const Icon(LineIcons.trash),
          trailing: const SizedBox(),
          onPressed: (context) {
            _showDeleteDialog();
          },
        ),
      ],
    );
  }

  Widget buildSettingsList(SecureStorage secureStorage) {
    return SettingsList(
      applicationType: ApplicationType.both,
      sections: [
        getUserInfoSection()!,
        getAppSettingsSections(secureStorage)!,
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
