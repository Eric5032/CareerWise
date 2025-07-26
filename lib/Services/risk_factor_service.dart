import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CareerAIService {
  final OpenAI _openAI = OpenAI.instance.build(
    token: dotenv.env['OPENAI_API_KEY'],
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)),
  );

  Future<Map<String, dynamic>?> getAutomationRisk(String jobTitle) async {
    final prompt = '''
You are an expert career advisor. A user is exploring career options and wants to understand the automation risk of a specific job.

Based on your training data and current technological trends, estimate the likelihood (as a percentage) that the following job will be automated in the future. Use this percentage to assign a risk level:

- 0% to 30% → "Low"
- 31% to 70% → "Medium"
- 71% to 100% → "High"

Job Title: $jobTitle

Please return the result in this exact JSON format:
{
  "job_title": "$jobTitle",
  "job_description": "[Short description of the job]",
  "risk_level": "Low | Medium | High",
  "automation_risk_percent": [number between 0 and 100],
  "explanation": "[Short explanation of the automation risk]",
  "future_proof_tips": [
    "Tip 1",
    "Tip 2",
    "Tip 3"
  ]
}
written clearly and simply for anyone to understand
''';

    final request = ChatCompleteText(
      messages: [
        Map.of({"role": "user", "content": prompt}),
      ],
      maxToken: 2000,
      model: Gpt4ChatModel(),
    );

    ChatCTResponse? response =
    await _openAI.onChatCompletion(request: request);
    if (response != null && response.choices.isNotEmpty) {
      try {
        final jsonString = response.choices.first.message!.content.trim();
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
