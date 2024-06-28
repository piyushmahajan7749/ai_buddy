import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/home/widgets/search_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatInterfaceWidget extends ConsumerStatefulWidget {
  const ChatInterfaceWidget({
    required this.messages,
    required this.chatBot,
    required this.color,
    required this.imagePath,
    required this.lastReadMessageId,
    super.key,
  });

  final List<types.Message> messages;
  final ChatBot chatBot;
  final Color color;
  final String imagePath;
  final String lastReadMessageId;

  @override
  // ignore: library_private_types_in_public_api
  _ChatInterfaceWidgetState createState() => _ChatInterfaceWidgetState();
}

class _ChatInterfaceWidgetState extends ConsumerState<ChatInterfaceWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatInterfaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chat(
      messages: widget.messages,
      scrollToUnreadOptions: ScrollToUnreadOptions(
        lastReadMessageId: widget.lastReadMessageId,
        scrollDuration: const Duration(milliseconds: 800),
      ),
      textMessageBuilder: (p0, {required messageWidth, required showName}) {
        final isLastMessage = widget.messages.first.id == p0.id;
        final isAiMessage = p0.author.id == TypeOfMessage.bot;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18)
                  .copyWith(
                bottom: (isLastMessage && isAiMessage) ? 0 : 16,
              ),
              child: Text(
                p0.text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (isLastMessage && isAiMessage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Regenerate',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        // Add regenerate functionality
                        ref
                            .read(messageListProvider.notifier)
                            .regenerateResults();
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      emptyState: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Lottie.asset(
                AssetConstants.onboardingAnimation,
                height: 120,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(height: 20),
              const Text(
                'Let the Search Begin',
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
          const SearchGridView(),
        ],
      ),
      onSendPressed: (text) =>
          ref.watch(messageListProvider.notifier).handleSendPressed(
                text: text.text,
                imageFilePath: widget.chatBot.attachmentPath,
              ),
      customMessageBuilder: (p0, {required messageWidth}) {
        return SizedBox(
          width: messageWidth.toDouble(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Lottie.asset(
                      AssetConstants.onboardingAnimation,
                      height: 60,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        'Searching for results...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.stop_fill,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        tooltip: 'Cancel request',
                        onPressed: () {
                          // Add stop functionality
                          ref
                              .read(messageListProvider.notifier)
                              .stopGeneration();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onMessageDoubleTap: (context, message) {
        final Map<String, dynamic> newMsg = message.toJson();
        final phoneNumber = extractPhoneNumber(newMsg['text'] as String);
        if (phoneNumber != null) {
          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Phone Number Detected'),
                content: Text('Do you want to call $phoneNumber?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Call'),
                    onPressed: () async {
                      final uri = Uri.parse('tel:$phoneNumber');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // ignore: only_throw_errors
                        throw 'Could not launch $uri';
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      user: const types.User(id: TypeOfMessage.user),
      showUserAvatars: false,
      theme: DarkChatTheme(
        backgroundColor: Colors.transparent,
        primaryColor: context.colorScheme.secondary,
        secondaryColor: context.colorScheme.onBackground,
        inputBackgroundColor: context.colorScheme.onBackground,
        inputTextColor: context.colorScheme.onSurface,
        messageMaxWidth: 600,
        sentMessageBodyLinkTextStyle: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Theme.of(context).colorScheme.secondary),
        sendingIcon: Icon(
          Icons.send,
          color: context.colorScheme.onSurface,
        ),
        inputTextCursorColor: context.colorScheme.onSurface,
        receivedMessageBodyTextStyle: TextStyle(
          color: context.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        sentMessageBodyTextStyle: TextStyle(
          color: context.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        dateDividerTextStyle: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.333,
        ),
        inputTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: context.colorScheme.onSurface,
        ),
        inputTextDecoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          fillColor: context.colorScheme.onBackground,
        ),
        inputBorderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }
}
