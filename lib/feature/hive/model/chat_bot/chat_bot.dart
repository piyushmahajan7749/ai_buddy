import 'package:hive/hive.dart';

part 'chat_bot.g.dart';

@HiveType(typeId: 0)
class ChatBot extends HiveObject {
  ChatBot({
    required this.messagesList,
    required this.id,
    required this.title,
    this.attachmentPath,
    this.embeddings,
    this.showSources,
    this.lastReadMessageId,
  });

  factory ChatBot.defaultInstance() => ChatBot(
        messagesList: [],
        id: '',
        title: 'New Chat',
      );
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? attachmentPath;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final List<Map<String, dynamic>> messagesList;

  @HiveField(4)
  final Map<String, List<num>>? embeddings;

  @HiveField(5)
  final bool? showSources;

  @HiveField(6)
  final String? lastReadMessageId;
}
