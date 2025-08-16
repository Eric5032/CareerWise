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

  /// Tracks which section titles are collapsed/disabled.
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

  Widget buildSection(String title, Map<String, String> jobs, BuildContext context) {
    final entries = jobs.entries
        .where((e) => e.key.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    // If search filters everything out, hide the whole section.
    if (entries.isEmpty) return const SizedBox.shrink();

    final collapsed = _isSectionCollapsed(title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with toggle button
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
          const SizedBox(height: 12),

          // Content (hidden when collapsed)
          if (!collapsed)
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final jobTitle = entries[index].key;
                  final imageUrl = entries[index].value;

                  return JobsTemplate(
                    imageUrl: imageUrl,
                    jobTitle: jobTitle,
                    onTap: () => _openJobResult(context, jobTitle),
                  );
                },
              ),
            ),
        ],
      ),
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2F2F2),
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
                  buildSection("STEM", tempJobs["STEM"] ?? {}, context),
                  buildSection("Healthcare", tempJobs["Healthcare"] ?? {}, context),
                  buildSection("Transportation", tempJobs["Transportation"] ?? {}, context),
                  buildSection("Education", tempJobs["Education"] ?? {}, context),
                  buildSection("Arts & Design", tempJobs["Arts & Design"] ?? {}, context),
                  buildSection("Finance & Business", tempJobs["Finance & Business"] ?? {}, context),
                  buildSection("Trades & Construction", tempJobs["Trades & Construction"] ?? {}, context),
                  buildSection("Law & Government", tempJobs["Law & Government"] ?? {}, context),
                  buildSection("Hospitality", tempJobs["Hospitality"] ?? {}, context),
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
  final String imageUrl;
  final String jobTitle;
  final VoidCallback onTap;

  const JobsTemplate({
    required this.imageUrl,
    required this.jobTitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Center(
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
          ],
        ),
      ),
    );
  }
}
