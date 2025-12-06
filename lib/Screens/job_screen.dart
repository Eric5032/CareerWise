import 'dart:convert';
import 'package:career_guidance/Theme/theme.dart';
import 'package:career_guidance/Screens/mentor_screen.dart';
import 'package:flutter/material.dart';
import '../data/saved_jobs.dart';
import 'company_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class JobPage extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobPage({super.key, required this.jobData});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late bool isSaved;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isSaved = savedJobs.any(
          (job) => job['job_title'] == widget.jobData['job_title'],
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
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

  void toggleSave() async {
    setState(() {
      if (isSaved) {
        savedJobs.removeWhere(
              (job) => job['job_title'] == widget.jobData['job_title'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bookmark_remove, color: Colors.white),
                SizedBox(width: 12),
                Text("Job removed from saved"),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        savedJobs.add(widget.jobData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.bookmark_added, color: Colors.white),
                SizedBox(width: 12),
                Text("Job saved successfully"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      isSaved = !isSaved;
    });
    await _persistSavedJobs();
  }

  Color getBadgeColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'high':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobData = widget.jobData;
    final title = jobData['job_title'] ?? 'Unknown Job';
    final description = jobData['job_description'] ?? 'No description available.';
    final riskLevel = jobData['risk_level'] ?? 'Unknown';
    final riskPercent = jobData['automation_risk_percent'] ?? 0;
    final explanation = jobData['explanation'] ?? '';
    final averageSalary = jobData['average_salary'] ?? 0;
    final jobOutlook = jobData['job_outlook'] ?? '';
    final String jobOutlookPercentage = jobData['job_outlook_percentage'] ?? '';
    final String entryLevelEducation = jobData['entry_level_education'] ?? '';

    final List<Map<String, dynamic>> companies =
    List<Map<String, dynamic>>.from((jobData['notable_companies'] ?? const []));
    final List<Map<String, dynamic>> degrees =
    List<Map<String, dynamic>>.from((jobData['degree_recommendation'] ?? const []));
    final List<String> skills = List<String>.from(jobData['skills_needed'] ?? []);

    final riskColor = getBadgeColor(riskLevel);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: kSurfaceLight,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: kSurfaceLight,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.lightBlue.shade700 : Colors.black,
              ),
              onPressed: toggleSave,
              tooltip: isSaved ? 'Unsave job' : 'Save job',
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Risk Badge Card
                Card(
                  elevation: 4,
                  shadowColor: riskColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          riskColor.withOpacity(0.1),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getRiskIcon(riskLevel),
                            color: riskColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: riskColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  riskLevel.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$riskPercent% Automation Risk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Job Description
                _buildInfoCard(
                  icon: Icons.description,
                  iconColor: Colors.lightBlue.shade600,
                  title: "Job Description",
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Risk Explanation
                _buildInfoCard(
                  icon: Icons.lightbulb,
                  iconColor: Colors.lightBlue.shade700,
                  title: "Why This Risk Level?",
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Stats
                _buildStatsRow(
                  context,
                  averageSalary,
                  jobOutlook,
                  jobOutlookPercentage,
                  entryLevelEducation,
                ),

                const SizedBox(height: 20),

                // Notable Companies
                if (companies.isNotEmpty) ...[
                  _buildCompaniesSection(companies),
                  const SizedBox(height: 20),
                ],

                // Degree Recommendations
                if (degrees.isNotEmpty) ...[
                  _buildDegreeSection(degrees),
                  const SizedBox(height: 20),
                ],

                // Skills Needed
                if (skills.isNotEmpty) ...[
                  _buildSkillsSection(skills),
                  const SizedBox(height: 20),
                ],

                // Ask Question Box
                _buildAskQuestionBox(title),

                const SizedBox(height: 20),

                // Save/Unsave Button
                _buildActionButton(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context,
      dynamic averageSalary,
      String jobOutlook,
      String jobOutlookPercentage,
      String entryLevelEducation,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.attach_money,
            iconColor: Colors.lightBlue.shade600,
            title: "Annual Pay",
            value: "\$$averageSalary",
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.trending_up,
            iconColor: Colors.lightBlue.shade700,
            title: "Job Outlook",
            value: jobOutlookPercentage,
            hasIcon: true,
            trendIcon: jobOutlook == "increasing"
                ? 'assets/icons/increase.png'
                : 'assets/icons/decrease.png',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.school,
            iconColor: Colors.lightBlue.shade800,
            title: "Entry Education",
            value: entryLevelEducation,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool hasIcon = false,
    String? trendIcon,
    bool isMultiline = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: isMultiline ? 180 : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.1),
              Colors.white.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasIcon && trendIcon != null)
              Row(
                children: [
                  Image.asset(
                    trendIcon,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                maxLines: isMultiline ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesSection(List<Map<String, dynamic>> companies) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.business, color: Colors.lightBlue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Notable Companies",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: companies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final company = companies[index];
                  final name = (company['name'] ?? '').toString();
                  final logoUrl = (company['logo_url'] ?? '').toString();
                  final website = (company['website'] ?? '').toString();

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
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
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              logoUrl.isNotEmpty ? logoUrl : 'about:blank',
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) {
                                return Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDegreeSection(List<Map<String, dynamic>> degrees) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school, color: Colors.lightBlue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Degree Recommendations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: degrees.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final degree = degrees[index];
                  final name = (degree['degree'] ?? '').toString();
                  final logoUrl = (degree['logo_url'] ?? '').toString();

                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            logoUrl.isNotEmpty ? logoUrl : 'about:blank',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) {
                              return Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey.shade800,
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
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified, color: Colors.lightBlue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Skills Needed",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...skills.map((skill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.lightBlue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionBox(String? title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                ),
                decoration: InputDecoration(
                  hintText: "Ask something about this job...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue.shade600,
                    Colors.lightBlue.shade700,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                iconSize: 20,
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MentorScreen(jobName: title, initialMessage: text),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: toggleSave,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSaved
                  ? [Colors.red.shade500, Colors.red.shade600]
                  : [Colors.blue.shade600, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isSaved ? Colors.red : Colors.blue).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isSaved ? "Remove from Saved" : "Save This Job",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}