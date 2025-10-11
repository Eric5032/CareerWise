import 'package:flutter/material.dart';
import 'package:career_guidance/Theme/theme.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _selectedRating = 0;

  void _setRating(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Forms Style Rating')),
      body: Center(
        child: Column(
          children: [
            ratingScaleCardBuilder("How well do you work in a team?"),
            ratingScaleCardBuilder("How well do you work in a team?"),
            ratingScaleCardBuilder("How well do you work in a team?"),
            ratingScaleCardBuilder("How well do you work in a team?"),
            ratingScaleCardBuilder("How well do you work in a team?"),

          ],
        ),
      ),
    );
  }

  Container ratingScaleCardBuilder(String prompt) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: kBannerColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 3),
            blurRadius: 2,
          ),
        ]
      ),

      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
                prompt,
                style: TextStyle(
                  fontSize: 16,
                ),
            ),
          ),
          SizedBox(height: 12),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final ratingValue = index + 1;

                return GestureDetector(
                  onTap: () => _setRating(ratingValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circle (radio-style)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedRating == ratingValue
                                  ? Colors.blue
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: _selectedRating == ratingValue
                              ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ratingValue.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}