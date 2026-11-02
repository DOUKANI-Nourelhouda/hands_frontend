import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const Color accentColor = Color(0xfffcc001);
  static const Color textColor = Color(0xff333333);

  Widget _section(String title, String content) {
    final isDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xff333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: isDark ? Colors.white : const Color(0xff333333),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xff333333) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xff333333) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Color(0xff333333),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          text(context, 'Terms of Service'),
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xff333333),
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
                color: isDark ? Color(0xff444444) : Color(0xfffff4cc),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.handshake_outlined,
                size: 34,
                color: isDark ? Colors.white : Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              text(context, 'Terms of Service'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Color(0xff333333),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            text(context, 'Read the rules and conditions for using Hands ') +
                text(context, 'to connect with students, offer services, ') +
                text(context, 'and exchange help within your residence.'),

            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: isDark ? Colors.white : Color(0xff777777),
            ),
          ),

          const SizedBox(height: 24),

          _section(
            text(context, '1. Acceptance of Terms'),
            text(context, 'By creating an account or using Hands, you agree ') +
                text(
                  context,
                  'to follow these Terms of Service and applicable ',
                ) +
                text(context, 'laws. If you do not agree, please stop using ') +
                text(context, 'the platform.'),
          ),

          _section(
            text(context, '2. Eligibility and Accounts'),
            text(
                  context,
                  'Hands is designed for students within participating ',
                ) +
                text(
                  context,
                  'student residences. You must provide accurate ',
                ) +
                text(
                  context,
                  'information, keep your account credentials secure, ',
                ) +
                text(context, 'and not impersonate another person or create ') +
                text(context, 'fraudulent accounts.'),
          ),

          _section(
            text(context, '3. Posts and Services'),
            text(context, 'You are responsible for the content you publish ') +
                text(
                  context,
                  'and the services you offer. Posts must be accurate, ',
                ) +
                text(
                  context,
                  'respectful, and lawful. Do not publish misleading ',
                ) +
                text(
                  context,
                  'offers, prohibited content, spam, or services ',
                ) +
                text(context, 'that could endanger other students.'),
          ),

          _section(
            text(context, '4. Communication and Conduct'),
            text(
                  context,
                  'Treat other users respectfully. Harassment, threats, ',
                ) +
                text(
                  context,
                  'fraud, discrimination, impersonation, and misuse ',
                ) +
                text(
                  context,
                  'of private information are not permitted. You may ',
                ) +
                text(context, 'block or report users who violate these rules.'),
          ),

          _section(
            text(context, '5. Transactions and Payments'),
            text(context, 'Users are responsible for agreeing on service ') +
                text(
                  context,
                  'details, prices, delivery, and payment arrangements. ',
                ) +
                text(
                  context,
                  'Hands does not guarantee the quality, completion, ',
                ) +
                text(
                  context,
                  'or outcome of services offered by other users. ',
                ) +
                text(
                  context,
                  'Any paid post-credit purchases are subject to ',
                ) +
                text(
                  context,
                  'the prices and conditions displayed at purchase.',
                ),
          ),

          _section(
            text(context, '6. Free Posts and Paid Credits'),
            text(
                  context,
                  'Hands may provide a limited number of free posts (3) ',
                ) +
                text(
                  context,
                  'and offer additional posting credits for purchase. ',
                ) +
                text(context, 'Available allowances, prices, and applicable ') +
                text(
                  context,
                  'conditions will be displayed in the app. Do not ',
                ) +
                text(
                  context,
                  'attempt to bypass posting limits or manipulate ',
                ) +
                text(context, 'payment confirmations.'),
          ),

          _section(
            text(context, '7. Privacy and Safety'),
            text(context, 'Use other students’ personal information only ') +
                text(
                  context,
                  'for legitimate purposes related to the platform. ',
                ) +
                text(
                  context,
                  'Do not share private messages, contact details, ',
                ) +
                text(
                  context,
                  'or other personal information without appropriate ',
                ) +
                text(
                  context,
                  'permission. Review our Privacy Policy to understand ',
                ) +
                text(context, 'how personal information is handled.'),
          ),

          _section(
            text(context, '8. Reporting and Account Restrictions'),
            text(context, 'Hands may review reported content and take ') +
                text(
                  context,
                  'appropriate action against accounts that violate ',
                ) +
                text(
                  context,
                  'these terms, including removing posts, restricting ',
                ) +
                text(
                  context,
                  'features, or suspending accounts, where appropriate.',
                ),
          ),

          _section(
            text(context, '9. Service Availability'),
            text(context, 'We aim to keep Hands available and functioning ') +
                text(context, 'properly, but uninterrupted access is not ') +
                text(
                  context,
                  'guaranteed. Features may be updated, changed, ',
                ) +
                text(context, 'or temporarily unavailable.'),
          ),

          _section(
            text(context, '10. Changes to These Terms'),
            text(context, 'These terms may be updated as Hands evolves. ') +
                text(
                  context,
                  'Material changes should be communicated through ',
                ) +
                text(
                  context,
                  'appropriate channels. Continued use after updated ',
                ) +
                text(
                  context,
                  'terms take effect may be subject to those terms, ',
                ) +
                text(context, 'as permitted by applicable law.'),
          ),

          _section(
            text(context, '11. Contact Us'),
            text(context, 'If you have questions about these terms, contact ') +
                text(context, 'the Hands team through the official support ') +
                text(context, 'email @@@@@@@@@@@@.'),
          ),

          const Divider(height: 32),

          Center(
            child: Text(
              text(context, 'Hands - To survive in your residence.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Color(0xff333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
