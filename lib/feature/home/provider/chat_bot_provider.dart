import 'package:ai_buddy/feature/gemini/repository/gemini_repository.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/feature/hive/repository/hive_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final chatBotListProvider =
    StateNotifierProvider<ChatBotListNotifier, List<ChatBot>>(
  (ref) => ChatBotListNotifier(),
);

class ChatBotListNotifier extends StateNotifier<List<ChatBot>> {
  ChatBotListNotifier() : super([]) {
    hiveRepository = HiveRepository();
    dio = Dio(BaseOptions(baseUrl: 'http://192.168.29.89:5000'));
    geminiRepository = GeminiRepository();
  }

  late final HiveRepository hiveRepository;
  late final Dio dio;
  late final GeminiRepository geminiRepository;

  Future<String?>? attachImageFilePath() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile?.path;
  }

  Future<void> fetchChatBots() async {
    final chatBotsList = await hiveRepository.getChatBots();
    state = chatBotsList;
  }

  Future<void> saveChatBot(ChatBot chatBot) async {
    await hiveRepository.saveChatBot(chatBot: chatBot);
    state = [chatBot, ...state];
  }

  Future<void> updateChatBotOnHomeScreen(ChatBot chatBot) async {
    final index = state.indexWhere((element) => element.id == chatBot.id);
    if (index != -1) {
      state[index] = chatBot;
      state = List.from(state);
    }
    await deleteChatBotsWithEmptyTitle();
  }

  Future<void> deleteChatBotsWithEmptyTitle() async {
    final chatBotsWithNonEmptyTitle =
        state.where((chatBot) => chatBot.title.isNotEmpty).toList();
    for (final chatBot in state.where((chatBot) => chatBot.title.isEmpty)) {
      await hiveRepository.deleteChatBot(chatBot: chatBot);
    }
    state = chatBotsWithNonEmptyTitle;
  }

  Future<void> deleteChatBot(ChatBot chatBot) async {
    await hiveRepository.deleteChatBot(chatBot: chatBot);
    state = state.where((item) => item.id != chatBot.id).toList();
  }

  Future<void> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(filePath),
      });

      // ignore: inference_failure_on_function_invocation
      final response = await dio.post('/upload', data: formData);

      // Handle response and update state as needed
      print(response.data);
    } catch (e) {
      // Handle error
      print('Error uploading file: $e');
      throw e;
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      // ignore: inference_failure_on_function_invocation
      final response = await dio.post('/chat', data: {'message': message});

      // Return the response from the server
      return response.data['response'] as String;
    } catch (e) {
      // Handle error
      print('Error sending message: $e');
      throw e;
    }
  }
}
