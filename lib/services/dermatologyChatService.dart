import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class DermatologyChatService {
  static Future<String?> sendMessage({required String prompt}) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${Constantes.geminiApiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": _buildPrompt(prompt)},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          },
          // Se eliminaron completamente los safetySettings
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Error de Gemini: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al enviar mensaje a Gemini: $e');
      return null;
    }
  }

  static String _buildPrompt(String userPrompt) {
    return '''
Eres un dermatólogo virtual especializado en dermatología.

Solo debes responder preguntas sobre:
- Enfermedades de la piel
- Tratamientos dermatológicos
- Cuidados básicos de la piel

Si la pregunta no es sobre dermatología, responde:
"Lo siento, solo puedo ayudarte con temas dermatológicos."

Usuario: $userPrompt
''';
  }
}
