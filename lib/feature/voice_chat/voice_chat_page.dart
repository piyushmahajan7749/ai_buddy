import 'dart:convert';

import 'package:ai_buddy/feature/voice_chat/chatutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:just_audio/just_audio.dart';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  final player = AudioPlayer();
  late final _provider = GeminiProvider(
    model: chatmodel, // Replace with your model
  );

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.history = List.from(_provider.history)
        ..add(
          ChatMessage(
            origin: MessageOrigin.llm,
            text: 'Hello! aap kis type ki properties dhoond rahe hain?',
            attachments: [],
          ),
        );
      setState(() {});
    });
  }

  Future<void> playTextToSpeech(String text) async {
    if (_isMuted) return;
    // Implement text-to-speech functionality here
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat'),
        actions: [
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) player.stop();
              });
            },
          ),
        ],
      ),
      body: LlmChatView(
          provider: _provider,
          style: _getChatStyle(context),
          messageSender: (prompt, {required attachments}) async* {
            await for (final message in _provider.sendMessageStream(
              prompt,
              attachments: attachments,
            )) {
              debugPrint("Received message: $message");

              // Check if the message is likely JSON (starts with '{')
              if (message.trim().startsWith('{')) {
                try {
                  final decoded = json.decode(message);
                  debugPrint("Decoded JSON: $decoded");

                  if (decoded is Map<String, dynamic> &&
                      decoded.containsKey('functionCall')) {
                    // Extract function call details.
                    final functionCallData = decoded['functionCall'];
                    debugPrint("Extracted functionCallData: $functionCallData");

                    // Create a FunctionCall object.
                    final call = FunctionCall(
                      functionCallData['name'] as String,
                      Map<String, Object?>.from(
                        functionCallData['args'] as Map<dynamic, dynamic>,
                      ),
                    );
                    debugPrint("Created FunctionCall: $call");

                    // Dispatch the function call.
                    final functionResponse = dispatchFunctionCall(call);
                    debugPrint(
                        "Function response: ${functionResponse.response}");
                    yield functionResponse.response.toString();
                    continue;
                  } else {
                    debugPrint(
                        "No functionCall key found in JSON. Processing as plain text.");
                  }
                } catch (e, stacktrace) {
                  debugPrint("Error decoding JSON: $e");
                  debugPrint("Stacktrace: $stacktrace");
                }
              }
              // If not JSON or if JSON doesn't include functionCall, process as plain text.
              await playTextToSpeech(message);
              yield message;
            }
          }),
    );
  }

  LlmChatViewStyle _getChatStyle(BuildContext context) {
    return LlmChatViewStyle(
      backgroundColor: Theme.of(context).colorScheme.surface,
      llmMessageStyle: LlmMessageStyle(
        markdownStyle: MarkdownStyleSheet(
          pPadding: const EdgeInsets.all(10),
          p: Theme.of(context).textTheme.bodyLarge!,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          border: Border.all(color: Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      userMessageStyle: UserMessageStyle(
        textStyle: Theme.of(context).textTheme.bodyLarge!,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(color: Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      recordButtonStyle: ActionButtonStyle(
        iconColor: Theme.of(context).primaryColor,
        icon: Icons.mic_outlined,
        iconDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
      ),
      stopButtonStyle: ActionButtonStyle(
        iconColor: Theme.of(context).primaryColor,
        icon: Icons.stop,
        iconDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
      ),
      submitButtonStyle: ActionButtonStyle(
        iconColor: Theme.of(context).primaryColor,
        icon: Icons.send_rounded,
        iconDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
      ),
      chatInputStyle: ChatInputStyle(
        textStyle: Theme.of(context).textTheme.bodyLarge!,
        hintText: 'Type or speak your message...',
        backgroundColor: Theme.of(context).colorScheme.surface,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.rectangle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            strokeAlign: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}
