import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class MentorService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String?> getMentorReply(String message) async {
    const url = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {"role": "system", "content": "You are a helpful career mentor."},
          {"role": "user", "content":
          "You are a advisor giving job advice about a certain field. make sure answers sound human"
              "and conversational while being professional. less than 50 words"
              + message
          }
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content']?.trim();
    } else {
      print('Error from OpenAI: ${response.body}');
      return null;
    }
  }
}
