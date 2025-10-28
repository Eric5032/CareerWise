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

    final collapsed = !_isSectionCollapsed(title);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0,3),
                  blurRadius:0.5,
                  spreadRadius: 0),
            ],
            color: kBackgroundLight,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: collapsed ? 'Expand section' : 'Collapse section',
                      onPressed: () => _toggleSection(title),
                      icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: filteredJobs.length*77,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: filteredJobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8,),
                itemBuilder: (context, index) {
                  final jobTitle = filteredJobs[index];

                  return JobsTemplate(
                    jobTitle: jobTitle,
                    onTap: () => _openJobResult(context, jobTitle),
                  );
                },
              ),
            ),
          ),
        SizedBox(height: 8,),
      ],
    );


  }

  Future<void> _openJobResult(BuildContext context, String jobTitle) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
          const SnackBar(content: Text('Failed to get job data.')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Sectors'),
        backgroundColor: kBannerColor,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      backgroundColor: kSurfaceLight,
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: "Search jobs...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection("Information Technology", tempJobs["Information Technology"] ?? [], context),
                  buildSection("Healthcare & Medicine", tempJobs["Healthcare & Medicine"] ?? [], context),
                  buildSection("Transportation & Logistics", tempJobs["Transportation & Logistics"] ?? [], context),
                  buildSection("Education", tempJobs["Education"] ?? [], context),
                  buildSection("Arts, Media & Design", tempJobs["Arts, Media & Design"] ?? [], context),
                  buildSection("Finance & Business", tempJobs["Finance & Business"] ?? [], context),
                  buildSection("Skilled Trades & Construction", tempJobs["Skilled Trades & Construction"] ?? [], context),
                  buildSection("Law, Public Safety & Government", tempJobs["Law, Public Safety & Government"] ?? [], context),
                  buildSection("Hospitality & Tourism", tempJobs["Hospitality & Tourism"] ?? [], context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JobsTemplate extends StatelessWidget {
  final String jobTitle;
  final VoidCallback onTap;

  const JobsTemplate({
    required this.jobTitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 70,
        decoration: BoxDecoration(
          color: kPrimaryColor, // the main color
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            jobTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
