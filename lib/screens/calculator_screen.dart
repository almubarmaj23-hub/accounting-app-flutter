import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  // إهلاك
  final _cost = TextEditingController();
  final _salvage = TextEditingController();
  final _life = TextEditingController();
  String _depMethod = 'sl';
  List<Map<String, double>> _depTable = [];

  // نقطة التعادل
  final _price = TextEditingController();
  final _vc = TextEditingController();
  final _fc = TextEditingController();
  double? _beUnits, _beSales;

  // نسب مالية
  final _ca = TextEditingController();
  final _cl = TextEditingController();
  final _ni = TextEditingController();
  final _sales = TextEditingController();
  Map<String, String> _ratios = {};

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    for (var c in [_cost,_salvage,_life,_price,_vc,_fc,_ca,_cl,_ni,_sales]) c.dispose();
    super.dispose();
  }

  void _calcDep() {
    final cost = double.tryParse(_cost.text) ?? 0;
    final salv = double.tryParse(_salvage.text) ?? 0;
    final life = int.tryParse(_life.text) ?? 0;
    if (cost <= 0 || life <= 0) return;
    List<Map<String, double>> table = [];
    double bv = cost, acc = 0;
    for (int y = 1; y <= life; y++) {
      double dep;
      if (_depMethod == 'sl') {
        dep = (cost - salv) / life;
      } else {
        dep = bv * (2 / life);
        if (bv - dep < salv) dep = bv - salv;
      }
      if (dep < 0) dep = 0;
      acc += dep; bv -= dep;
      table.add({'year': y.toDouble(), 'dep': dep, 'acc': acc, 'bv': bv});
    }
    setState(() => _depTable = table);
  }

  void _calcBE() {
    final p = double.tryParse(_price.text) ?? 0;
    final vc = double.tryParse(_vc.text) ?? 0;
    final fc = double.tryParse(_fc.text) ?? 0;
    if (p <= vc || fc <= 0) return;
    setState(() {
      _beUnits = fc / (p - vc);
      _beSales = _beUnits! * p;
    });
  }

  void _calcRatios() {
    final ca = double.tryParse(_ca.text) ?? 0;
    final cl = double.tryParse(_cl.text) ?? 0;
    final ni = double.tryParse(_ni.text) ?? 0;
    final s = double.tryParse(_sales.text) ?? 0;
    if (cl <= 0) return;
    setState(() {
      _ratios = {
        'نسبة التداول': (ca / cl).toStringAsFixed(2),
        'هامش الربح': s > 0 ? '${(ni / s * 100).toStringAsFixed(1)}%' : '-',
      };
    });
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحاسبة المحاسبية'),
        bottom: TabBar(
          controller: _tc,
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'الإهلاك'),
            Tab(icon: Icon(Icons.trending_flat), text: 'التعادل'),
            Tab(icon: Icon(Icons.pie_chart), text: 'النسب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tc,
        children: [
          // ─── الإهلاك ───
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(controller: _cost, decoration: _dec('تكلفة الأصل'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _salvage, decoration: _dec('القيمة التخريدية'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _life, decoration: _dec('العمر الإنتاجي (سنوات)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _depMethod,
                decoration: _dec('طريقة الإهلاك'),
                items: const [
                  DropdownMenuItem(value: 'sl', child: Text('القسط الثابت')),
                  DropdownMenuItem(value: 'ddb', child: Text('القسط المتناقص')),
                ],
                onChanged: (v) => setState(() => _depMethod = v!),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calcDep,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب الإهلاك'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              if (_depTable.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: const [
                        Expanded(child: Text('السنة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('قسط الإهلاك', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('القيمة الدفترية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                    ),
                    const Divider(height: 1),
                    ..._depTable.map((row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(children: [
                        Expanded(child: Text('${row['year']!.toInt()}', textAlign: TextAlign.center)),
                        Expanded(child: Text(row['dep']!.toStringAsFixed(0), textAlign: TextAlign.center)),
                        Expanded(child: Text(row['bv']!.toStringAsFixed(0), textAlign: TextAlign.center)),
                      ]),
                    )),
                  ]),
                ),
              ],
            ]),
          ),
          // ─── نقطة التعادل ───
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(controller: _price, decoration: _dec('سعر البيع للوحدة'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _vc, decoration: _dec('التكلفة المتغيرة للوحدة'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _fc, decoration: _dec('التكاليف الثابتة الإجمالية'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calcBE,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب نقطة التعادل'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              if (_beUnits != null) ...[
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _resultRow('هامش المساهمة', '${(double.parse(_price.text) - double.parse(_vc.text)).toStringAsFixed(2)} ريال'),
                      const Divider(),
                      _resultRow('نقطة التعادل (وحدات)', '${_beUnits!.ceil().toString()} وحدة'),
                      _resultRow('نقطة التعادل (ريال)', '${_beSales!.toStringAsFixed(0)} ريال'),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
          // ─── النسب ───
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(controller: _ca, decoration: _dec('الأصول المتداولة'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _cl, decoration: _dec('الخصوم المتداولة'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _ni, decoration: _dec('صافي الربح'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: _sales, decoration: _dec('صافي المبيعات'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _calcRatios,
                icon: const Icon(Icons.analytics),
                label: const Text('احسب النسب'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              if (_ratios.isNotEmpty) ...[
                const SizedBox(height: 20),
                ..._ratios.entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(e.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                  ),
                )),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14)),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]),
  );
}
