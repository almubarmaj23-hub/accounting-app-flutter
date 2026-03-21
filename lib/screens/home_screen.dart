import 'package:flutter/material.dart';
import 'lessons_screen.dart';
import 'videos_screen.dart';
import 'quiz_screen.dart';
import 'glossary_screen.dart';
import 'calculator_screen.dart';
import 'exercises_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_rounded, 'الرئيسية'),
    _NavItem(Icons.book_rounded, 'الدروس'),
    _NavItem(Icons.play_circle_rounded, 'فيديوهات'),
    _NavItem(Icons.quiz_rounded, 'الاختبار'),
    _NavItem(Icons.insights_rounded, 'تقدمي'),
  ];

  void _navigate(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screens = [
      _HomeTab(onNavigate: _navigate, isDark: widget.isDark, onToggleTheme: widget.onToggleTheme),
      const LessonsScreen(),
      const VideosScreen(),
      const QuizScreen(),
      const DashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسبة المالية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
            tooltip: 'تبديل الثيم',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigate,
        destinations: _navItems
            .map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ─── الصفحة الرئيسية ───
class _HomeTab extends StatelessWidget {
  final Function(int) onNavigate;
  final bool isDark;
  final VoidCallback onToggleTheme;
  const _HomeTab({required this.onNavigate, required this.isDark, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مرحباً بك 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                const Text(
                  'تعلّم المحاسبة المالية',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'دروس + فيديوهات + اختبارات + حاسبة',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(1),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('ابدأ التعلم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // أقسام سريعة
          Text('الأقسام', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: [
              _SectionCard('الدروس', Icons.book_rounded, Colors.blue, () => onNavigate(1)),
              _SectionCard('فيديوهات', Icons.play_circle_rounded, Colors.red, () => onNavigate(2)),
              _SectionCard('اختبار', Icons.quiz_rounded, Colors.orange, () => onNavigate(3)),
              _SectionCard('تقدمي', Icons.insights_rounded, Colors.purple, () => onNavigate(4)),
              _SectionCard('حاسبة', Icons.calculate_rounded, Colors.teal, () =>
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CalculatorScreen()))),
              _SectionCard('تمارين', Icons.edit_note_rounded, Colors.green, () =>
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ExercisesScreen()))),
            ],
          ),
          const SizedBox(height: 24),

          // إحصائيات الموقع
          Text('محتوى التطبيق', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatChip('10', 'فصول')),
            const SizedBox(width: 8),
            Expanded(child: _StatChip('17', 'فيديو')),
            const SizedBox(width: 8),
            Expanded(child: _StatChip('20+', 'سؤال')),
            const SizedBox(width: 8),
            Expanded(child: _StatChip('6', 'تمارين')),
          ]),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SectionCard(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}
