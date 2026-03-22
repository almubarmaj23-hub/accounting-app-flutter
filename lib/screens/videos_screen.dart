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
  String _search = '';
  String _selCat = 'الكل';

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
    final url = Uri.parse('https://www.youtube.com/watch?v=\$ytId');
    if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allVideos = AppData.videos;
    final cats = ['الكل', ...{...allVideos.map((v) => v['cat'] as String)}];

    final filtered = allVideos.where((v) {
      final matchCat = _selCat == 'الكل' || v['cat'] == _selCat;
      final matchSearch = _search.isEmpty || (v['title'] as String).contains(_search);
      return matchCat && matchSearch;
    }).toList();

    final watchedCount = _watched.length;

    return Column(children: [
      // ─── شريط البحث ───
      Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث في الدروس...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _search.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _search = ''))
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(.6),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
      // ─── فلتر التصنيفات ───
      SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: cats.length,
          itemBuilder: (ctx, i) {
            final cat = cats[i];
            final sel = cat == _selCat;
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: () => setState(() => _selCat = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cat,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold,
                      color: sel ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    )),
                ),
              ),
            );
          },
        ),
      ),
      // ─── إحصائية ───
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Row(children: [
          Icon(Icons.play_circle_rounded, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 5),
          Text('\$watchedCount/\${allVideos.length} مشاهَد',
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('\${filtered.length} نتيجة',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
      ),
      // ─── قائمة الفيديوهات ───
      Expanded(
        child: filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('لا توجد نتائج', style: TextStyle(color: Colors.grey[400])),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final v = filtered[i];
                final vid = v['id'] as String;
                final done = _watched.contains(vid);
                final catColor = _catColor(v['cat'] as String, theme);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1.5,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () { _markWatched(vid); _openVideo(vid); },
                    child: Row(children: [
                      // صورة مصغرة
                      Stack(children: [
                        Image.network(
                          'https://img.youtube.com/vi/\$vid/mqdefault.jpg',
                          width: 110, height: 75, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110, height: 75,
                            color: catColor.withOpacity(.15),
                            child: Icon(Icons.play_circle_rounded, size: 36, color: catColor),
                          ),
                        ),
                        Positioned.fill(child: Center(child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ))),
                        if (done) Positioned(top: 4, right: 4,
                          child: CircleAvatar(radius: 9, backgroundColor: Colors.green,
                            child: const Icon(Icons.check, size: 11, color: Colors.white))),
                      ]),
                      // المعلومات
                      Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(v['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Text(v['desc'] as String,
                            style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.3),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(v['cat'] as String,
                                style: TextStyle(fontSize: 9, color: catColor, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.access_time, size: 11, color: Colors.grey[400]),
                            const SizedBox(width: 2),
                            Text(v['dur'] as String,
                              style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                          ]),
                        ]),
                      )),
                    ]),
                  ),
                );
              },
            ),
      ),
    ]);
  }

  Color _catColor(String cat, ThemeData theme) {
    switch (cat) {
      case 'مقدمة': return Colors.blue;
      case 'قيود اليومية': return Colors.green;
      case 'دفتر الأستاذ': return Colors.orange;
      case 'القوائم المالية': return Colors.purple;
      case 'المخزون والأصول': return Colors.teal;
      case 'التكاليف والنسب': return Colors.red;
      case 'كورس كامل': return Colors.indigo;
      default: return theme.colorScheme.primary;
    }
  }
}
