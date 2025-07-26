import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/jobs.dart';
import '../OpenAI/job_page.dart';
import '../Services/risk_factor_service.dart';


class AIIndexScreen extends StatelessWidget {
  const AIIndexScreen({super.key});

  Widget buildSection(String title, Map<String, Map<String, dynamic>> jobs) {
    final entries = jobs.entries.toList(); // Convert map to list

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final categoryTitle = entry.key;
                final jobData = entry.value;

                return JobsTemplate(
                  imageUrl: jobData['image']!,
                  JobTitle: categoryTitle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Sectors'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSection("STEM", jobSectors["STEM"] ?? {}),
              buildSection("Healthcare & Medical", jobSectors["Healthcare & Medical"] ?? {}),
              buildSection("Transportation & Logistics", jobSectors["Transportation & Logistics"] ?? {}),
            ],
          ),
        ),
      ),
    );
  }
}


class JobsTemplate extends StatelessWidget {
  final String imageUrl;
  final String JobTitle;

  const JobsTemplate({
    required this.imageUrl,
    this.JobTitle = "Title",
    super.key,
  });
  void _openJobs(BuildContext context, String area){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => )
    )
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final result = await CareerAIService().getAutomationRisk(jobTitle);
      }
      child: Container(
        width: 320,
        height: 160,
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
            // Bottom image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
      
            // Semi-transparent overlay (optional, helps make text readable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
      
            // Centered text
            Center(
              child: Text(
                JobTitle,
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
