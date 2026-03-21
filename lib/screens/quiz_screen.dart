import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends State<QuizScreen> {
  int _idx = 0, _score = 0;
  int? _selected;
  bool _answered = false, _done = false;
  int _best = 0;

  @override void initState() { super.initState(); _loadBest(); }
  Future<void> _loadBest() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _best = p.getInt('quizBestScore') ?? 0);
  }
  Future<void> _saveBest(int s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('quizBestScore', s);
    await p.setBool('quiz_done', true);
  }

  void _answer(int idx) {
    if (_answered) return;
    final q = AppData.quizQuestions[_idx];
    final correct = idx == q['correct'] as int;
    setState(() { _selected = idx; _answered = true; if (correct) _score++; });
  }

  void _next() {
    if (_idx < AppData.quizQuestions.length - 1) {
      setState(() { _idx++; _selected = null; _answered = false; });
    } else {
      final pct = (_score * 100 ~/ AppData.quizQuestions.length);
      _saveBest(pct);
      setState(() => _done = true);
    }
  }

  void _restart() => setState(() { _idx = 0; _score = 0; _selected = null; _answered = false; _done = false; });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_done) {
      final pct = _score * 100 ~/ AppData.quizQuestions.length;
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Icon(pct >= 70 ? Icons.emoji_events : Icons.refresh, size: 80,
              color: pct >= 70 ? Colors.amber : theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('$pct%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
          Text('$_score من ${AppData.quizQuestions.length} إجابة صحيحة'),
          const SizedBox(height: 8),
          Text('أفضل نتيجة: $_best%', style: TextStyle(color: theme.colorScheme.primary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _restart,
              icon: const Icon(Icons.refresh), label: const Text('إعادة الاختبار')),
        ],
      )));
    }
    final q = AppData.quizQuestions[_idx];
    final opts = q['options'] as List;
    return Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LinearProgressIndicator(value: (_idx + 1) / AppData.quizQuestions.length,
            borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 8),
        Text('سؤال ${_idx + 1} / ${AppData.quizQuestions.length}',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(padding: const EdgeInsets.all(20),
                child: Text(q['question'] as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.6)))),
        const SizedBox(height: 16),
        ...List.generate(opts.length, (i) {
          Color? bg;
          if (_answered) {
            if (i == q['correct'] as int) bg = Colors.green.withOpacity(.15);
            else if (i == _selected) bg = Colors.red.withOpacity(.15);
          }
          return Padding(padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(onTap: () => _answer(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg ?? theme.colorScheme.surfaceVariant.withOpacity(.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: bg != null ? bg!.withOpacity(2) : Colors.transparent)),
                child: Text(opts[i] as String))));
        }),
        if (_answered) ElevatedButton(onPressed: _next,
            child: Text(_idx < AppData.quizQuestions.length - 1 ? 'السؤال التالي' : 'إنهاء الاختبار')),
      ],
    ));
  }
}
