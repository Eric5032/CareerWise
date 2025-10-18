import 'package:flutter/material.dart';
import 'package:career_guidance/Theme/theme.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final List<int> _selectedRatings = List<int>.filled(5, 0);
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<String> _freeResponses = List.filled(5, '');
  final List<dynamic> _ExpandableResponses = List.filled(5, List<String>);

  void _setRating(int rating, int qIndex) {
    setState(() {
      _selectedRatings[qIndex] = rating;
    });
  }

  void _setFreeResponse(String response, int qIndex) {
    _freeResponses[qIndex] = response;
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ratingScaleCardBuilder("How well do you work in a team?", 0),
            freeResponseCardBuilder(
              "Describe your ideal work environment.",
              0,
              _controllers[0],
            ),
            ratingScaleCardBuilder(
              "You prefer working independently rather than in teams?",
              1,
            ),
            freeResponseCardBuilder(
              "What motivates you the most at work?",
              1,
              _controllers[1],
            ),
            ratingScaleCardBuilder(
              "You thrive in fast paced and dynamic work environment?",
              0,
            ),
            ExpandableFreeResponseCardBuilder(
              "What are your hobbies? Describe your weekly activity and why you are interested.",
              0,
              _controllers[2],
            ),
          ],
        ),
      ),
    );
  }

  Container ratingScaleCardBuilder(String prompt, int qIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: kBannerColor,
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final ratingValue = index + 1;
              return GestureDetector(
                onTap: () => _setRating(ratingValue, qIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedRatings[qIndex] == ratingValue
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: _selectedRatings[qIndex] == ratingValue
                            ? const Center(
                                child: CircleAvatar(
                                  radius: 7,
                                  backgroundColor: Colors.blue,
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

  Container freeResponseCardBuilder(
    String prompt,
    int qIndex,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: kBannerColor,
        boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: (value) {
              _setFreeResponse(value, qIndex);
            },
            maxLines: null, // Allows multi-line input
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container ExpandableFreeResponseCardBuilder(
    String prompt,
    int qIndex,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: kBannerColor,
        boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt,
            softWrap: true,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: (value) {
              _setFreeResponse(value, qIndex);
            },
            maxLines: null, // Allows multi-line input
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
          Center(
            child: TextButton(onPressed: () {}, child: Text("Add")),
          ),
        ],
      ),
    );
  }
}
