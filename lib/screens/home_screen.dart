import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'lessons_screen.dart';
import 'videos_screen.dart';
import 'quiz_screen.dart';
import 'dashboard_screen.dart';
import 'calculator_screen.dart';
import 'exercises_screen.dart';
import 'glossary_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final SharedPreferences prefs;
  const HomeScreen({super.key, required this.isDark, required this.onToggleTheme, required this.prefs});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeTab(prefs: widget.prefs, onNavigate: _navigate),
      LessonsScreen(prefs: widget.prefs),
      VideosScreen(prefs: widget.prefs),
      QuizScreen(prefs: widget.prefs),
      DashboardScreen(prefs: widget.prefs),
    ];
  }

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسبة المالية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.onToggleTheme,
            tooltip: 'تغيير المظهر',
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GlossaryScreen())),
            tooltip: 'المصطلحات',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigate,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'الدروس'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_rounded), label: 'فيديوهات'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: 'اختبار'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'تقدمي'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final SharedPreferences prefs;
  final Function(int) onNavigate;
  const _HomeTab({required this.prefs, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readCount = (prefs.getStringList('readLessons') ?? []).length;
    final watchedCount = (prefs.getStringList('watchedVids') ?? []).length;
    final solvedCount = (prefs.getStringList('solvedEx') ?? []).length;
    final quizScore = prefs.getInt('quizBestScore') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مرحباً بك 👋', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('تعلم المحاسبة المالية', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('${readCount} فصلاً مقروءاً من 10', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: readCount / 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 20),

          // Stats
          Row(children: [
            _StatCard('الفصول', '$readCount/10', Icons.menu_book, const Color(0xFF1A73E8)),
            const SizedBox(width: 10),
            _StatCard('فيديوهات', '$watchedCount/17', Icons.play_circle, Colors.red),
            const SizedBox(width: 10),
            _StatCard('تمارين', '$solvedCount/6', Icons.edit_note, Colors.green),
            const SizedBox(width: 10),
            _StatCard('اختبار', '$quizScore%', Icons.star, Colors.orange),
          ]).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          Text('الأقسام', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _QuickCard('الدروس', '10 فصول', Icons.menu_book_rounded, const Color(0xFF1A73E8), () => onNavigate(1)),
              _QuickCard('فيديوهات', '17 فيديو', Icons.play_circle_rounded, Colors.red, () => onNavigate(2)),
              _QuickCard('الاختبار', '15 سؤال', Icons.quiz_rounded, Colors.orange, () => onNavigate(3)),
              _QuickCard('تقدمي', '8 إنجازات', Icons.insights_rounded, Colors.purple, () => onNavigate(4)),
              _QuickCard('الحاسبة', '5 أدوات', Icons.calculate_rounded, Colors.teal, () => Navigator.push(_, MaterialPageRoute(builder: (_) => CalculatorScreen()))),
              _QuickCard('تمارين', '6 تمارين', Icons.edit_note_rounded, Colors.green, () => Navigator.push(_, MaterialPageRoute(builder: (_) => ExercisesScreen(prefs: prefs)))),
            ].asMap().entries.map((e) => e.value.animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
      ]),
    ),
  );
}

class _QuickCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard(this.title, this.subtitle, this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    ),
  );
}
