import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color _yellow = Color(0xfffcc001);

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffeeeeee)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _yellow, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff292929),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Color(0xff666666),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy policy',
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
                Icons.privacy_tip_outlined,
                size: 34,
                color: Color(0xff292929),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Your privacy matters',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xff292929),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn how Hands handles your information when '
            'you use the app to connect with students and '
            'exchange services within your residence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xff777777),
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            icon: Icons.person_outline,
            title: '1. Information we collect',
            content:
                'Hands may collect information you provide when creating '
                'your account, such as your username, email address, '
                'residence, profile picture, and bio. Content you publish, '
                'including posts, comments, and media, may also be stored '
                'to provide the app services.',
          ),

          _buildSection(
            icon: Icons.home_outlined,
            title: '2. Residence-based access',
            content:
                'Hands is designed to connect students within their '
                'residence. Your residence information is used to help '
                'provide residence-based features. This does not mean '
                'every piece of your personal information is visible '
                'to every resident.',
          ),

          _buildSection(
            icon: Icons.chat_bubble_outline,
            title: '3. Messages and communication',
            content:
                'Hands allows users to communicate through messages. '
                'Messages are intended for the relevant conversation '
                'participants. Do not share passwords, financial details, '
                'or other sensitive information in chats. Only describe '
                'messages as private or encrypted if the app actually '
                'provides those protections.',
          ),

          _buildSection(
            icon: Icons.photo_outlined,
            title: '4. Posts and profile information',
            content:
                'Information you publish on your profile or in posts may '
                'be visible to other users who are permitted to access it. '
                'Think carefully before publishing personal details or '
                'uploading photos and videos.',
          ),

          _buildSection(
            icon: Icons.block_outlined,
            title: '5. Blocking and reporting',
            content:
                'You can use available blocking features to limit '
                'interactions with specific accounts. Reports may be '
                'reviewed to help address inappropriate content or '
                'behavior. Blocking should not be treated as a guarantee '
                'that all previous interactions or content are erased.',
          ),

          _buildSection(
            icon: Icons.security_outlined,
            title: '6. Data security',
            content:
                'We use technical and organizational measures intended '
                'to protect account information. No online service can '
                'guarantee absolute security. Keep your login credentials '
                'safe and report suspicious activity.',
          ),

          _buildSection(
            icon: Icons.cloud_outlined,
            title: '7. Storage and service providers',
            content:
                'Information may be processed by the service providers '
                'needed to operate Hands, such as database, media storage, '
                'authentication, and payment providers, where applicable. '
                'The final policy should identify the providers actually '
                'used and explain their relevant roles.',
          ),

          _buildSection(
            icon: Icons.delete_outline,
            title: '8. Your choices and your data',
            content:
                'You can manage information through the settings and '
                'features available in Hands. You may request access to, '
                'correction of, or deletion of your personal information, '
                'subject to applicable law and legitimate retention '
                'requirements. Add your actual account-deletion process '
                'and contact details before publishing this policy.',
          ),

          _buildSection(
            icon: Icons.child_care_outlined,
            title: '9. Age requirements',
            content:
                'Hands is intended for its eligible student audience. '
                'The app should apply and communicate its actual minimum '
                'age requirements and comply with the laws applicable '
                'to its users.',
          ),

          _buildSection(
            icon: Icons.update_outlined,
            title: '10. Changes to this policy',
            content:
                'This policy may be updated when Hands changes its '
                'features or legal requirements change. When appropriate, '
                'users will be informed of significant changes.',
          ),

          _buildSection(
            icon: Icons.mail_outline,
            title: '11. Contact us',
            content:
                'For questions about this policy or your personal '
                'information, contact the Hands team at the official '
                'privacy email address published by the app developer.',
          ),

          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Draft for review — add the effective date and '
              'verified contact details before publication.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xff999999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
