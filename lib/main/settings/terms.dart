import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const Color accentColor = Color(0xfffcc001);
  static const Color textColor = Color(0xff1e1f24);

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Colors.black87,
            ),
          ),
        ],
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms of Service',
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
                Icons.handshake_outlined,
                size: 34,
                color: Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xff292929),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Read the rules and conditions for using Hands '
            'to connect with students, offer services, '
            'and exchange help within your residence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xff777777),
            ),
          ),

          const SizedBox(height: 24),

          _section(
            '1. Acceptance of Terms',
            'By creating an account or using Hands, you agree '
                'to follow these Terms of Service and applicable '
                'laws. If you do not agree, please stop using '
                'the platform.',
          ),

          _section(
            '2. Eligibility and Accounts',
            'Hands is designed for students within participating '
                'student residences. You must provide accurate '
                'information, keep your account credentials secure, '
                'and not impersonate another person or create '
                'fraudulent accounts.',
          ),

          _section(
            '3. Posts and Services',
            'You are responsible for the content you publish '
                'and the services you offer. Posts must be accurate, '
                'respectful, and lawful. Do not publish misleading '
                'offers, prohibited content, spam, or services '
                'that could endanger other students.',
          ),

          _section(
            '4. Communication and Conduct',
            'Treat other users respectfully. Harassment, threats, '
                'fraud, discrimination, impersonation, and misuse '
                'of private information are not permitted. You may '
                'block or report users who violate these rules.',
          ),

          _section(
            '5. Transactions and Payments',
            'Users are responsible for agreeing on service '
                'details, prices, delivery, and payment arrangements. '
                'Hands does not guarantee the quality, completion, '
                'or outcome of services offered by other users. '
                'Any paid post-credit purchases are subject to '
                'the prices and conditions displayed at purchase.',
          ),

          _section(
            '6. Free Posts and Paid Credits',
            'Hands may provide a limited number of free posts '
                'and offer additional posting credits for purchase. '
                'Available allowances, prices, and applicable '
                'conditions will be displayed in the app. Do not '
                'attempt to bypass posting limits or manipulate '
                'payment confirmations.',
          ),

          _section(
            '7. Privacy and Safety',
            'Use other students’ personal information only '
                'for legitimate purposes related to the platform. '
                'Do not share private messages, contact details, '
                'or other personal information without appropriate '
                'permission. Review our Privacy Policy to understand '
                'how personal information is handled.',
          ),

          _section(
            '8. Reporting and Account Restrictions',
            'Hands may review reported content and take '
                'appropriate action against accounts that violate '
                'these terms, including removing posts, restricting '
                'features, or suspending accounts, where appropriate.',
          ),

          _section(
            '9. Service Availability',
            'We aim to keep Hands available and functioning '
                'properly, but uninterrupted access is not '
                'guaranteed. Features may be updated, changed, '
                'or temporarily unavailable.',
          ),

          _section(
            '10. Changes to These Terms',
            'These terms may be updated as Hands evolves. '
                'Material changes should be communicated through '
                'appropriate channels. Continued use after updated '
                'terms take effect may be subject to those terms, '
                'as permitted by applicable law.',
          ),

          _section(
            '11. Contact Us',
            'If you have questions about these terms, contact '
                'the Hands team through the official support '
                'email @@@@@@@@@@@@.',
          ),

          const Divider(height: 32),

          const Center(
            child: Text(
              'Hands ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
