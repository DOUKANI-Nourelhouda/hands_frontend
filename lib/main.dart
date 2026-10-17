import 'package:flutter/material.dart';
import 'package:hands/splash/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const HandsApp());
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'VAGRoundedNext'),
      debugShowCheckedModeBanner: false,
      title: 'Hands',
      home: const SplashScreen(),
    );
  }
}
