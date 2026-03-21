import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_data.dart';

class VideosScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const VideosScreen({super.key, required this.prefs});
  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  String _selectedCat = 'الكل';
  List<String> _watched = [];
  String _search = '';

  final List<String> _cats = ['الكل', 'مقدمة', 'قيود', 'دفتر الأستاذ', 'القوائم', 'كورس كامل'];

  @override
  void initState() {
    super.initState();
    _watched = widget.prefs.getStringList('watchedVids') ?? [];
  }

  Future<void> _openVideo(Map video) async {
    final id = video['id'] as String;
    final uri = Uri.parse('https://www.youtube.com/watch?v=$id');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!_watched.contains(id)) {
        setState(() => _watched.add(id));
        widget.prefs.setStringList('watchedVids', _watched);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = AppData.videos.where((v) {
      final matchCat = _selectedCat == 'الكل' || v['cat'] == _selectedCat;
      final matchSearch = _search.isEmpty || (v['title'] as String).contains(_search);
      return matchCat && matchSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث في الفيديوهات...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _cats.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(_cats[i]),
                selected: _selectedCat == _cats[i],
                onSelected: (_) => setState(() => _selectedCat = _cats[i]),
                selectedColor: const Color(0xFF1A73E8).withOpacity(0.2),
                checkmarkColor: const Color(0xFF1A73E8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Text('${filtered.length} فيديو', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Text('• شاهدت ${_watched.length}/17', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final v = filtered[i];
              final isWatched = _watched.contains(v['id']);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openVideo(v),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(children: [
                        CachedNetworkImage(
                          imageUrl: 'https://img.youtube.com/vi/${v['id']}/mqdefault.jpg',
                          height: 100, width: double.infinity, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(height: 100, color: Colors.grey[200], child: const Icon(Icons.play_circle, size: 40, color: Colors.grey)),
                        ),
                        Positioned.fill(child: Container(color: Colors.black26, child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 36)))),
                        if (isWatched) Positioned(top: 6, right: 6, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                          child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 11)),
                        )),
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(v['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(v['cat'] as String, style: const TextStyle(color: Color(0xFF1A73E8), fontSize: 10, fontWeight: FontWeight.w600))),
                            const Spacer(),
                            Text(v['dur'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ]),
                        ]),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
            },
          ),
        ),
      ],
    );
  }
}
