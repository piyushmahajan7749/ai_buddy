// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

import 'package:ai_buddy/core/config/type_of_message.dart';
import 'package:ai_buddy/core/database/dbuser.dart';
import 'package:ai_buddy/core/logger/logger.dart';
import 'package:ai_buddy/core/util/auth.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/hive/model/chat_message/chat_message.dart';
import 'package:ai_buddy/feature/hive/repository/hive_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// const String baseUrl = 'https://roofai-cr372ioeiq-el.a.run.app';
const String baseUrl = 'http://192.168.1.2:5000';

final messageListProvider = StateNotifierProvider<MessageListNotifier, ChatBot>(
  (ref) => MessageListNotifier(),
);

class MessageListNotifier extends StateNotifier<ChatBot> {
  MessageListNotifier()
      : super(ChatBot(messagesList: [], id: '', title: '', typeOfBot: ''));

  final uuid = const Uuid();
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  CancelToken? _cancelToken;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  String placeholderId = '';

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

  Future<void> updateChatBotRemovePlaceholder(ChatMessage message) async {
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

  DateTime getMostRecentDate(List<dynamic> listings) {
    return listings
        .map((listing) => parseDate(listing['date'] as String))
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  DateTime parseDate(String dateStr) {
    DateTime date;
    try {
      date = DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      try {
        date = DateFormat('MM-yy').parse(dateStr);
      } catch (e) {
        date = DateTime.now();
      }
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Future<void> getPythonAPIResponse({required String prompt}) async {
    _isGenerating = true;
    _cancelToken = CancelToken(); // Create a new token for this request
    _errorMessage = '';

    final String? userId = AuthService().getCurrentUserId();
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      await addErrorMessage(placeholderId);
      _isGenerating = false;
      return;
    }

    final userData = await DbServiceUser(uid: userId).getUserData();
    final bool isPro = userData['is_pro'] as bool;
    final int creditsUsed = userData['credits_used'] as int;

    if (!isPro && creditsUsed >= 9) {
      _errorMessage =
          // ignore: lines_longer_than_80_chars
          'You have reached your limit. Please upgrade to Pro from settings tab.';
      await addErrorMessage(placeholderId);
      _isGenerating = false;
      return;
    }

    final List<Map<String, String>> chatParts = state.messagesList.map((msg) {
      return {'text': msg['text'] as String};
    }).toList();

    chatParts.add({'text': prompt});
    placeholderId = uuid.v4();
    final placeholderMessage = CustomMessage(
      id: placeholderId,
      author: User(
        id: placeholderId,
        createdAt: DateTime.now().day,
      ),
      type: MessageType.custom,
    );

    await updateChatBotWithCustomMessage(placeholderMessage);

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
        ),
      );
      // ignore: inference_failure_on_function_invocation
      final response = await dio.post<dynamic>(
        '/chat',
        data: jsonEncode({'message': prompt}),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
        cancelToken: _cancelToken, // Add the cancel token here
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        final rawResponse = responseData['response'];
        final properties = rawResponse['properties'] as List;

        if (!isPro) {
          await DbServiceUser(uid: userId).updateCredits();
        }

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
            final existingListings =
                groupedListings[contact]!['listings'] as List;
            final isDuplicate = existingListings.any(
              (existingListing) =>
                  existingListing['location'] == listing['location'] &&
                  existingListing['description'] == listing['description'],
            );

            if (!isDuplicate) {
              groupedListings[contact]!['listings'].add({
                'date': listing['date'],
                'location': listing['location'],
                'description': listing['description'],
              });
            }
          }
        }

        final List<ChatMessage> rawMessageList = [];

        groupedListings.forEach((contact, data) {
          final name = data['name'];
          final listings = data['listings'] as List;

          listings.sort((a, b) {
            final dateTimeA = parseDate(a['date'] as String);
            final dateTimeB = parseDate(b['date'] as String);
            return dateTimeB.compareTo(dateTimeA); // Sort in descending order
          });

          // Select top 10 most recent listings
          final topListings = listings.take(10).toList();

          // Combine listings into a single message
          final messageText = StringBuffer();
          messageText.writeln('Name: $name');
          messageText.writeln('Contact: $contact');
          messageText.writeln();

          for (final listing in topListings) {
            final dateTime = parseDate(listing['date'] as String);

            messageText.writeln(
              'Listing date: ${DateFormat('dd/MM/yyyy').format(dateTime)}',
            );
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
            newMessageList.indexWhere((msg) => msg['id'] == placeholderId);
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
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // print('Request canceled: ${e.message}');
      } else {
        logError('Error in response: $e');
        _errorMessage =
            'Sorry, an error occurred while processing your request.';
        await addErrorMessage(placeholderId);
      }
    } finally {
      _isGenerating = false;
      _cancelToken = null; // Clear the token
    }
  }

  Future<void> addErrorMessage(String placeholderMsgId) async {
    final errorMessage = ChatMessage(
      id: uuid.v4(),
      text: _errorMessage,
      createdAt: DateTime.now(),
      typeOfMessage: TypeOfMessage.bot,
      chatBotId: state.id,
    );

    final newMessageList = List<Map<String, dynamic>>.from(state.messagesList);

    final int placeholderIndex =
        newMessageList.indexWhere((msg) => msg['id'] == placeholderMsgId);
    if (placeholderIndex != -1) {
      newMessageList.removeAt(placeholderIndex);
    }
    newMessageList.add(errorMessage.toJson());

    final newStateWithNewMessage = ChatBot(
      id: state.id,
      title: state.title,
      typeOfBot: state.typeOfBot,
      messagesList: newMessageList,
      attachmentPath: state.attachmentPath,
      embeddings: state.embeddings,
    );
    await updateChatBot(newStateWithNewMessage);
  }

  Future<void> stopGeneration() async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Request cancelled by user');
    }
    _isGenerating = false;
    final newMessageList = List<Map<String, dynamic>>.from(state.messagesList);

    final int placeholderIndex =
        newMessageList.indexWhere((msg) => msg['id'] == placeholderId);
    if (placeholderIndex != -1) {
      newMessageList.removeAt(placeholderIndex);
    }

    final stopMessage = ChatMessage(
      id: uuid.v4(),
      text: 'Search was cancelled',
      createdAt: DateTime.now(),
      typeOfMessage: TypeOfMessage.bot,
      chatBotId: state.id,
    );

    newMessageList.add(stopMessage.toJson());
    final newStateWithNewMessage = ChatBot(
      id: state.id,
      title: state.title,
      typeOfBot: state.typeOfBot,
      messagesList: newMessageList,
      attachmentPath: state.attachmentPath,
      embeddings: state.embeddings,
    );
    await updateChatBot(newStateWithNewMessage);
  }

  Future<void> regenerateResults() async {
    // Get the last user message and regenerate
    final lastUserMessage = state.messagesList.lastWhere(
      (msg) => msg['typeOfMessage'] == TypeOfMessage.user,
    );

    await getPythonAPIResponse(prompt: lastUserMessage['text'] as String);
  }

  Future<void> updateChatBot(ChatBot newChatBot) async {
    state = newChatBot;
    await HiveRepository().saveChatBot(chatBot: state);
  }
}
