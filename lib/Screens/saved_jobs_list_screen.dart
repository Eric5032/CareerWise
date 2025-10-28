import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_screen.dart';
import '../data/saved_jobs.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _jobKey = 'saved_jobs_list';
  List<Map<String, dynamic>> _filteredJobs = [];
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _initializeJobs();
    _searchController.addListener(_filterJobs);
  }

  Future<void> _initializeJobs() async {
    await _loadSavedJobs();
    setState(() {
      _filteredJobs = List.from(savedJobs);
    });
  }

  Future<void> _loadSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_jobKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decoded = jsonDecode(jsonString);
        savedJobs = decoded.cast<Map<String, dynamic>>();
        _filteredJobs = savedJobs;
      } else {
        savedJobs = [];
      }
    } catch (e) {
      debugPrint('Failed to load saved jobs: $e');
      savedJobs = [];
    }
  }

  Future<void> _saveJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jobKey, jsonEncode(savedJobs));
      debugPrint('${savedJobs.length} jobs to SharedPreferences.');
    } catch (e) {
      debugPrint('Failed to save jobs: $e');
    }
  }

  Future<void> _removeJob(Map<String, dynamic> job) async {
    setState(() {
      savedJobs.removeWhere((j) => j['job_title'] == job['job_title']);
      _filteredJobs = List.from(savedJobs);
    });
    await _saveJobs();
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = savedJobs.where((job) {
        final title = (job['job_title'] ?? '').toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _filteredJobs = List.from(savedJobs);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _filteredJobs.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Jobs"),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search saved jobs...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          Expanded(
            child: isEmpty
                ? const Center(child: Text("No saved jobs found."))
                : ListView.builder(
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return ListTile(
                  title: Text(job['job_title'] ?? 'Untitled'),
                  subtitle: Text(
                      "${job['automation_risk_percent'] ?? '?'}% risk"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeJob(job),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobPage(jobData: job),
                      ),
                    ).then((_) => _initializeJobs()); // refresh on return
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
