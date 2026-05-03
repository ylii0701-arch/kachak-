import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/map_keys.dart';

Future<Map<String, dynamic>> identifySpecies(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  return identifySpeciesFromBytes(bytes);
}

Future<Map<String, dynamic>> identifySpeciesFromBytes(Uint8List bytes) async {
  if (geminiApiKey.isEmpty) {
    return {
      "status": "ERROR",
      "message":
          "Gemini API key is missing. Rebuild with --dart-define=GEMINI_API_KEY=...",
    };
  }
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
    'systemInstruction': {
      'parts': [
        {'text': systemInstruction},
      ],
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {
            'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
          },
          {'text': 'Identify this species.'},
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.1,
      'responseMimeType': 'application/json',
    },
  };

  // Primary + fallback model strategy.
  const models = <String>['gemini-3.1-flash-lite-preview', 'gemini-2.5-flash'];
  final stopwatch = Stopwatch()..start();
  const maxTotalDuration = Duration(seconds: 25);

  String? lastError;
  for (final model in models) {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey',
    );

    try {
      http.Response? response;
      for (var attempt = 0; attempt < 2; attempt++) {
        final remaining = maxTotalDuration - stopwatch.elapsed;
        if (remaining <= Duration.zero) {
          return {
            "status": "ERROR",
            "message":
                "Recognition request timed out after 25 seconds. Please try again.",
          };
        }
        response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(remaining);
        if (response.statusCode == 503 && attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          continue;
        }
        break;
      }
      if (response == null) {
        return {
          "status": "ERROR",
          "message": "Gemini request did not return a response.",
        };
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          return {
            "status": "ERROR",
            "message": "Gemini returned an empty response.",
          };
        }
        final candidate = candidates.first as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          return {
            "status": "ERROR",
            "message": "Gemini returned empty content.",
          };
        }
        final text = parts
            .map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
            .join('\n')
            .trim();
        if (text.isEmpty) {
          return {
            "status": "ERROR",
            "message": "Gemini returned empty content text.",
          };
        }
        try {
          return jsonDecode(text) as Map<String, dynamic>;
        } catch (_) {
          return {
            "status": "ERROR",
            "message": "Gemini response format was invalid. Please retry.",
          };
        }
      }

      lastError = _extractGeminiError(response);
      if (response.statusCode == 404) {
        continue; // Try next model
      }
      return {"status": "ERROR", "message": lastError};
    } catch (e) {
      debugPrint('Error with $model: $e');
      lastError =
          'Unable to reach Gemini. Please check your network and retry.';
    }
  }
  return {
    "status": "ERROR",
    "message":
        lastError ??
        "Gemini model is unavailable for this key/project. Check model access and quota.",
  };
}

String _extractGeminiError(http.Response response) {
  try {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final err = decoded['error'] as Map<String, dynamic>?;
    final message = (err?['message'] as String?)?.trim();
    if (message != null && message.isNotEmpty) {
      return 'Gemini request failed (${response.statusCode}): $message';
    }
  } catch (_) {
    // Fall through to generic status message.
  }
  return 'Gemini request failed (${response.statusCode}). Please verify API key, quota, and model access.';
}
