// lib/Screens/company_page.dart
import 'package:flutter/material.dart';
import '../Services/mentor_service.dart';
// Optional: if you want "Open Website" button to launch URLs, add url_launcher to pubspec.yaml
// dependencies:
//   url_launcher: ^6.3.0
import 'package:url_launcher/url_launcher.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDescription();
  }

  Future<void> _fetchDescription() async {
    // You can tweak the prompt to fit your tone/style.
    final prompt = """
Write exactly two concise paragraphs about "${widget.name}".
Paragraph 1: What the company does, key products/services, and customer segments.
Paragraph 2: Market position, scale or traction (if widely known), and recent strategic focus areas.
No headings, no bullet points, neutral tone.
""".trim();

    try {
      final reply = await MentorService().getMentorReply(prompt);
      setState(() {
        _description = (reply == null || reply.trim().isEmpty)
            ? " ${widget.name} is a company operating in its sector, offering products and services to its target customers. It focuses on solving practical problems and delivering value through technology, operations, and partnerships.\n\nIn recent years, the company has focused on refining its core offerings, improving user experience, and pursuing sustainable growth opportunities. It continues to iterate on its roadmap and adapt to changing market conditions."
            : reply.trim();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _description =
        "${widget.name} is a company offering products and services for its customers.\n\nIt continues to build on its position with a focus on product improvement and responsible growth.";
        _loading = false;
      });
    }
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    (widget.logoUrl ?? '').isNotEmpty ? widget.logoUrl! : 'about:blank',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
            Text(
              _description ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
