import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

// API Keys
// ignore: constant_identifier_names
const String EL_API_KEY = 'sk_817fe8b8b146ba0acf3a0ecbcc9f93d1f1bb5687b00ee4a3';
// ignore: constant_identifier_names
const String GEMINI_API_KEY = 'AIzaSyAxrZhU0GJrRb4wUrK0fxte-s5fmsZ_ibE';

// Schema Definitions

Map<String, Object?> searchProperties(Map<String, Object?> args) {
  // 1. Extract arguments
  final requirement = args['requirement'] as String?;
  final area = args['area'] as num?;
  final location = args['location'] as String?;
  final price = args['price'] as num?;
  final propertySubtype = args['property_subtype'] as String?;

  // 2. Debug print to see if it was called
  debugPrint('searchProperties called with: '
      'requirement=$requirement, area=$area, location=$location, '
      'price=$price, property_subtype=$propertySubtype');

  // 3. Do your "search" (or mock it)
  // For example, you can return a list of properties as JSON:
  final results = [
    {
      'title': '2BHK Flat in $location',
      'price': price ?? 25000,
      'area': area ?? 1200,
      'requirement': requirement ?? 'Rent',
      'subtype': propertySubtype ?? '2BHK Flat',
    },
    // ... up to 5 properties
  ];

  // 4. Return a response object that the AI can parse
  return {'results': results};
}

final searchPropertiesFunction = FunctionDeclaration(
  'searchProperties',
  'Search properties with the given parameters.',
  Schema.object(
    properties: {
      'requirement':
          Schema.string(description: 'Rent, Sale, Ratio Deal', nullable: true),
      'area': Schema.number(description: 'Area in square feet', nullable: true),
      'location': Schema.string(
        description: 'Location mentioned (city or area)',
        nullable: true,
      ),
      'price': Schema.number(
        description: 'Budget for property in rupees',
        nullable: true,
      ),
      'property_subtype': Schema.string(
        description: 'e.g. Office, Shop, 2BHK flat, 3BHK house, etc.',
        nullable: true,
      ),
    },
  ),
);

final functions = {
  searchPropertiesFunction.name: searchProperties,
};
FunctionResponse dispatchFunctionCall(FunctionCall call) {
  final function = functions[call.name]!;
  final result = function(call.args);
  return FunctionResponse(call.name, result);
}

final chatmodel = GenerativeModel(
  model: 'gemini-2.0-flash-exp',
  apiKey: GEMINI_API_KEY,
  tools: [
    Tool(functionDeclarations: [searchPropertiesFunction]),
  ],
  systemInstruction: Content.system(
    """
-  You are an AI real estate agent to help people in their search for properties.
- The users will provide you the data on the type of properties they are looking for.
- You need to capture at least 2 of the following query paramaters from the conversation, and ask for any missing ones if they want but only once.

requirement: Optional[str] = Field(description="Type of requirement: Rent, Sale, Ratio Deal")
area: Optional[int] = Field(description="Area in square feet")
location: Optional[str] = Field(description="The specific location mentioned (if any)")
price: Optional[int] = Field(description="Price of the property in rupees")
property_subtype: Optional[str] = Field(description=Subtype of property based on category:         
                                        Commercial: Office, Shop, Showroom, School, College, Hospital
                                        Land: Agricultural land, Commercial land, Industrial land, Residential Plot, Commercial Plot
                                        Industrial: Factory, Warehouse, Godown
                                        Hospitality: Hotel, Resort, Farmhouse
                                        Residential: Hostel, 1bhk Flat, 2bhk flat, 3bhk flat, 4bhk flat, 5bhk flat, 1RK Flat, Studio Apartment, 1bhk house, 2bhk house, 3bhk house, 4bhk house, 5bhk house

- After getting user requirements, call `searchProperties` with the identified parameters.
- Tell them about the top 5 properties briefly that matches the closest with their requirements.
- If they don't like any of these properties then give them 3 more options.
- keep asking them if they need to make any modifications or search more and continue the chat like that.

PERSONALITY:
- Be upbeat and genuine
- Talk to them in casual Hindi.
""",
  ),
);

const String welcomeMessage = 'Hi, kaise ho aap?';

// Text to Speech Utility
Future<void> playTextToSpeech(
  String text,
  // ignore: avoid_positional_boolean_parameters
  bool isMuted,
  AudioPlayer player,
) async {
  if (isMuted) {
    return;
  }

  const String voiceRachel = 'SGbOfpm28edC83pZ9iGb';
  const String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'accept': 'audio/mpeg',
      'xi-api-key': EL_API_KEY,
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'text': text,
      'model_id': 'eleven_flash_v2_5',
      'voice_settings': {'stability': .45, 'similarity_boost': .40},
    }),
  );

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    await player.setAudioSource(MyCustomSource(bytes));
    await player.play();
  }
}

// Custom Audio Source
class MyCustomSource extends StreamAudioSource {
  MyCustomSource(this.bytes);
  final List<int> bytes;

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
