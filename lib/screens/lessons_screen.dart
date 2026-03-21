import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_data.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const LessonsScreen({super.key, required this.prefs});
  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<String> _readLessons = [];

  @override
  void initState() {
    super.initState();
    _readLessons = widget.prefs.getStringList('readLessons') ?? [];
  }

  void _markRead(int id) {
    final key = id.toString();
    if (!_readLessons.contains(key)) {
      setState(() { _readLessons.add(key); });
      widget.prefs.setStringList('readLessons', _readLessons);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _readLessons.length / AppData.lessons.length;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('تقدمك في الدروس', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text('\${_readLessons.length}/\${AppData.lessons.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8, borderRadius: BorderRadius.circular(4)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppData.lessons.length,
            itemBuilder: (ctx, i) {
              final lesson = AppData.lessons[i];
              final isRead = _readLessons.contains(lesson['id'].toString());
              final color = Color(lesson['color'] as int);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(lesson['icon'], style: const TextStyle(fontSize: 22))),
                  ),
                  title: Text(lesson['title'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text('\${(lesson['sections'] as List).length} أقسام', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isRead) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_back_ios, size: 14, color: color),
                  ]),
                  onTap: () async {
                    _markRead(lesson['id'] as int);
                    await Navigator.push(ctx, MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)));
                  },
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}
