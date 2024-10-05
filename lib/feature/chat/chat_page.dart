import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/feature/chat/provider/message_provider.dart';
import 'package:ai_buddy/feature/chat/widgets/chat_interface_widget.dart';
import 'package:ai_buddy/feature/chat/widgets/filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatBot = ref.watch(messageListProvider);
    final messagesToShow = ref.watch(messagesToShowProvider);
    final color = context.colorScheme.tertiary;
    const imagePath = AssetConstants.textLogo;

    final allMessages = chatBot.messagesList.map((msg) {
      if (msg['type'] == 'custom') {
        return types.CustomMessage(
          author: const types.User(id: 'cd', createdAt: 11),
          id: msg['id'] as String,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          metadata: {'custom_type': msg['custom_type'] ?? ''},
        );
      }
      return types.TextMessage(
        author: types.User(id: msg['typeOfMessage'] as String),
        createdAt:
            DateTime.parse(msg['createdAt'] as String).millisecondsSinceEpoch,
        id: msg['id'] as String,
        text: msg['text'] as String,
      );
    }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    List<types.Message> messages;
    if (allMessages.length <= messagesToShow) {
      messages = allMessages;
    } else {
      messages = allMessages.take(messagesToShow).toList();

      // Add a custom "Show more" message
      final showMoreMessage = types.CustomMessage(
        id: 'show_more',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        author: const types.User(id: 'system'),
        metadata: {'custom_type': 'show_more'},
      );

      messages.add(showMoreMessage);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const FilterSection(),
              Expanded(
                child: ChatInterfaceWidget(
                  messages: messages,
                  chatBot: chatBot,
                  color: color,
                  imagePath: imagePath,
                  lastReadMessageId: chatBot.lastReadMessageId ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
