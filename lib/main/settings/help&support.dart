import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color accentColor = Color(0xfffcc001);
  static const Color textColor = Color(0xff1e1f24);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildFaq({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        // Remove the top and bottom lines
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),

        iconColor: textColor,
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: textColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xfffff4cc),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.support_agent_outlined,
                size: 34,
                color: Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Find answers to common questions or get help '
            'with your Hands account and services within your residence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xff777777),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Frequently asked questions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff292929),
            ),
          ),

          const SizedBox(height: 14),

          // Keep your existing FAQ items and support content here.
          _buildFaq(
            question: 'What is Hands?',
            answer:
                'Hands is a social marketplace designed for students living '
                'in the same residence. It combines social media features '
                'with a platform where students can offer services, discover '
                'what others provide, connect through messages, and support '
                'their student community.',
          ),

          _buildFaq(
            question: 'Why can I only see certain posts?',
            answer:
                'Posts are intended for students in your residence. '
                'Make sure your account is associated with the '
                'correct residence.',
          ),

          _buildFaq(
            question: 'How can I publish a post?',
            answer:
                'Open the create-post screen, add your service '
                'details and media, then follow the instructions '
                'to publish. Posting allowances and any applicable '
                'credit requirements are shown in the app.',
          ),

          _buildFaq(
            question: 'Why can’t I publish another post?',
            answer:
                'You may have used your free posting allowance '
                'and may need additional post credits. Check the '
                'credits section in your profile.',
          ),

          _buildFaq(
            question: 'How do I block or report someone?',
            answer:
                'Open the relevant profile or post and use the '
                'available block or report option. If someone '
                'makes you feel unsafe, avoid sharing personal '
                'information and contact support.',
          ),

          _buildFaq(
            question: 'How can I edit my profile?',
            answer:
                'Open your profile and use the available profile '
                'editing option to update your username, bio, '
                'or profile picture.',
          ),

          const Text(
            'Still need help?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 14),

          _buildContactTile(
            icon: Icons.email_outlined,
            title: 'Email support',
            subtitle: 'Get help with an account or a problem',
            onTap: () {
              _showMessage(context, '@@@@@@@@@@@@@');
            },
          ),

          Center(
            child: Text(
              text(context, 'Hands • We are here to help'),
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
