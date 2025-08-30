// lib/Screens/company_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/mentor_service.dart';

class CompanyPage extends StatefulWidget {
  final String name;
  final String? website;
  final String? logoUrl;

  const CompanyPage({
    super.key,
    required this.name,
    this.website,
    this.logoUrl,
  });

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  String? _description;
  String? _ceo;
  String? _founded;
  String? _worth;
  String? _worthLabel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
  }

  Future<void> _fetchCompanyInfo() async {
    final prompt = '''
Return ONLY compact JSON. Provide structured info about "${widget.name}".
If unknown, return null for the field.

{
  "description": "Two short paragraphs. Para 1: what the company does, key products/services, main customer segments. Para 2: market position, scale, and recent strategy. Neutral tone.",
  "ceo": "Current CEO if known, else null",
  "founded": "Year or full date if known, else null",
  "worth": "Company valuation or market cap in human-readable form, else null",
  "worth_label": "Market Cap or Valuation depending on the type, else Company Worth"
}
''';

    try {
      final reply = await MentorService().getMentorReply(prompt);

      if (reply != null && reply.trim().isNotEmpty) {
        final data = _tryParseJson(reply.trim());

        setState(() {
          _description = data['description'] ?? "Nothing here yet…";
          _ceo = data['ceo'];
          _founded = data['founded'];
          _worth = data['worth'];
          _worthLabel = data['worth_label'] ?? "Company Worth";
          _loading = false;
        });
      } else {
        setState(() {
          _description = "No information available.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _description = "Failed to load information.";
        _loading = false;
      });
    }
  }

  /// Proper JSON parsing with fallback
  Map<String, dynamic> _tryParseJson(String input) {
    try {
      // Strip Markdown code fences if model wrapped JSON in ```json ... ```
      final cleaned = input
          .replaceAll(RegExp(r'```json', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint("⚠️ JSON parse failed: $e");
    }
    return {};
  }

  Future<void> _openWebsite() async {
    if (widget.website == null || widget.website!.isEmpty) return;
    final uri = Uri.parse(widget.website!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        (widget.logoUrl ?? '').isNotEmpty
                            ? widget.logoUrl!
                            : 'about:blank',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Center(
                            child: Text(
                              widget.name.isNotEmpty
                                  ? widget.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (widget.website != null && widget.website!.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openWebsite,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Website'),
                ),
              ),

            const SizedBox(height: 8),

            // Facts row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SectionContainer(
                    title: "Date of Establishment",
                    info: _founded ?? "No notes added yet.",
                  ),
                  const SizedBox(width: 15),
                  SectionContainer(
                    title: "Company CEO",
                    info: _ceo ?? "No notes added yet.",
                  ),
                  const SizedBox(width: 15),
                  SectionContainer(
                    title: _worthLabel ?? "Company Worth",
                    info: _worth ?? "No notes added yet.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            SectionContainer(
              title: "Company Description",
              info: _description ?? "Nothing here yet…",
              padding: const EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionContainer extends StatelessWidget {
  final String title;
  final String info;
  final EdgeInsetsGeometry padding;

  const SectionContainer({
    super.key,
    required this.title,
    this.info = "Nothing here yet…",
    this.padding = const EdgeInsets.all(13),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(minWidth: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(
          width: 1.5,
          color: theme.colorScheme.outlineVariant.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            info,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
