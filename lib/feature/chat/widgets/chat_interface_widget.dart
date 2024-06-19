import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/util/utils.dart';
import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatInterfaceWidget extends ConsumerWidget {
  const ChatInterfaceWidget({
    required this.messages,
    required this.chatBot,
    required this.color,
    required this.imagePath,
    super.key,
  });

  final List<types.Message> messages;
  final ChatBot chatBot;
  final Color color;
  final String imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Chat(
      messages: messages,
      onSendPressed: (text) =>
          ref.watch(messageListProvider.notifier).handleSendPressed(
                text: text.text,
                imageFilePath: chatBot.attachmentPath,
              ),
      onAttachmentPressed: () =>
          ref.watch(messageListProvider.notifier).handleShowSourcesPressed(),
      customMessageBuilder: (p0, {required messageWidth}) {
        return Row(
          children: [
            Lottie.asset(
              AssetConstants.onboardingAnimation,
              height: 64,
              fit: BoxFit.fitHeight,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Looking for results...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      },
      onMessageDoubleTap: (context, message) {
        final phoneNumber = extractPhoneNumber(message.toString());
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
                      final url = 'tel:$phoneNumber';
                      if (await canLaunchUrl(Uri.dataFromString(url))) {
                        await launchUrl(Uri.dataFromString(url));
                      } else {
                        // ignore: only_throw_errors
                        throw 'Could not launch $url';
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
      theme: DefaultChatTheme(
        backgroundColor: Colors.transparent,
        attachmentButtonIcon: Icon(
          CupertinoIcons.eye,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
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
