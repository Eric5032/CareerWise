import 'package:flutter/material.dart';
import 'package:career_guidance/Screens/ai_index_screen.dart';
import 'package:career_guidance/Screens/saved_jobs_list_screen.dart';
import 'package:career_guidance/Screens/mentor_screen.dart';
import 'package:career_guidance/Theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome to CG_App!",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              shrinkWrap: true,
              children: [
                _buildModuleCard(
                  context,
                  title: "AI Index",
                  icon: Icons.analytics,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AIIndexScreen()),
                    );
                  },
                ),
                _buildModuleCard(
                  context,
                  title: "Mentor",
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MentorScreen()),
                    );
                  },
                ),
                _buildModuleCard(
                  context,
                  title: "Learn",
                  icon: Icons.school,
                  onTap: () {
                    // TODO: Add navigation to Learn screen
                  },
                ),
                _buildModuleCard(
                  context,
                  title: "Saved Jobs",
                  icon: Icons.work,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedJobsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildModuleCard(
    BuildContext context, {
      required String title,
      required IconData icon,
      required VoidCallback onTap,
    }) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      color: kPrimaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}
