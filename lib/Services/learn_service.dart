import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LearnArticle {
  final String title;
  final String url;
  final String source;
  final String summary;
  final String category; // news | trend | salary | skills | report | hiring
  final String recency;  // YYYY-MM

  LearnArticle({
    required this.title,
    required this.url,
    required this.source,
    required this.summary,
    required this.category,
    required this.recency,
  });

  factory LearnArticle.fromJson(Map<String, dynamic> j) => LearnArticle(
    title: (j['title'] ?? '').toString(),
    url: (j['url'] ?? '').toString(),
    source: (j['source'] ?? '').toString(),
    summary: (j['summary'] ?? '').toString(),
    category: (j['category'] ?? '').toString(),
    recency: (j['recency'] ?? '').toString(),
  );
}

class LearnResult {
  final String summary;               // 1–3 sentence overview
  final List<LearnArticle> articles;  // curated list

  LearnResult({required this.summary, required this.articles});
}

class LearnService {
  LearnService({
    String? apiKey,
    this.model = 'gpt-4o-mini',
  }) : openAIApiKey = apiKey ?? (dotenv.env['OPENAI_API_KEY'] ?? '');

  final String openAIApiKey;
  final String model;

  Future<LearnResult> getArticlesForTopic(String topic, {int count = 10}) async {
    if (openAIApiKey.isEmpty) {
      throw Exception('OpenAI API key missing (.env OPENAI_API_KEY).');
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAIApiKey',
    };

    final body = jsonEncode({
      'model': model,
      'temperature': 0.3,
      'messages': [
        {
          'role': 'system',
          'content':
          'You are a concise career research assistant. Return STRICT JSON only—no extra prose.'
        },
        {
          'role': 'user',
          'content': _buildPrompt(topic, count),
        },
      ],
    });

    final resp = await http.post(uri, headers: headers, body: body);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('OpenAI ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (decoded['choices'] as List).first['message']['content'] as String;

    final parsed = _safeJsonParse(content);

    if (parsed is! Map) throw Exception('Unexpected JSON from OpenAI.');
    final String brief = (parsed['summary'] ?? '').toString();
    final List items = (parsed['items'] is List) ? parsed['items'] as List : const [];

    final articles = items
        .map((e) => LearnArticle.fromJson(e as Map<String, dynamic>))
        .toList();

    return LearnResult(summary: brief, articles: articles);
  }

  String _buildPrompt(String topic, int count) => '''
Return JSON with a short "summary" and an "items" array of $count recent, reputable links about the "$topic" job market.
Rules:
- JSON ONLY (no commentary).
- "summary": 2–3 sentences, ≤ 60 words total. Mention demand, skills, and salary trend briefly.
- "items": array of objects with REQUIRED keys:
  - title (string)
  - url   (string, full http/https)
  - source (string)
  - summary (string, ≤ 35 words)
  - category (one of: news, trend, salary, skills, report, hiring)
  - recency (YYYY-MM)
- Prefer official sources, gov/edu reports, and reputable outlets. Avoid spam.
- Include mixed angles: hiring, skills, salary, macro reports, and role demand.

Example:
{
  "summary": "Hiring for X is rebounding... Skills Y/Z are in demand...",
  "items": [
    {
      "title": "2025 X Hiring Snapshot",
      "url": "https://example.com/snapshot",
      "source": "Example News",
      "summary": "Concise point on trend, roles, pay.",
      "category": "trend",
      "recency": "2025-07"
    }
  ]
}
''';

  dynamic _safeJsonParse(String content) {
    try {
      return jsonDecode(content);
    } catch (_) {
      final startObj = content.indexOf('{');
      final endObj = content.lastIndexOf('}');
      if (startObj == -1 || endObj == -1 || endObj <= startObj) rethrow;
      return jsonDecode(content.substring(startObj, endObj + 1));
    }
  }
}
