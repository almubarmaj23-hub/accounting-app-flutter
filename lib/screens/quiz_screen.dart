import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  SharedPreferences? _prefs;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() {});
  }
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  final _questions = AppData.quizQuestions;

  void _answer(int idx) {
    if (_answered) return;
    final correct = _questions[_current]['ans'] as int;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == correct) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() { _current++; _selected = null; _answered = false; });
    } else {
      setState(() => _finished = true);
      final pct = (_score / _questions.length * 100).round();
      final prev = _prefs?.getInt('quizBestScore') ?? 0;
      if (pct > prev) _prefs?.setInt('quizBestScore', pct);
    }
  }

  void _restart() => setState(() { _current = 0; _score = 0; _selected = null; _answered = false; _finished = false; });

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult(context);
    final q = _questions[_current];
    final opts = q['opts'] as List;
    final correct = q['ans'] as int;
    final progress = (_current + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('سؤال ${_current + 1}/${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('$_score صحيح', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)), minHeight: 8, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('السؤال', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Text(q['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, height: 1.5)),
            ]),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: opts.length,
              itemBuilder: (_, i) {
                Color? bgColor;
                Color borderColor = Colors.grey[300]!;
                if (_answered) {
                  if (i == correct) { bgColor = Colors.green[50]; borderColor = Colors.green; }
                  else if (i == _selected) { bgColor = Colors.red[50]; borderColor = Colors.red; }
                }
                return GestureDetector(
                  onTap: () => _answer(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor ?? Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(color: borderColor.withOpacity(0.15), shape: BoxShape.circle),
                        child: Center(child: Text(['أ','ب','ج','د'][i], style: TextStyle(fontWeight: FontWeight.w800, color: borderColor))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(opts[i] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      if (_answered && i == correct) const Icon(Icons.check_circle, color: Colors.green),
                      if (_answered && i == _selected && i != correct) const Icon(Icons.cancel, color: Colors.red),
                    ]),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
              },
            ),
          ),
          if (_answered) ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(_current < _questions.length - 1 ? 'السؤال التالي ←' : 'عرض النتيجة', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final pct = (_score / _questions.length * 100).round();
    final isPass = pct >= 60;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isPass ? '🎉' : '😔', style: const TextStyle(fontSize: 60)).animate().scale(),
            const SizedBox(height: 16),
            Text(isPass ? 'أحسنت!' : 'حاول مجدداً', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('نتيجتك: $_score من ${_questions.length}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [isPass ? Colors.green : Colors.orange, isPass ? Colors.teal : Colors.red]),
              ),
              child: Center(child: Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800))),
            ).animate().scale(delay: 300.ms),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh),
              label: const Text('أعد الاختبار'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48), backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
