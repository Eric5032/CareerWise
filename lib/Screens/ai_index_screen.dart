import 'dart:ffi';

import 'package:career_guidance/Theme/theme.dart';
import 'package:flutter/material.dart';
import '../data/temp_jobs.dart';
import '../Services/risk_factor_service.dart';
import 'job_screen.dart';

class AIIndexScreen extends StatefulWidget {
  const AIIndexScreen({super.key});

  @override
  State<AIIndexScreen> createState() => _AIIndexScreenState();
}

class _AIIndexScreenState extends State<AIIndexScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  final Set<String> _collapsedSections = <String>{};

  // Category icons mapping
  final Map<String, IconData> _categoryIcons = {
    "Information Technology": Icons.computer,
    "Healthcare & Medicine": Icons.medical_services,
    "Transportation & Logistics": Icons.local_shipping,
    "Education": Icons.school,
    "Arts, Media & Design": Icons.palette,
    "Finance & Business": Icons.business_center,
    "Skilled Trades & Construction": Icons.construction,
    "Law, Public Safety & Government": Icons.gavel,
    "Hospitality & Tourism": Icons.hotel,
  };

  // Category colors mapping
  final Map<String, Color> _categoryColors = {
    "Information Technology": Colors.blue.shade700,
    "Healthcare & Medicine": Colors.red.shade600,
    "Transportation & Logistics": Colors.orange.shade700,
    "Education": Colors.green.shade700,
    "Arts, Media & Design": Colors.purple.shade600,
    "Finance & Business": Colors.teal.shade700,
    "Skilled Trades & Construction": Colors.brown.shade600,
    "Law, Public Safety & Government": Colors.indigo.shade700,
    "Hospitality & Tourism": Colors.pink.shade600,
  };

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _query = '';
      _searchController.clear();
    });
  }

  void _toggleSection(String title) {
    setState(() {
      if (_collapsedSections.contains(title)) {
        _collapsedSections.remove(title);
      } else {
        _collapsedSections.add(title);
      }
    });
  }

  bool _isSectionCollapsed(String title) => _collapsedSections.contains(title);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildSection(String title, List<String> jobs, BuildContext context) {
    final filteredJobs = jobs
        .where((job) => job.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    if (filteredJobs.isEmpty) return const SizedBox.shrink();

    final collapsed = _isSectionCollapsed(title);
    final categoryColor = _categoryColors[title] ?? Colors.blue.shade700;
    final categoryIcon = _categoryIcons[title] ?? Icons.work;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              categoryColor.withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Header Section
            InkWell(
              onTap: () => _toggleSection(title),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: collapsed ? Colors.transparent : categoryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon with colored background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and job count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredJobs.length} ${filteredJobs.length == 1 ? 'job' : 'jobs'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        collapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Jobs List
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredJobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final jobTitle = filteredJobs[index];
                    return JobsTemplate(
                      jobTitle: jobTitle,
                      categoryColor: categoryColor,
                      onTap: () => _openJobResult(context, jobTitle),
                    );
                  },
                ),
              ),
              crossFadeState: collapsed
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openJobResult(BuildContext context, String jobTitle) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading job details...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await CareerAIService().getAutomationRisk(jobTitle);

      if (context.mounted) Navigator.pop(context);

      if (result != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobPage(jobData: result)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Failed to get job data.'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kSurfaceLight,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Column(
            children: [
              Text(
                'Explore Career Paths',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
              tooltip: _isSearching ? 'Close search' : 'Search jobs',
            ),
          ],
        ),
        backgroundColor: kSurfaceLight,
        body: Column(
          children: [
            // Search Bar with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearching ? 80 : 0,
              child: _isSearching
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kBannerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: "Search for jobs...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _searchController.clear();
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with stats
                    if (_query.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Discover AI automation risks across different sectors',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Job Sections
                    buildSection("Information Technology", tempJobs["Information Technology"] ?? [], context),
                    buildSection("Healthcare & Medicine", tempJobs["Healthcare & Medicine"] ?? [], context),
                    buildSection("Transportation & Logistics", tempJobs["Transportation & Logistics"] ?? [], context),
                    buildSection("Education", tempJobs["Education"] ?? [], context),
                    buildSection("Arts, Media & Design", tempJobs["Arts, Media & Design"] ?? [], context),
                    buildSection("Finance & Business", tempJobs["Finance & Business"] ?? [], context),
                    buildSection("Skilled Trades & Construction", tempJobs["Skilled Trades & Construction"] ?? [], context),
                    buildSection("Law, Public Safety & Government", tempJobs["Law, Public Safety & Government"] ?? [], context),
                    buildSection("Hospitality & Tourism", tempJobs["Hospitality & Tourism"] ?? [], context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobsTemplate extends StatelessWidget {
  final String jobTitle;
  final Color categoryColor;
  final VoidCallback onTap;

  const JobsTemplate({
    required this.jobTitle,
    required this.categoryColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor,
                categoryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
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