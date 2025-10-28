// import 'package:flutter/material.dart';
// import '../data/temp_jobs.dart';
// import '../Services/risk_factor_service.dart';
// import 'job_screen.dart';
//
// class JobListScreen extends StatelessWidget {
//   const JobListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Job Categories'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: ListView(
//         children: tempJobs.keys.map((category) {
//           return ListTile(
//             title: Text(category),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => SpecificJobsScreen(category: category),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
// class SpecificJobsScreen extends StatelessWidget {
//   final String category;
//
//   const SpecificJobsScreen({super.key, required this.category});
//
//   @override
//   Widget build(BuildContext context) {
//     final jobs = tempJobs[category] ?? {};
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(category),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: ListView(
//         children: jobs.entries.map((entry) {
//           final title = entry.key;
//
//           return ListTile(
//             title: Text(title),
//             onTap: () async {
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => const Center(child: CircularProgressIndicator()),
//               );
//
//               final result = await CareerAIService().getAutomationRisk(title);
//               if (context.mounted) Navigator.pop(context);
//
//               if (result != null && context.mounted) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => JobPage(jobData: result),
//                   ),
//                 );
//               }
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
