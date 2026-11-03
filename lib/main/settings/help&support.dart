import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color accentColor = Color(0xfffcc001);
  static const Color textColor = Color(0xff333333);

  Widget _buildFaq({
    required String question,
    required String answer,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF444444) : Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        iconColor: isDark ? Colors.white : Color(0xFF333333),
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Color(0xFF333333),
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: isDark ? Colors.white : Color(0xFF333333),
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
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Color(0xFF444444) : Colors.grey.shade200,
          ),
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
              child: Icon(
                icon,
                color: isDark ? Colors.white : Color(0xFF333333),
              ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : Color(0xFF333333),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          text(context, 'Help & Support'),
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF444444) : Color(0xfffff4cc),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.support_agent_outlined,
                size: 34,
                color: isDark ? Colors.white : Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              text(context, 'How can we help you?'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            text(context, 'Find answers to common questions or get help ') +
                text(
                  context,
                  'with your Hands account and services within your residence.',
                ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark ? Colors.white : Color(0xff777777),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            text(context, 'Frequently asked questions :'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xff292929),
            ),
          ),

          const SizedBox(height: 14),

          // Keep your existing FAQ items and support content here.
          _buildFaq(
            context: context,
            question: text(context, 'What is Hands?'),
            answer:
                text(
                  context,
                  'Hands is a social marketplace designed for students living ',
                ) +
                text(
                  context,
                  'in the same residence. It combines social media features ',
                ) +
                text(
                  context,
                  'with a platform where students can offer services, discover ',
                ) +
                text(
                  context,
                  'what others provide, connect through messages, and support ',
                ) +
                text(context, 'their student community.'),
          ),

          _buildFaq(
            context: context,
            question: text(context, 'Why can I only see certain posts?'),
            answer:
                text(
                  context,
                  'Posts are intended for students in your residence. ',
                ) +
                text(
                  context,
                  'Make sure your account is associated with the ',
                ) +
                text(context, 'correct residence.'),
          ),

          _buildFaq(
            context: context,
            question: text(context, 'How can I publish a post?'),
            answer:
                text(
                  context,
                  'Open the create-post screen, add your service ',
                ) +
                text(
                  context,
                  'details and media, then follow the instructions ',
                ) +
                text(
                  context,
                  'to publish. Posting allowances and any applicable ',
                ) +
                text(context, 'credit requirements are shown in the app.'),
          ),

          _buildFaq(
            context: context,
            question: text(context, 'Why can’t I publish another post?'),
            answer:
                text(
                  context,
                  'You may have used your free posting allowance ',
                ) +
                text(
                  context,
                  'and may need additional post credits. Check the ',
                ) +
                text(context, 'credits section in your profile.'),
          ),

          _buildFaq(
            context: context,
            question: text(context, 'How do I block or report someone?'),
            answer:
                text(
                  context,
                  'Open the relevant profile or post and use the ',
                ) +
                text(context, 'available block or report option. If someone ') +
                text(
                  context,
                  'makes you feel unsafe, avoid sharing personal ',
                ) +
                text(context, 'information and contact support.'),
          ),

          _buildFaq(
            context: context,
            question: text(context, 'How can I edit my profile?'),
            answer:
                text(
                  context,
                  'Open your profile and use the available profile ',
                ) +
                text(context, 'editing option to update your username, bio, ') +
                text(context, 'or profile picture.'),
          ),

          Text(
            text(context, 'Still need help?'),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 14),

          _buildContactTile(
            context: context,
            icon: Icons.email_outlined,
            title: textRead(context, 'Email support'),
            subtitle: 'handsapppp@gmail.com',
          ),

          Center(
            child: Text(
              text(context, 'Hands - To survive in your residence.'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
