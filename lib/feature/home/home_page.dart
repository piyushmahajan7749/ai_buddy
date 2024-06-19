// ignore_for_file: use_build_context_synchronously

import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/config/type_of_bot.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/home/provider/chat_bot_provider.dart';
import 'package:ai_buddy/feature/home/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final uuid = const Uuid();

  bool _isBuildingChatBot = false;
  String currentState = '';

  @override
  void initState() {
    super.initState();
    ref.read(chatBotListProvider.notifier).fetchChatBots();
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
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
          Text(currentState, style: context.textTheme.titleMedium),
        ],
      ),
    );
  }

  void _showAllHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final chatBotsList = ref.watch(chatBotListProvider);
            return Column(
              children: [
                Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.separated(
                      itemCount: chatBotsList.length,
                      itemBuilder: (context, index) {
                        final chatBot = chatBotsList[index];
                        final imagePath = chatBot.typeOfBot == TypeOfBot.pdf
                            ? AssetConstants.pdfLogo
                            : chatBot.typeOfBot == TypeOfBot.image
                                ? AssetConstants.imageLogo
                                : AssetConstants.textLogo;
                        final tileColor = chatBot.typeOfBot == TypeOfBot.pdf
                            ? context.colorScheme.primary
                            : chatBot.typeOfBot == TypeOfBot.text
                                ? context.colorScheme.secondary
                                : context.colorScheme.tertiary;
                        return HistoryItem(
                          imagePath: imagePath,
                          label: chatBot.title,
                          color: tileColor,
                          chatBot: chatBot,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatBotsList = ref.watch(chatBotListProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _isBuildingChatBot
          ? _buildLoadingIndicator(currentState)
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 60),
                        Lottie.asset(
                          AssetConstants.onboardingAnimation,
                          height: 64,
                          fit: BoxFit.fitHeight,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: CircleAvatar(
                            maxRadius: 20,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                            child: IconButton(
                              icon: const Icon(
                                CupertinoIcons.settings,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () async {
                                // Preferences view
                                AppRoute.preferences.push(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'How may I help you today?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CardButton(
                              title: 'Upload chats',
                              color: context.colorScheme.primary,
                              imagePath: AssetConstants.pdfLogo,
                              isMainButton: true,
                              onPressed: _onUploadPressed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'History',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withOpacity(0.95),
                                      ),
                                ),
                                TextButton(
                                  onPressed: () => _showAllHistory(context),
                                  child: Text(
                                    'See all',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.8),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (chatBotsList.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(64),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(width: 12),
                                    Text(
                                      'No chats yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withOpacity(0.95),
                                          ),
                                    ),
                                    const Icon(CupertinoIcons.cube_box),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: chatBotsList.length > 3
                                  ? 3
                                  : chatBotsList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final chatBot = chatBotsList[index];
                                final imagePath =
                                    chatBot.typeOfBot == TypeOfBot.pdf
                                        ? AssetConstants.pdfLogo
                                        : chatBot.typeOfBot == TypeOfBot.image
                                            ? AssetConstants.imageLogo
                                            : AssetConstants.textLogo;
                                final tileColor =
                                    chatBot.typeOfBot == TypeOfBot.pdf
                                        ? context.colorScheme.primary
                                        : chatBot.typeOfBot == TypeOfBot.text
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary;
                                return HistoryItem(
                                  label: chatBot.title,
                                  imagePath: imagePath,
                                  color: tileColor,
                                  chatBot: chatBot,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}
