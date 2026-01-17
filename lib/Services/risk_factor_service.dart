// lib/Services/career_ai_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:career_guidance/data/soft_skills.dart';

class CareerAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final Uri _endpoint = Uri.parse('https://api.openai.com/v1/chat/completions');

  static const String _model = 'gpt-4o-mini';

  Future<Map<String, dynamic>?> getAutomationRisk(String jobTitle) async {
    if (_apiKey.isEmpty) {
      print('❌ Missing OPENAI_API_KEY in .env');
      return null;
    }

    // Get the list of soft skill categories from the map



    final prompt = '''
Respond ONLY with a single valid JSON object (no backticks, no prose).
Add atleast 5 notable companies.
For the job "$jobTitle", return exactly this schema:

{
  "job_title": $jobTitle,
  "automation_risk_percent": "integer",
  "job_description": "3-4 sentences summarizing the role.",
  "explanation": "3-4 sentences explaining the risk level.",
  "hard_skills": [
     5 hard skills for the job  
  ],
  "soft_skills": [
     2-5 soft skill from $soft_skills_data
  ],
  "soft_skills_application": "3-4 sentences explaining how the soft skills listed above are specifically applicable and important for this job role. Be specific about how each skill category helps in day-to-day tasks.",
  "notable_companies": [
    {
      "name": "company1",
      "website": "https://companywebsite.com",
      "logo_url": "https://logo.clearbit.com/companylogo.com"
    }
  ],
  "degree_recommendation": [
    {
      "degree": "Bachelor's in Computer Science",
      "logo_url": "https://logo.clearbit.com/domain.com"
    }
  ],
  "average_salary": "100,000/year",
  "job_outlook": "increasing",
  "job_outlook_percentage": "20%",
  "entry_level_education": "Bachelor's degree"
}

CRITICAL RULES:
- "hard_skills" must contain 5-8 SPECIFIC technical skills, tools, programming languages, or certifications. 
  Examples: "Python", "JavaScript", "React", "AutoCAD", "Adobe Photoshop", "SQL", "AWS", "Excel", "Salesforce"
  DO NOT use generic phrases like "Programming Languages" or "Software Development" - be specific!
- "soft_skills" must contain exactly 5 skills chosen ONLY from this exact list:
  [$soft_skills_data]
  You MUST pick exactly 5 categories from this list that are most relevant for this specific job.
  DO NOT create new categories or modify these names - use them exactly as written.
- "soft_skills_application" must be 3-4 sentences explaining HOW these specific soft skills apply to this job's daily tasks.
- "automation_risk_percent" must be an integer 0–100.
- "average_salary" must have comma every 3 digits and include "/year"
- "job_outlook_percentage" show the projected growth in the range of 10 years from now
- "job_outlook" must be either "increasing" or "decreasing"
- "notable_companies" must be a non-empty array of objects with "name", "website" (full URL), and "logo_url" built as "https://logo.clearbit.com/<domain>".
- "degree_recommendation" must be an array of objects with "degree" that shows specific degrees that fit this career, and 'logo_url' that shows a relevant icon from clearbit.
''';

    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": "You are a careful assistant who outputs strict JSON that matches the requested schema. Always be specific with technical skills."},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.4,
      "max_tokens": 900,
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
        print('OpenAI API error (${response.statusCode}): ${response.body}');
        return null;
      }

      final responseJson = jsonDecode(response.body);
      final rawContent = responseJson['choices']?[0]?['message']?['content'];
      if (rawContent == null) {
        print('Missing content in OpenAI response');
        return null;
      }

      final parsed = _extractJsonFromContent(rawContent);
      print(parsed?['soft_skills']);
      if (parsed == null) return null;

      // Fix logo URLs for companies
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

      // Rename skills_needed to hard_skills for backwards compatibility
      if (parsed.containsKey('hard_skills')) {
        parsed['skills_needed'] = parsed['hard_skills'];
      }

      return parsed;
    } catch (e) {
      print('Error in getAutomationRisk: $e');
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
      print('Error extracting JSON: $e');
      return null;
    }
  }
}