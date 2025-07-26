import 'package:flutter/material.dart';
import '../OpenAI/job_page.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> savedJobs = [
      // {
      //   'imageUrl': 'https://source.unsplash.com/random/800x600/?tech',
      //   'jobTitle': 'Software Engineer',
      // },
      // {
      //   'imageUrl': 'https://source.unsplash.com/random/800x600/?office',
      //   'jobTitle': 'Product Manager',
      // },
      // {
      //   'imageUrl': 'https://source.unsplash.com/random/800x600/?developer',
      //   'jobTitle': 'Backend Developer',
      // },
      // Add more job entries...
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: savedJobs.isEmpty
            ? const Center(
          child: Text(
            "No saved jobs yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black38, // Faint text
              fontStyle: FontStyle.italic,
            ),
          ),
        )
            : GridView.builder(
          itemCount: savedJobs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final job = savedJobs[index];
            return JobsTemplate(
              imageUrl: job['imageUrl'],
              JobTitle: job['jobTitle'],
            );
          },
        ),
      ),
    );
  }
}

class JobsTemplate extends StatelessWidget {
  final String imageUrl;
  final String JobTitle;

  JobsTemplate(
      {required this.imageUrl, this.JobTitle = "Title"});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Image(
                image: NetworkImage(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
              child: TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobPage(jobTitle: JobTitle,))
                  );
                },
                child: Text(JobTitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
