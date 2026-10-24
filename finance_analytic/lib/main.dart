import 'package:finance_analytic/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAF7EF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFA45D7F),
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      fontFamily: 'Google Sans',
    );
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.googleSansTextTheme(baseTheme.textTheme),
        primaryTextTheme: GoogleFonts.googleSansTextTheme(
          baseTheme.primaryTextTheme,
        ),
      ),
      home: const FinanceDashboard(),
    );
  }
}
