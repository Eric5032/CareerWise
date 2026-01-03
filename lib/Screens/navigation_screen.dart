import 'package:career_guidance/Screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../Screens/ai_index_screen.dart';
import '../Screens/learn_screen.dart';
import '../Screens/mentor_screen.dart';
import '../Screens/saved_jobs_list_screen.dart';
import "../Screens/profile_screen.dart";
import '../Screens/soft_skills_screen.dart';
import '../Theme/theme.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    AIIndexScreen(),
    MentorScreen(),
    LearnScreen(initialTopic: 'General Job Market'),
    SavedJobsScreen(),
    SoftSkillsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mentor'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: kSurfaceLight,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade400,
        onTap: _onItemTapped,
      ),
    );
  }
}