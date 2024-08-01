import 'package:hive/hive.dart';

part 'chat_bot.g.dart';

@HiveType(typeId: 0)
class ChatBot extends HiveObject {
  ChatBot({
    required this.messagesList,
    required this.id,
    required this.title,
    required this.typeOfBot,
    this.attachmentPath,
    this.embeddings,
    this.showSources,
    this.lastReadMessageId,
    this.shownMessagesCount = 4, // Add this line
  });
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? attachmentPath;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String typeOfBot;

  @HiveField(4)
  final List<Map<String, dynamic>> messagesList;

  @HiveField(5)
  final Map<String, List<num>>? embeddings;

  @HiveField(6)
  final bool? showSources;

  @HiveField(7)
  final String? lastReadMessageId;

  @HiveField(8) // Add this field
  int shownMessagesCount;
}
