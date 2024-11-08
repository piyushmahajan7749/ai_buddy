// ignore_for_file: use_build_context_synchronously

import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/chathistory/widgets/widgets.dart';
import 'package:ai_buddy/feature/hive/model/search_item/search_item.dart';
import 'package:ai_buddy/feature/home/provider/chat_bot_provider.dart';
import 'package:ai_buddy/feature/home/widgets/search_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ChatHistoryPage extends ConsumerStatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ConsumerState<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends ConsumerState<ChatHistoryPage> {
  late List<SearchItem> searchItems;
  @override
  void initState() {
    super.initState();
    initSharingIntent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatBotListProvider.notifier).fetchChatBots();
    });
  }

  Future<void> initSharingIntent() async {
    // For sharing files coming from outside the app while the app is closed
    await ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        _handleSharedFiles(value);
      }
    });

    // For handling files shared from WhatsApp while the app is in memory
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        if (value.isNotEmpty) {
          _handleSharedFiles(value);
        }
        // ignore: inference_failure_on_untyped_parameter
      },
      onError: (err) {},
    );
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> sharedFiles) async {
    final filePaths = sharedFiles.map((file) => file.path).toList();

    if (filePaths.isNotEmpty) {
      try {
        await ref.read(chatBotListProvider.notifier).uploadFiles(filePaths);

        await Fluttertoast.showToast(
          msg: 'Files Uploaded successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          textColor: Theme.of(context).colorScheme.surface,
          fontSize: 16,
        );
      } catch (e) {
        if (kDebugMode) {
          print('File upload error: $e');
        }

        await Fluttertoast.showToast(
          msg: 'File upload error!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          textColor: Theme.of(context).colorScheme.surface,
          fontSize: 16,
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    searchItems = getFeaturedSearches();
    super.didChangeDependencies();
  }

  void _showAllHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final chatBotsList = ref.watch(chatBotListProvider);
                return Column(
                  children: [
                    Container(
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 120, // Adjust this height as needed
                              child: Center(
                                child: Text(
                                  'All searches',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final reversedIndex =
                                    chatBotsList.length - 1 - index;

                                final chatBot = chatBotsList[reversedIndex];
                                const imagePath = AssetConstants.textLogo;
                                final tileColor = context.colorScheme.tertiary;
                                return Column(
                                  children: [
                                    HistoryItem(
                                      imagePath: imagePath,
                                      label: chatBot.title,
                                      color: tileColor,
                                      chatBot: chatBot,
                                    ),
                                    if (reversedIndex > 0)
                                      const SizedBox(height: 4),
                                  ],
                                );
                              },
                              childCount: chatBotsList.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          child: ListView(
            children: [
              Lottie.asset(
                AssetConstants.onboardingAnimation,
                height: 64,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      'Top searches this week',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.95),
                          ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      CupertinoIcons.right_chevron,
                      size: 18,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: SearchGridView(),
                  ),
                  Divider(
                    height: 30,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      itemCount:
                          chatBotsList.length > 3 ? 3 : chatBotsList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final reversedIndex = chatBotsList.length - 1 - index;

                        final chatBot = chatBotsList[reversedIndex];
                        const imagePath = AssetConstants.textLogo;
                        final tileColor =
                            Theme.of(context).colorScheme.tertiary;
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
