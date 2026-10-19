import 'package:flutter/material.dart';
import 'package:hands/splash/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hands/services/lang_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final languageManager = LanguageManager();
  await languageManager.loadLanguage();

  runApp(
    ChangeNotifierProvider.value(
      value: languageManager,
      child: const HandsApp(),
    ),
  );
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          theme: ThemeData(fontFamily: 'VAGRoundedNext'),
          debugShowCheckedModeBanner: false,
          locale: languageManager.locale,
          supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
