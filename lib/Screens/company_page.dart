// lib/Screens/company_page.dart
import 'package:flutter/material.dart';
import '../Services/mentor_service.dart';
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
    final prompt = """
Write exactly two concise paragraphs about "${widget.name}".
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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              (widget.logoUrl ?? '').isNotEmpty
                                  ? widget.logoUrl!
                                  : 'about:blank',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
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

            // ✅ Horizontal scrolling row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  SectionContainer(
                    title: "Date of Establishment",
                    info: "No notes added yet.",
                  ),
                  SizedBox(width: 15),
                  SectionContainer(
                    title: "Company CEO",
                    info: "No notes added yet.",
                  ),
                  SizedBox(width: 15,),
                  SectionContainer(
                    title: "Company Valuation",
                    info: "No notes added yet.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Full-width description
            SectionContainer(
              title: "Company Description",
              info: _description ?? '',
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
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0 ),
      constraints: const BoxConstraints(minWidth: 150), // ensures readability
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
        mainAxisSize: MainAxisSize.min, // wrap content
        children: [
          // Section Title
          Text(
            title,
            softWrap: true,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),

          // Placeholder / info text
          Text(
            info,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
