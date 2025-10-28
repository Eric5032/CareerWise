import 'dart:convert';
import 'package:career_guidance/Theme/theme.dart';
import 'package:career_guidance/Screens/mentor_screen.dart';
import 'package:flutter/material.dart';
import '../data/saved_jobs.dart';
import 'company_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final double SIZEDBOXHEIGHT = 8.0;
final double SIZEDBOXWIDTH = 10.0;
const double HPADDING = 14.0;
const double VPADDING = 14.0;

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
    isSaved = savedJobs.any(
      (job) => job['job_title'] == widget.jobData['job_title'],
    );
  }

  Future<void> _persistSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_jobs_list', jsonEncode(savedJobs));
      debugPrint('Job list persisted: ${savedJobs.length} jobs');
    } catch (e) {
      debugPrint('Failed to persist jobs: $e');
    }
  }

  void toggleSave() async{
    setState(() {
      if (isSaved) {
        savedJobs.removeWhere(
          (job) => job['job_title'] == widget.jobData['job_title'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Job removed from saved")),
        );
      } else {
        savedJobs.add(widget.jobData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Job saved")));
      }
      isSaved = !isSaved;
    });
    await _persistSavedJobs();
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
    final theme = Theme.of(context);
    final jobData = widget.jobData;
    final title = jobData['job_title'] ?? 'Unknown Job';
    final description =
        jobData['job_description'] ?? 'No description available.';
    final riskLevel = jobData['risk_level'] ?? 'Unknown';
    final riskPercent = jobData['automation_risk_percent'] ?? 0;
    final explanation = jobData['explanation'] ?? '';
    final averageSalary = jobData['average_salary'] ?? 0;
    final jobOutlook = jobData['job_outlook'] ?? '';
    final String jobOutlookPercentage = jobData['job_outlook_percentage'] ?? '';
    final String entryLevelEducation = jobData['entry_level_education'] ?? '';

    // 🔹 Notable companies (array of {name, website, logo_url})
    final List<Map<String, dynamic>> companies =
        List<Map<String, dynamic>>.from(
          (jobData['notable_companies'] ?? const []),
        );
    final List<Map<String, dynamic>> degrees =
        List<Map<String, dynamic>>.from(
            (jobData['degree_recommendation'] ?? const [])
        );

    return Scaffold(
      backgroundColor: kSurfaceLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: kBannerColor,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Badge and risk
          Card(
            color: kBackgroundLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getBadgeColor(riskLevel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      riskLevel.toUpperCase(),
                      style: const TextStyle(
                        color: kBackgroundLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$riskPercent% risk of automation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: kBackgroundLight,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📝 Job Description",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),

          SizedBox(height: SIZEDBOXHEIGHT),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: kBackgroundLight,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💡 Why is this the risk?",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(explanation),
              ],
            ),
          ),

          SizedBox(height: SIZEDBOXHEIGHT),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HPADDING,
                    vertical: VPADDING,
                  ),
                  decoration: BoxDecoration(
                    color: kBackgroundLight,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Annual Pay",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$${averageSalary.toString()}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SIZEDBOXWIDTH),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HPADDING,
                    vertical: VPADDING,
                  ),
                  decoration: BoxDecoration(
                    color: kBackgroundLight,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Job Outlook",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Image.asset(
                            jobOutlook == "increasing" ?
                            'assets/icons/increase.png' : 'assets/icons/decrease.png',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 3,),
                          Text(
                            jobOutlookPercentage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SIZEDBOXWIDTH),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HPADDING,
                    vertical: VPADDING,
                  ),
                  decoration: BoxDecoration(
                    color: kBackgroundLight,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Entry Level Education",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entryLevelEducation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (companies.isNotEmpty) ...[
            Card(
              color: kBannerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🏢 Notable Companies",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: companies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final company = companies[index];
                          final name = (company['name'] ?? '').toString();
                          final logoUrl = (company['logo_url'] ?? '')
                              .toString();
                          final website = (company['website'] ?? '').toString();

                          final tile = Container(
                            width: 180,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: kBackgroundLight,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // Circular logo with graceful fallback
                                ClipOval(
                                  child: Image.network(
                                    logoUrl.isNotEmpty
                                        ? logoUrl
                                        : 'about:blank',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, _, __) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.grey.shade200,
                                        alignment: Alignment.center,
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CompanyPage(
                                    name: name,
                                    website: website.isEmpty ? null : website,
                                    logoUrl: logoUrl.isEmpty ? null : logoUrl,
                                  ),
                                ),
                              );
                            },
                            child: tile,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Skills
          if ((jobData['degree_recommendation'] ?? []).isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: kBannerColor,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 7),
                      Text(
                        "Degree Recommendation",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12,),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: degrees.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final degree = degrees[index];
                        final name = (degree['degree'] ?? '').toString();
                        final logoUrl = (degree['logo_url'] ?? '').toString();

                        return Container(
                          width: 180,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: kBackgroundLight,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  logoUrl.isNotEmpty ? logoUrl : 'about:blank',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          if ((jobData['skills_needed'] ?? []).isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: kBackgroundLight,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book),
                      SizedBox(width: 7),
                      Text(
                        "Skills Needed",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List<String>.from(jobData['skills_needed']).map(
                    (skills) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(skills),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),

          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kBackgroundLight,
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
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Ask something about this job...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 9,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
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
                            builder: (context) =>
                                MentorScreen(initialMessage: text),
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

          ElevatedButton.icon(
            onPressed: toggleSave,
            icon: Icon(isSaved ? Icons.bookmark_remove : Icons.bookmark_add),
            label: Text(isSaved ? "Unsave Job" : "Save Job"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved ? Colors.red : Colors.blueAccent,
              foregroundColor: kButtonDark,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
