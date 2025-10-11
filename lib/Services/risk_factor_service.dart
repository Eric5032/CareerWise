// lib/Services/career_ai_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CareerAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final Uri _endpoint = Uri.parse('https://api.openai.com/v1/chat/completions');

  // You can keep your existing model; this one is generally better/cheaper.
  static const String _model = 'gpt-4o-mini';

  Future<Map<String, dynamic>?> getAutomationRisk(String jobTitle) async {
    if (_apiKey.isEmpty) {
      print('❌ Missing OPENAI_API_KEY in .env');
      return null;
    }

    final prompt = '''
Respond ONLY with a single valid JSON object (no backticks, no prose).
Add atleast 5 notable companies.
For the job "$jobTitle", return exactly this schema:

{
  "job_title": "Software Engineer",
  "automation_risk_percent": 18,
  "risk_level": "Low",
  "job_description": "1-2 sentences summarizing the role.",
  "explanation": "1-2 sentences explaining the risk level.",
  "skills_needed": [
    "Skill 1",
    "Skill 2",
    "Skill 3"
  ],
  "notable_companies": [
    {
      "name": "company1",
      "website": "companywebsite.com",
      "logo_url": "https://logo.clearbit.com/companylogo.com"
    },
  ]
  "average_salary": 100,000/year 
  "job_outlook": "increasing"
  "job_outlook_percentage": "20%"
  "entry_level_education": "Bachelor's degree"
}
- "automation_risk_percent" must be an integer 0–100.
- "risk_level" must be "Low", "Medium", or "High".
- "future_proof_tips" must be a non-empty array of strings.
- "notable_companies" must be a non-empty array of objects with "name", "website" (domain only), and "logo_url" built as "https://logo.clearbit.com/<website>".
- "degree_recommendation" must be a array of objects with "degree" that show specific degrees that fit this career, 'logo_url' that shows the cartoon and simple badge that fits the degree(flask for science, Computer for IT, Camera for media, Bitcoin for Finance)
''';

    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": "You are a careful assistant who outputs strict JSON that matches the requested schema."},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.4,
      "max_tokens": 700,
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

      final parsed = _extractJsonFromContent(rawContent);
      if (parsed == null) return null;

      // --- Post-process: ensure each company has a logo_url derived from website ---
      if (parsed['notable_companies'] is List) {
        final List comps = parsed['notable_companies'];
        for (var i = 0; i < comps.length; i++) {
          final c = comps[i];
          if (c is Map<String, dynamic>) {
            final website = (c['website'] ?? '').toString().trim();
            if ((c['logo_url'] == null || (c['logo_url'] as String).isEmpty) && website.isNotEmpty) {
              final domain = website
                  .replaceAll(RegExp(r'^https?://'), '')
                  .split('/')
                  .first;
              c['logo_url'] = 'https://logo.clearbit.com/$domain';
            }
          }
        }
      }

      return parsed;
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
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Failed to parse JSON from content: $e\nContent:\n$content');
      return null;
    }
  }
}
