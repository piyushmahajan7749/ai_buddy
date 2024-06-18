import 'dart:convert';
import 'dart:io';

import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/logger/logger.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/hive/model/chat_message/chat_message.dart';
import 'package:ai_buddy/feature/hive/repository/hive_repository.dart';
// ignore: deprecated_member_use
import 'package:collection/equality.dart';
import 'package:dio/dio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const String baseUrl = 'http://192.168.1.2:5000';

final messageListProvider = StateNotifierProvider<MessageListNotifier, ChatBot>(
  (ref) => MessageListNotifier(),
);

class MessageListNotifier extends StateNotifier<ChatBot> {
  MessageListNotifier()
      : super(ChatBot(messagesList: [], id: '', title: '', typeOfBot: ''));

  final uuid = const Uuid();
  List<ChatMessage> sourceMessageList = [];

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

  Future<void> updateChatBotWithCustomMessage(CustomMessage message) async {
    final newMessageList = [...state.messagesList, message.toJson()];

    await updateChatBot(
      ChatBot(
        messagesList: newMessageList,
        id: state.id,
        title: state.title,
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

  Future<void> handleShowSourcesPressed() async {
    final newMessageList = List<Map<String, dynamic>>.from(state.messagesList);

    // Add new messages to the list
    // ignore: cascade_invocations
    newMessageList.addAll(sourceMessageList.map((msg) => msg.toJson()));

    // Extract texts from messages and ensure uniqueness
    final uniqueMessages = <String, Map<String, dynamic>>{};
    for (final message in newMessageList) {
      uniqueMessages[message['text'] as String] = message;
    }

    // Create a list of unique messages based on text
    final uniqueMessageList = uniqueMessages.values.toList();

    // Check if the list has changed
    if (const ListEquality<Map<String, dynamic>>()
        .equals(state.messagesList, uniqueMessageList)) {
      // No change, return early
      return;
    }

    final newStateWithNewMessage = ChatBot(
      id: state.id,
      title: state.title,
      typeOfBot: state.typeOfBot,
      messagesList: uniqueMessageList,
      attachmentPath: state.attachmentPath,
      embeddings: state.embeddings,
    );

    await updateChatBot(newStateWithNewMessage);
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
    final placeholderMessage = CustomMessage(
      id: modelMessageId,
      author: User(
        id: modelMessageId,
        createdAt: DateTime.now().day,
      ),
      type: MessageType.custom,
    );

    await updateChatBotWithCustomMessage(placeholderMessage);

    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      // ignore: inference_failure_on_function_invocation
      final response = await dio.post<dynamic>(
        '/chat',
        data: jsonEncode({'message': prompt}),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final String rawResponse = responseData['response'] as String;

        final List<String> sources =
            List<String>.from(responseData['sources'] as List);

        final List<String> rawMsgs =
            List<String>.from(rawResponse.split('###|||') as List);

        // ignore: cascade_invocations
        rawMsgs.removeWhere((element) => element.isEmpty);

        final List<ChatMessage> rawMessageList = rawMsgs.map((source) {
          return ChatMessage(
            id: uuid.v4(),
            text: source,
            createdAt: DateTime.now(),
            typeOfMessage: TypeOfMessage.bot,
            chatBotId: state.id,
          );
        }).toList();

        sourceMessageList = sources.map((source) {
          return ChatMessage(
            id: uuid.v4(),
            text: source,
            createdAt: DateTime.now(),
            typeOfMessage: TypeOfMessage.bot,
            chatBotId: state.id,
          );
        }).toList();

        final newMessageList =
            List<Map<String, dynamic>>.from(state.messagesList);

        final int placeholderIndex =
            newMessageList.indexWhere((msg) => msg['id'] == modelMessageId);
        if (placeholderIndex != -1) {
          newMessageList.removeAt(placeholderIndex);
        }

        newMessageList.addAll(rawMessageList.map((msg) => msg.toJson()));

        final newStateWithNewMessage = ChatBot(
          id: state.id,
          title: state.title,
          typeOfBot: state.typeOfBot,
          messagesList: newMessageList,
          attachmentPath: state.attachmentPath,
          embeddings: state.embeddings,
        );
        await updateChatBot(newStateWithNewMessage);
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
