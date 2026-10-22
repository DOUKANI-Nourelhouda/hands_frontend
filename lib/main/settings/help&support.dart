import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent, size: 38, color: textColor),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Find answers to common questions or '
                    'get help with your Hands account.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Frequently asked questions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 14),

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

            _buildFaq(
              question: 'What if my messages are not working?',
              answer:
                  'Check your internet connection and reopen the '
                  'app. If the problem continues, contact support '
                  'and describe what happened.',
            ),

            const SizedBox(height: 24),

            const Text(
              'Still need help?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose an option below to get assistance.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 14),

            _buildContactTile(
              icon: Icons.email_outlined,
              title: 'Email support',
              subtitle: 'Get help with an account or a problem',
              onTap: () {
                _showMessage(
                  context,
                  'Configure your official support email here.',
                );
              },
            ),

            _buildContactTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a technical issue',
              subtitle: 'Tell us about a bug or broken feature',
              onTap: () {
                _showMessage(
                  context,
                  'Connect this option to your issue report form.',
                );
              },
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Hands • We are here to help',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
