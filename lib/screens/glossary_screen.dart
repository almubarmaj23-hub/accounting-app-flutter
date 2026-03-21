import 'package:flutter/material.dart';
import '../data/app_data.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = AppData.glossary
        .where((g) =>
            g['ar']!.contains(_search) ||
            g['en']!.toLowerCase().contains(_search.toLowerCase()) ||
            g['def']!.contains(_search))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('قاموس المصطلحات'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث بالعربية أو الإنجليزية...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('لا توجد نتائج', style: TextStyle(fontSize: 16)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final g = filtered[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  title: Row(
                    children: [
                      Text(g['ar']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(g['en']!, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(g['def']!, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                  ),
                );
              },
            ),
    );
  }
}
