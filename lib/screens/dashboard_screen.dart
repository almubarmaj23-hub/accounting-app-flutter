import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int lessonsRead = 0;
  int quizScore = 0;
  bool quizDone = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lessonsRead = prefs.getInt('lessons_read') ?? 0;
      quizScore = prefs.getInt('quiz_score') ?? 0;
      quizDone = prefs.getBool('quiz_done') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalLessons = 10;
    final progress = lessonsRead / totalLessons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تقدمي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة التقدم الكلي
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Icon(Icons.school, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: 10),
                    Text('تقدم الدراسة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ]),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text('$lessonsRead من $totalLessons فصلاً مكتملاً',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // إحصائيات سريعة
            Row(children: [
              Expanded(child: _statCard('الفصول المقروءة', '$lessonsRead', Icons.book, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('نتيجة الاختبار', quizDone ? '$quizScore%' : 'لم يُجرَ', Icons.quiz, Colors.orange)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _statCard('الفيديوهات', '17 متاحة', Icons.play_circle, Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('التمارين', '6 تمارين', Icons.edit, Colors.green)),
            ]),
            const SizedBox(height: 20),

            // روابط سريعة
            Text('روابط سريعة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
            const SizedBox(height: 10),
            _quickLink(context, Icons.book_outlined, 'مكتبة الدروس', Colors.blue, 1),
            _quickLink(context, Icons.quiz_outlined, 'الاختبار التفاعلي', Colors.orange, 3),
            _quickLink(context, Icons.play_circle_outlined, 'دروس الفيديو', Colors.red, 4),
            _quickLink(context, Icons.edit_outlined, 'التمارين التطبيقية', Colors.green, 5),
            _quickLink(context, Icons.calculate_outlined, 'الحاسبة المحاسبية', Colors.purple, 6),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _quickLink(BuildContext context, IconData icon, String label, Color color, int tab) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color.withOpacity(.15), child: Icon(icon, color: color)),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      );
}
