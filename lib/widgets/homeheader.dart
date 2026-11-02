import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/main/notification.dart';
import 'package:hands/utils/langs.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static const Color accent = Color(0xfffcc001);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            Image.asset(
              'assets/logo_exct.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),

            // Hands: always centered
            Expanded(
              child: Center(
                child: Text(
                  'Hands',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : Color(0xff333333),
                  ),
                ),
              ),
            ),

            // SVG notification: top right
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
              icon: SvgPicture.asset(
                'assets/icons/notification.svg',
                width: 33,
                height: 33,
                colorFilter: const ColorFilter.mode(
                  Color(0xfffcc001),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
