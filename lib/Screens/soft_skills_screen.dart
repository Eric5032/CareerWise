import 'package:flutter/material.dart';
import '../data/soft_skills.dart';
class SoftSkillsScreen extends StatefulWidget {
  const SoftSkillsScreen({super.key});

  @override
  State<SoftSkillsScreen> createState() => _SoftSkillsScreenState();
}

class _SoftSkillsScreenState extends State<SoftSkillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  final Set<String> _collapsedCategories = <String>{};
  final Map<String, Set<String>> _collapsedSkills = {};

  // Category icons mapping
  final Map<String, IconData> _categoryIcons = {
    "Communication Skills": Icons.chat_bubble_outline,
    "Leadership & Interpersonal Skills": Icons.groups,
    "Problem-Solving & Critical Thinking": Icons.lightbulb_outline,
    "Emotional Intelligence & Self-Management": Icons.psychology,
    "Adaptability & Resilience": Icons.trending_up,
  };

  // Category colors mapping
  final Map<String, Color> _categoryColors = {
    "Communication Skills": Colors.blue.shade700,
    "Leadership & Interpersonal Skills": Colors.purple.shade600,
    "Problem-Solving & Critical Thinking": Colors.orange.shade700,
    "Emotional Intelligence & Self-Management": Colors.teal.shade700,
    "Adaptability & Resilience": Colors.green.shade700,
  };

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _query = '';
      _searchController.clear();
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_collapsedCategories.contains(category)) {
        _collapsedCategories.remove(category);
      } else {
        _collapsedCategories.add(category);
      }
    });
  }

  void _toggleSkill(String category, String skill) {
    setState(() {
      if (!_collapsedSkills.containsKey(category)) {
        _collapsedSkills[category] = <String>{};
      }
      if (_collapsedSkills[category]!.contains(skill)) {
        _collapsedSkills[category]!.remove(skill);
      } else {
        _collapsedSkills[category]!.add(skill);
      }
    });
  }

  bool _isCategoryCollapsed(String category) => _collapsedCategories.contains(category);

  bool _isSkillCollapsed(String category, String skill) {
    return _collapsedSkills[category]?.contains(skill) ?? true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildCategorySection(String category, Map<String, String> skills, BuildContext context) {
    final filteredSkills = <String, String>{};

    skills.forEach((skill, description) {
      if (_query.isEmpty ||
          skill.toLowerCase().contains(_query.toLowerCase()) ||
          description.toLowerCase().contains(_query.toLowerCase())) {
        filteredSkills[skill] = description;
      }
    });

    if (filteredSkills.isEmpty) return const SizedBox.shrink();

    final collapsed = _isCategoryCollapsed(category);
    final categoryColor = _categoryColors[category] ?? Colors.blue.shade700;
    final categoryIcon = _categoryIcons[category] ?? Icons.star;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              categoryColor.withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Category Header
            InkWell(
              onTap: () => _toggleCategory(category),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: collapsed ? Colors.transparent : categoryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon with colored background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and skill count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredSkills.length} ${filteredSkills.length == 1 ? 'skill' : 'skills'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        collapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Skills List
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSkills.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skill = filteredSkills.keys.elementAt(index);
                    final description = filteredSkills[skill]!;
                    return SkillTemplate(
                      skillName: skill,
                      skillDescription: description,
                      categoryColor: categoryColor,
                      isCollapsed: _isSkillCollapsed(category, skill),
                      onTap: () => _toggleSkill(category, skill),
                    );
                  },
                ),
              ),
              crossFadeState: collapsed
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Soft Skills Development',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search skills',
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Search Bar with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearching ? 80 : 0,
            child: _isSearching
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
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
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: "Search for skills...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
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
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with description
                  if (_query.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Master essential skills for personal and professional growth',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Skill Categories - Replace with your actual map variable
                  // buildCategorySection("Communication Skills", tempJobs["Communication Skills"] ?? {}, context),
                  // buildCategorySection("Leadership & Interpersonal Skills", tempJobs["Leadership & Interpersonal Skills"] ?? {}, context),
                  // buildCategorySection("Problem-Solving & Critical Thinking", tempJobs["Problem-Solving & Critical Thinking"] ?? {}, context),
                  // buildCategorySection("Emotional Intelligence & Self-Management", tempJobs["Emotional Intelligence & Self-Management"] ?? {}, context),
                  // buildCategorySection("Adaptability & Resilience", tempJobs["Adaptability & Resilience"] ?? {}, context),

                  // Example usage - replace tempJobs with your actual map name
                  ...tempJobs.entries.map((entry) {
                    return buildCategorySection(entry.key, entry.value, context);
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillTemplate extends StatelessWidget {
  final String skillName;
  final String skillDescription;
  final Color categoryColor;
  final bool isCollapsed;
  final VoidCallback onTap;

  const SkillTemplate({
    required this.skillName,
    required this.skillDescription,
    required this.categoryColor,
    required this.isCollapsed,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withOpacity(0.1),
                categoryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: categoryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Skill Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        skillName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCollapsed ? Icons.add : Icons.remove,
                        color: categoryColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Skill Description
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      skillDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                crossFadeState: isCollapsed
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}