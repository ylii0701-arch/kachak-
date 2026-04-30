import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/map_keys.dart';

Future<Map<String, dynamic>> identifySpecies(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  // Hidden Instruction for Gemini
  final systemInstruction = '''
You are the KaChak AI species recognition engine.
Analyze the provided image and classify it. You must reply STRICTLY in JSON format with no markdown tags.

RULES:
1. If the image does NOT contain an animal (e.g., everyday objects, landscapes, humans, text), reply exactly with:
{"status": "NOT_ANIMAL"}

2. If the image contains an animal, but it is too blurry, too far away, heavily obscured, or the lighting is too poor to confidently identify the exact species, reply exactly with:
{"status": "UNCLEAR"}

3. If it is a clearly recognizable wildlife species, reply exactly with:
{
  "status": "SUCCESS",
  "commonName": "Common Name",
  "scientificName": "Scientific Name",
  "description": "Short 2-sentence description."
}
''';

  final payload = {
    'systemInstruction': {'parts': [{'text': systemInstruction}]},
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image}},
          {'text': 'Identify this species.'}
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.1,
      'responseMimeType': 'application/json',
    },
  };

  // Your friend's fallback loop mechanism
  const models = <String>[
    'gemini-3.1-flash-lite-preview',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
  ];

  for (final model in models) {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey');

    try {
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text = decoded['candidates'][0]['content']['parts'][0]['text'];
        return jsonDecode(text);
      } else if (response.statusCode == 404) {
        continue; // Try next model
      }
    } catch (e) {
      debugPrint('Error with $model: $e');
    }
  }
  return {"status": "ERROR", "message": "Failed to connect to AI."};
}