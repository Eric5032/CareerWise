import 'package:career_guidance/Screens/mentor_screen.dart';
import 'package:flutter/material.dart';
import '../data/saved_jobs.dart'; // contains: List<Map<String, dynamic>> savedJobs = [];

class JobPage extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobPage({super.key, required this.jobData});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final TextEditingController _controller = TextEditingController();
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = savedJobs.any((job) => job['job_title'] == widget.jobData['job_title']);
  }

  void toggleSave() {
    setState(() {
      if (isSaved) {
        savedJobs.removeWhere((job) => job['job_title'] == widget.jobData['job_title']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Job removed from saved")),
        );
      } else {
        savedJobs.add(widget.jobData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Job saved")),
        );
      }
      isSaved = !isSaved;
    });
  }

  Color getBadgeColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobData = widget.jobData;
    final title = jobData['job_title'] ?? 'Unknown Job';
    final description = jobData['job_description'] ?? 'No description available.';
    final riskLevel = jobData['risk_level'] ?? 'Unknown';
    final riskPercent = jobData['automation_risk_percent'] ?? 0;
    final explanation = jobData['explanation'] ?? '';
    final tips = List<String>.from(jobData['future_proof_tips'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Badge and risk
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getBadgeColor(riskLevel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      riskLevel.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$riskPercent% risk of automation',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📝 Job Description", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("💡 Why is this the risk?", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(explanation),
              ],
            ),
          ),


          const SizedBox(height: 20),

          if (tips.isNotEmpty) ...[

            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🛡️ Future-Proof Tips", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...tips.map((tip) => ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.blueAccent),
                    title: Text(tip),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: null, // unlimited but capped by parent
                    decoration: const InputDecoration(
                      hintText: "Ask something about this job...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                    ),
                  ),
                ),

                // 🚀 Submit Button

                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape:  BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        _controller.clear();
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MentorScreen(initialMessage: text),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 16),

          // ✅ Save/Unsave Toggle
          ElevatedButton.icon(
            onPressed: toggleSave,
            icon: Icon(isSaved ? Icons.bookmark_remove : Icons.bookmark_add),
            label: Text(isSaved ? "Unsave Job" : "Save Job"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved ? Colors.red : Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
