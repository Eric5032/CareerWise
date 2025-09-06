import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Services/learn_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, this.initialTopic});
  final String? initialTopic;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _queryCtrl = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  final LearnService _service = LearnService();

  bool _loading = false;
  String? _error;
  String _summary = '';
  List<LearnArticle> _articles = [];

  @override
  void initState() {
    super.initState();
    final topic = (widget.initialTopic?.trim().isNotEmpty ?? false)
        ? widget.initialTopic!.trim()
        : 'software engineer job market';
    _queryCtrl.text = topic;
    _fetch(topic);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  Future<void> _fetch(String topic) async {
    setState(() {
      _loading = true;
      _error = null;
      _summary = '';
      _articles = [];
    });

    try {
      final res = await _service.getArticlesForTopic(topic);
      setState(() {
        _summary = res.summary;
        _articles = res.articles;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _fetch(_queryCtrl.text.trim()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Topic bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _queryCtrl,
                    focusNode: _queryFocus,
                    leading: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Icon(Icons.search),
                    ),
                    hintText: "Search for a job to learn about",
                    onSubmitted: (v) {
                      final t = v.trim();
                      if (t.isNotEmpty) _fetch(t);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    final t = _queryCtrl.text.trim();
                    if (t.isNotEmpty) _fetch(t);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Go'),
                )
              ],
            ),
          ),


          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetch(_queryCtrl.text.trim()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [

                  Text('Articles', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),

                  if (_articles.isEmpty && !_loading && _error == null)
                    Text(
                      'No articles yet. Try another topic.',
                      style: TextStyle(color: Colors.grey.shade700),
                    )
                  else
                    ..._articles.map((a) => _ArticleCard(article: a, onOpen: () => _openUrl(a.url))),

                  if (_loading) Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onOpen});

  final LearnArticle article;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall?.color;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                article.title.isEmpty ? 'Untitled' : article.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),

              // Source + recency
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(article.source, style: TextStyle(color: small, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                    if (article.recency.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('• ${article.recency}', style: TextStyle(color: small, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Summary
              if (article.summary.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(article.summary, style: const TextStyle(fontSize: 14)),
                ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
