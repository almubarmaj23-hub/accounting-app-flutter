import 'package:flutter/material.dart';
import '../data/app_data.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});
  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final Set<int> _revealed = {};

  Color _levelColor(String level) {
    switch (level) {
      case 'مبتدئ': return Colors.green;
      case 'متوسط': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('التمارين التطبيقية')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.exercises.length,
        itemBuilder: (ctx, i) {
          final ex = AppData.exercises[i];
          final isOpen = _revealed.contains(i);
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: Text(ex['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _levelColor(ex['level']!).withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(ex['level']!, style: TextStyle(color: _levelColor(ex['level']!), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(ex['question']!, style: TextStyle(color: Colors.grey[700], height: 1.6)),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => setState(() => isOpen ? _revealed.remove(i) : _revealed.add(i)),
                  icon: Icon(isOpen ? Icons.visibility_off : Icons.lightbulb_outline),
                  label: Text(isOpen ? 'إخفاء الحل' : 'عرض الحل'),
                ),
                if (isOpen) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(.3)),
                    ),
                    child: Text(ex['solution']!, style: const TextStyle(height: 1.7)),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}
