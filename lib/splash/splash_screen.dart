import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hands/main/main.dart';
import 'package:hands/splash/welcome_screen.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  final String word = "Hands";

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 3300));

    final authService = AuthService();
    final isLoggedIn = await authService.isSessionValid();

    if (!mounted) return;

    if (isLoggedIn) {
      final token = await authService.getSavedToken();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
        return;
      }

      final baseUrl = dotenv.env['BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BASE_URL is missing from .env');
      }

      final postService = PostService(baseUrl: baseUrl, token: token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(postService: postService)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _startAnimation();
    _checkLoginStatus();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      _textController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildLetter(int index) {
    final double start = index * 0.15;
    final double end = start + 0.30;

    final animation = CurvedAnimation(
      parent: _textController,
      curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double xOffset = 35 * (1 - animation.value);

        return Transform.translate(
          offset: Offset(xOffset, 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Text(
        word[index],
        style: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO
            FadeTransition(
              opacity: _logoOpacity,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  'assets/logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                word.length,
                (index) => _buildLetter(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
