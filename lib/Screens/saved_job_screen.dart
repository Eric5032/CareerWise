import 'package:flutter/material.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  static final List<Map<String, dynamic>> _savedJobs = [];

  static void addJob(Map<String, dynamic> jobData) {
    // Prevent duplicates by title
    if (_savedJobs.any((job) => job['job_title'] == jobData['job_title'])) return;
    _savedJobs.add(jobData);
  }

  static void removeJob(String title) {
    _savedJobs.removeWhere((job) => job['job_title'] == title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _savedJobs.isEmpty
          ? const Center(child: Text('No saved jobs yet.'))
          : ListView.builder(
        itemCount: _savedJobs.length,
        itemBuilder: (context, index) {
          final job = _savedJobs[index];
          return ListTile(
            title: Text(job['job_title'] ?? ''),
            subtitle: Text('Risk: ${job['automation_risk_percent']}%'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  removeJob(job['job_title']);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
