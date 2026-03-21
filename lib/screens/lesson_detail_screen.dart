import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  Future<void> _openVideo(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(lesson['color'] as int);
    final sections = lesson['sections'] as List;
    final videoId = lesson['videoId'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(lesson['title'] as String), backgroundColor: color, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson['icon'] as String, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(lesson['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                Text('${sections.length} أقسام', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ]),
            ),
            if (videoId != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _openVideo(videoId),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 24)),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('شاهد فيديو الدرس', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('يفتح على يوتيوب', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ])),
                    const Icon(Icons.arrow_back_ios, size: 16, color: Colors.red),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ...sections.asMap().entries.map((e) {
              final section = e.value as Map;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(right: BorderSide(color: color, width: 4)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 28, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(section['heading'] as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color))),
                    ]),
                    const SizedBox(height: 10),
                    Text(section['content'] as String, style: const TextStyle(fontSize: 14, height: 1.7)),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
