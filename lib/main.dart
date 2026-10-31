import 'package:flutter/material.dart';
import 'package:hands/splash/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hands/services/lang_manager.dart';
import 'package:hands/utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final languageManager = LanguageManager();
  await languageManager.loadLanguage();

  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageManager),
        ChangeNotifierProvider.value(value: themeManager),
      ],
      child: const HandsApp(),
    ),
  );
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageManager, ThemeManager>(
      builder: (context, languageManager, themeManager, child) {
        return MaterialApp(
          theme: ThemeData(
            fontFamily: 'VAGRoundedNext',
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),

          darkTheme: ThemeData(
            fontFamily: 'VAGRoundedNext',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xff121212),
          ),

          themeMode: themeManager.themeMode,

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
