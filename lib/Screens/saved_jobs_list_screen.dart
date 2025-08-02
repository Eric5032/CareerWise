import 'package:flutter/material.dart';
import '../data/saved_jobs.dart';
import 'job_screen.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Jobs")),
      body: savedJobs.isEmpty
          ? const Center(child: Text("No saved jobs yet."))
          : ListView.builder(
        itemCount: savedJobs.length,
        itemBuilder: (context, index) {
          final job = savedJobs[index];
          return ListTile(
            title: Text(job['job_title'] ?? 'Untitled'),
            subtitle: Text("${job['automation_risk_percent']}% risk"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobPage(jobData: job),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
