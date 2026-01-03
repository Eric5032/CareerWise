import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_screen.dart';
import 'package:career_guidance/Theme/theme.dart';
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
  bool _isMultiSelectMode = false;
  Set<String> _selectedJobTitles = {};

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

  Future<void> _removeSelectedJobs() async {
    setState(() {
      savedJobs.removeWhere((j) => _selectedJobTitles.contains(j['job_title']));
      _filteredJobs = List.from(savedJobs);
      _selectedJobTitles.clear();
      _isMultiSelectMode = false;
    });
    await _saveJobs();
  }

  void _toggleJobSelection(String jobTitle) {
    setState(() {
      if (_selectedJobTitles.contains(jobTitle)) {
        _selectedJobTitles.remove(jobTitle);
      } else {
        _selectedJobTitles.add(jobTitle);
      }
    });
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedJobTitles.clear();
      }
    });
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
      backgroundColor: kSurfaceLight,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? "${_selectedJobTitles.length} selected"
              : "Saved Jobs",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: kSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: _isMultiSelectMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleMultiSelectMode,
        )
            : null,
        actions: [
          if (!_isMultiSelectMode && !isEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleMultiSelectMode,
              tooltip: 'Select multiple',
            ),
          if (!_isMultiSelectMode)
            IconButton(
              icon: Icon(_showSearchBar ? Icons.close : Icons.search),
              onPressed: _toggleSearchBar,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showSearchBar ? 80 : 0,
                child: _showSearchBar
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kSurfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search for jobs...",
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.lightBlue.shade50,
                              Colors.lightBlue.shade100
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.lightBlue.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _searchController.text.isNotEmpty
                            ? "No jobs found"
                            : "No saved jobs yet",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? "Try searching for something else"
                              : "Start saving jobs to see them here!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: _selectedJobTitles.length >= 3 ? 100 : 16,
                  ),
                  itemCount: _filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = _filteredJobs[index];
                    final riskPercent =
                        job['automation_risk_percent'] ?? 0;
                    final riskLevel = job['risk_level'] ?? 'Unknown';
                    final jobTitle = job['job_title'] ?? 'Untitled';
                    final isSelected =
                    _selectedJobTitles.contains(jobTitle);

                    Color getRiskColor() {
                      switch (riskLevel.toLowerCase()) {
                        case 'low':
                          return Colors.green.shade600;
                        case 'medium':
                          return Colors.orange.shade600;
                        case 'high':
                          return Colors.red.shade600;
                        default:
                          return Colors.grey.shade600;
                      }
                    }

                    return Card(
                      elevation: isSelected ? 4 : 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isSelected
                            ? BorderSide(
                            color: Colors.blue.shade700, width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (_isMultiSelectMode) {
                            _toggleJobSelection(jobTitle);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobPage(jobData: job),
                              ),
                            ).then((_) => _initializeJobs());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [
                                Colors.blue.shade100.withAlpha(100),
                                Colors.blue.shade50.withAlpha(50),
                              ]
                                  : [
                                Colors.lightBlue.shade200
                                    .withAlpha(40),
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isMultiSelectMode)
                                Padding(
                                  padding:
                                  const EdgeInsets.only(right: 12),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                        : null,
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      jobTitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getRiskColor(),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            riskLevel.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "$riskPercent% risk",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isMultiSelectMode)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade400,
                                  ),
                                  onPressed: () async {
                                    final confirm =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        title: const Text(
                                          "Remove job?",
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        content: Text(
                                          "Remove \"${job['job_title']}\" from saved jobs?",
                                          style: const TextStyle(
                                              height: 1.5),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, false),
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors
                                                      .grey.shade600),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, true),
                                            child: Text(
                                              "Remove",
                                              style: TextStyle(
                                                color:
                                                Colors.red.shade600,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      _removeJob(job);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Bottom Action Bar
          if (_selectedJobTitles.length >= 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _selectedJobTitles.length >= 3
                    ? Offset.zero
                    : const Offset(0, 1),
                curve: Curves.easeInOut,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Text(
                                      "Remove selected jobs?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      "Remove ${_selectedJobTitles.length} jobs from saved jobs?",
                                      style: const TextStyle(height: 1.5),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          "Remove All",
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _removeSelectedJobs();
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade600,
                                      Colors.red.shade600.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.red.shade600.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Delete ${_selectedJobTitles.length} Jobs",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}