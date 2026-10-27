import 'package:finance_analytic/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finance_analytic/firebase_options.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  try {
    if (foundation.kIsWeb) {
      const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
      const messagingSenderId = String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      );
      const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
      const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
      if ([apiKey, appId, messagingSenderId, projectId].every(
        (value) => value.isNotEmpty,
      )) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            authDomain: authDomain.isEmpty ? null : authDomain,
            storageBucket: storageBucket.isEmpty ? null : storageBucket,
          ),
        );
      } else {
        debugPrint('Firebase web configuration is missing.');
      }
    } else {
      if (foundation.defaultTargetPlatform == TargetPlatform.android) {
        // Explicit options avoid relying on generated Android resources when
        // Firebase's default app is initialized before authentication starts.
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.android,
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } on FirebaseException catch (error) {
    setFirebaseInitializationError('${error.code}: ${error.message}');
    debugPrint('Firebase is not configured: ${error.code}');
  } catch (error) {
    setFirebaseInitializationError(error.toString());
    debugPrint('Firebase initialization failed: $error');
  }
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
      title: 'Finora: Finance Tracker',
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
