import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

// API Keys
const String EL_API_KEY = 'sk_817fe8b8b146ba0acf3a0ecbcc9f93d1f1bb5687b00ee4a3';
const String GEMINI_API_KEY = "AIzaSyAxrZhU0GJrRb4wUrK0fxte-s5fmsZ_ibE";

// Schema Definitions

final chatmodel = GenerativeModel(
  model: 'gemini-2.0-flash-exp',
  apiKey: GEMINI_API_KEY,
  systemInstruction: Content.system(
    'You are a helpful assistant that can answer questions and help with tasks.',
  ),
);

const String welcomeMessage = 'Hi, kaise ho aap?';

// Text to Speech Utility
Future<void> playTextToSpeech(
    String text, bool isMuted, AudioPlayer player) async {
  if (isMuted) return;

  String voiceRachel = 'SGbOfpm28edC83pZ9iGb';
  String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'accept': 'audio/mpeg',
      'xi-api-key': EL_API_KEY,
      'Content-Type': 'application/json',
    },
    body: json.encode({
      "text": text,
      "model_id": "eleven_flash_v2_5",
      "voice_settings": {"stability": .45, "similarity_boost": .40}
    }),
  );

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    await player.setAudioSource(MyCustomSource(bytes));
    player.play();
  }
}

// Custom Audio Source
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
