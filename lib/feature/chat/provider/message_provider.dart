// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/logger/logger.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/hive/model/chat_message/chat_message.dart';
import 'package:ai_buddy/feature/hive/repository/hive_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const String baseUrl = 'http://192.168.1.9:5000';

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
        lastReadMessageId: state.id,
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
      chatBotId: messageId,
    );
    await updateChatBotWithMessage(message);
    await getPythonAPIResponse(prompt: text);
    await updateChatBot(
      ChatBot(
        messagesList: state.messagesList,
        id: state.id,
        title: state.title,
        typeOfBot: state.typeOfBot,
        attachmentPath: state.attachmentPath,
        embeddings: state.embeddings,
        lastReadMessageId: messageId,
      ),
    );
  }

  Future<void> getPythonAPIResponse({required String prompt}) async {
    final List<Map<String, String>> chatParts = state.messagesList.map((msg) {
      return {'text': msg['text'] as String};
    }).toList();

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
        final rawResponse = responseData['response'];
        final properties = rawResponse['properties'] as List;

        final Map<String, Map<String, dynamic>> groupedListings = {};
        for (final property in properties) {
          final contact = property['contact'];
          final name = property['name'];
          final listings = property['listings'] as List;

          if (!groupedListings.containsKey(contact)) {
            groupedListings[contact as String] = {
              'contact': contact,
              'name': name,
              // ignore: inference_failure_on_collection_literal
              'listings': [],
            };
          }

          for (final listing in listings) {
            groupedListings[contact]!['listings'].add({
              'date': listing['date'],
              'time': listing['time'],
              'location': listing['location'],
              'description': listing['description'],
            });
          }
        }

        final List<ChatMessage> rawMessageList = [];

        groupedListings.forEach((contact, data) {
          final name = data['name'];
          final listings = data['listings'] as List;

          // Sort listings by date and time
          listings.sort((a, b) {
            final dateTimeA = DateTime.parse('${a['date']} ${a['time']}');
            final dateTimeB = DateTime.parse('${b['date']} ${b['time']}');
            return dateTimeA.compareTo(dateTimeB); // Sort in descending order
          });

          // Select top 5 most recent listings
          final topListings = listings.take(10).toList();

          // Combine listings into a single message
          final messageText = StringBuffer();
          messageText.writeln('Name: $name');
          messageText.writeln('Contact: $contact');
          for (final listing in topListings) {
            messageText.writeln('Listing date: ${listing['date']}');
            messageText.writeln('Location: ${listing['location']}');
            messageText.writeln('Description: ${listing['description']}');
            messageText.writeln();
          }

          final chatMessage = ChatMessage(
            id: uuid.v4(),
            text: messageText.toString(),
            createdAt: DateTime.now(),
            typeOfMessage: TypeOfMessage.bot,
            contactNumber: contact,
            chatBotId: state.id,
          );

          rawMessageList.add(chatMessage);
        });

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
