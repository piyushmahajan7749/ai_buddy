import 'package:ai_buddy/core/app/app.dart';
import 'package:ai_buddy/feature/hive/model/chat_bot/chat_bot.dart';
import 'package:ai_buddy/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';

late FirebaseAuth auth;

Future<void> initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();

  Hive
    ..init(appDocumentDir.path)
    ..registerAdapter(ChatBotAdapter());

  try {
    final box = await Hive.openBox<ChatBot>('chatBots');
    if (box.isEmpty) {
      // Add a default ChatBot if the box is empty
      await box.add(ChatBot.defaultInstance());
    }
  } catch (e) {
    print('Error initializing Hive: $e');
    await Hive.deleteBoxFromDisk('chatBots');
    final box = await Hive.openBox<ChatBot>('chatBots');
    await box.add(ChatBot.defaultInstance());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instance;
  _initLoggy();
  _initGoogleFonts();
  await initHive();

  runApp(
    const ProviderScope(
      child: AIBuddy(),
    ),
  );
}

void _initLoggy() {
  Loggy.initLoggy(
    logOptions: const LogOptions(
      LogLevel.all,
      stackTraceLevel: LogLevel.warning,
    ),
    logPrinter: const PrettyPrinter(),
  );
}

void _initGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
