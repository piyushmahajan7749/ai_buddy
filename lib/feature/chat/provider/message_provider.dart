import 'dart:convert';
import 'dart:io';

import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/logger/logger.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/hive/model/chat_message/chat_message.dart';
import 'package:ai_buddy/feature/hive/repository/hive_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final messageListProvider = StateNotifierProvider<MessageListNotifier, ChatBot>(
  (ref) => MessageListNotifier(),
);

class MessageListNotifier extends StateNotifier<ChatBot> {
  MessageListNotifier()
      : super(ChatBot(messagesList: [], id: '', title: '', typeOfBot: ''));

  final uuid = const Uuid();

  Future<void> updateChatBotWithMessage(ChatMessage message) async {
    final newMessageList = [...state.messagesList, message.toJson()];
    await updateChatBot(
      ChatBot(
        messagesList: newMessageList,
        id: state.id,
        title: state.title.isEmpty ? message.text : state.title,
        typeOfBot: state.typeOfBot,
        attachmentPath: state.attachmentPath,
        embeddings: state.embeddings,
      ),
    );
  }

  Future<void> handleSendPressed({
    required String text,
    String? imageFilePath,
  }) async {
    final messageId = uuid.v4();
    final ChatMessage message = ChatMessage(
      id: messageId,
      text: text,
      createdAt: DateTime.now(),
      typeOfMessage: TypeOfMessage.user,
      chatBotId: state.id,
    );
    await updateChatBotWithMessage(message);
    await getPythonAPIResponse(prompt: text, imageFilePath: imageFilePath);
  }

  Future<void> getPythonAPIResponse({
    required String prompt,
    String? imageFilePath,
  }) async {
    final List<Map<String, String>> chatParts = state.messagesList.map((msg) {
      return {'text': msg['text'] as String};
    }).toList();

    // ignore: cascade_invocations
    chatParts.add({'text': prompt});
    final String modelMessageId = uuid.v4();
    final placeholderMessage = ChatMessage(
      id: modelMessageId,
      text: 'waiting for response...',
      createdAt: DateTime.now(),
      typeOfMessage: TypeOfMessage.bot,
      chatBotId: state.id,
    );

    await updateChatBotWithMessage(placeholderMessage);

    final StringBuffer fullResponseText = StringBuffer();

    try {
      final dio = Dio();
      // ignore: inference_failure_on_function_invocation
      final response = await dio.post(
        'http://192.168.29.89:5000/chat',
        data: jsonEncode({'message': prompt}),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        fullResponseText.write(responseData['response']);
        final int messageIndex =
            state.messagesList.indexWhere((msg) => msg['id'] == modelMessageId);
        if (messageIndex != -1) {
          final newMessagesList =
              List<Map<String, dynamic>>.from(state.messagesList);
          newMessagesList[messageIndex]['text'] = fullResponseText.toString();
          final newState = ChatBot(
            id: state.id,
            title: state.title,
            typeOfBot: state.typeOfBot,
            messagesList: newMessagesList,
            attachmentPath: state.attachmentPath,
            embeddings: state.embeddings,
          );
          await updateChatBot(newState);
        }
      } else {
        logError('Error in response: ${response.statusCode}');
      }
    } catch (e) {
      logError('Error in response: $e');
    }
  }

  Future<void> updateChatBot(ChatBot newChatBot) async {
    state = newChatBot;
    await HiveRepository().saveChatBot(chatBot: state);
  }
}
