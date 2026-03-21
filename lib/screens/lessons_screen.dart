import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_data.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});
  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<String> _readLessons = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _readLessons = prefs.getStringList('readLessons') ?? [];
    });
  }

  Future<void> _markRead(int id) async {
    final key = id.toString();
    if (_readLessons.contains(key)) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [..._readLessons, key];
    await prefs.setStringList('readLessons', updated);
    if (!mounted) return;
    setState(() => _readLessons = updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessons = AppData.lessons;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (ctx, i) {
        final lesson = lessons[i];
        final isRead = _readLessons.contains(lesson['id'].toString());
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isRead
                  ? Colors.green.withOpacity(.15)
                  : theme.colorScheme.primaryContainer,
              child: Icon(
                isRead ? Icons.check_circle : Icons.book_outlined,
                color: isRead ? Colors.green : theme.colorScheme.primary,
              ),
            ),
            title: Text(lesson['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            subtitle: Text('${(lesson['sections'] as List).length} أقسام',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _markRead(lesson['id'] as int);
              Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)));
            },
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
      },
    );
  }
}
