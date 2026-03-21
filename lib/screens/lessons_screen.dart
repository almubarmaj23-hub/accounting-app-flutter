import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_data.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});
  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}
class _LessonsScreenState extends State<LessonsScreen> {
  List<String> _read = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _read = p.getStringList('readLessons') ?? []);
  }
  Future<void> _mark(int id) async {
    if (_read.contains('$id')) return;
    final p = await SharedPreferences.getInstance();
    final u = [..._read, '$id'];
    await p.setStringList('readLessons', u);
    if (mounted) setState(() => _read = u);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AppData.lessons.length,
      itemBuilder: (ctx, i) {
        final l = AppData.lessons[i];
        final done = _read.contains('${l['id']}');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: done ? Colors.green.withOpacity(.15) : theme.colorScheme.primaryContainer,
              child: Icon(done ? Icons.check_circle : Icons.book_outlined,
                  color: done ? Colors.green : theme.colorScheme.primary),
            ),
            title: Text(l['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${(l['sections'] as List).length} أقسام',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _mark(l['id'] as int);
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: l)));
            },
          ),
        );
      },
    );
  }
}
