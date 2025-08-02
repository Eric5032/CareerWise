import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CareerAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final Uri _endpoint = Uri.parse('https://api.openai.com/v1/chat/completions');

  Future<Map<String, dynamic>?> getAutomationRisk(String jobTitle) async {
    if (_apiKey.isEmpty) {
      print('❌ Missing OPENAI_API_KEY in .env');
      return null;
    }

    final prompt = '''
Respond ONLY in raw JSON. For the job "$jobTitle", return a response like:

{
  "job_title": "Software Engineer",
  "automation_risk_percent": 18,
  "risk_level": "Low",
  "job_description": "Designs and builds software applications.",
  "explanation": "Involves creative thinking, problem-solving, and human collaboration.",
  "future_proof_tips": [
    "Improve communication skills",
    "Stay updated with emerging tech",
    "Focus on roles requiring human empathy"
  ]
}
''';

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
      "max_tokens": 600,
    });

    try {
      final response = await http.post(
        _endpoint,
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode != 200) {
        print('❌ OpenAI API error (${response.statusCode}): ${response.body}');
        return null;
      }

      final responseJson = jsonDecode(response.body);
      final rawContent = responseJson['choices']?[0]?['message']?['content'];
      if (rawContent == null) {
        print('❌ Missing content in OpenAI response');
        return null;
      }

      return _extractJsonFromContent(rawContent);
    } catch (e) {
      print('❌ Request failed: $e');
      return null;
    }
  }

  Map<String, dynamic>? _extractJsonFromContent(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        throw const FormatException("JSON not found in response content.");
      }

      final jsonStr = content.substring(start, end + 1);
      return json.decode(jsonStr);
    } catch (e) {
      print('❌ Failed to parse JSON from content: $e\nContent:\n$content');
      return null;
    }
  }
}
