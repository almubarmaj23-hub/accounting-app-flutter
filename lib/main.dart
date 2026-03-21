import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final prefs = await SharedPreferences.getInstance();
  runApp(AccountingApp(prefs: prefs));
}

class AccountingApp extends StatefulWidget {
  final SharedPreferences prefs;
  const AccountingApp({super.key, required this.prefs});
  @override
  State<AccountingApp> createState() => _AccountingAppState();
}

class _AccountingAppState extends State<AccountingApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.prefs.getBool('darkMode') ?? false;
  }

  void toggleTheme() {
    setState(() {
      _isDark = !_isDark;
      widget.prefs.setBool('darkMode', _isDark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المحاسبة المالية',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: HomeScreen(isDark: _isDark, onToggleTheme: toggleTheme, prefs: widget.prefs),
    );
  }
}
