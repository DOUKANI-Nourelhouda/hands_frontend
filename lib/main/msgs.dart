import 'package:flutter/material.dart';

class MsgsPage extends StatefulWidget {
  const MsgsPage({super.key});

  @override
  State<MsgsPage> createState() => _MsgsPageState();
}

class _MsgsPageState extends State<MsgsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header

            // Scrollable home content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      'Discover services in your residence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Add your home page content here.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
