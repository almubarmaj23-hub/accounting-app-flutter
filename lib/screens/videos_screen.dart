import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_data.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});
  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  List<String> _watched = [];
  String _filter = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _watched = p.getStringList('watchedVids') ?? []);
  }

  Future<void> _markWatched(String id) async {
    if (_watched.contains(id)) return;
    final p = await SharedPreferences.getInstance();
    final u = [..._watched, id];
    await p.setStringList('watchedVids', u);
    if (mounted) setState(() => _watched = u);
  }

  Future<void> _openVideo(String ytId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$ytId');
    if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final videos = AppData.videos.where((v) {
      if (_filter.isEmpty) return true;
      return (v['title'] as String).contains(_filter) || (v['category'] as String).contains(_filter);
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث في الفيديوهات...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true, fillColor: theme.colorScheme.surfaceVariant,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _filter = v),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Icon(Icons.play_circle, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 6),
          Text('${_watched.length}/${AppData.videos.length} مشاهَد',
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: videos.length,
        itemBuilder: (ctx, i) {
          final v = videos[i];
          final vid = v['ytId'] as String;
          final done = _watched.contains(vid);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () { _markWatched(vid); _openVideo(vid); },
              child: Row(children: [
                Stack(children: [
                  Image.network(
                    'https://img.youtube.com/vi/$vid/mqdefault.jpg',
                    width: 120, height: 80, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120, height: 80,
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.play_circle, size: 40, color: theme.colorScheme.primary),
                    ),
                  ),
                  if (done) Positioned(top: 4, right: 4,
                    child: CircleAvatar(radius: 10, backgroundColor: Colors.green,
                      child: const Icon(Icons.check, size: 12, color: Colors.white))),
                ]),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(v['category'] as String,
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
                    ),
                  ]),
                )),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}
