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
        title: Text(
          text(context, 'Privacy Policy'),
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
          Center(
            child: Text(
              text(context, 'Your privacy matters'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xff292929),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text(context, 'Learn how Hands handles your information when ') +
                text(context, 'you use the app to connect with students and ') +
                text(context, 'exchange services within your residence.'),

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
            title: text(context, '1. Information we collect'),
            content:
                text(
                  context,
                  'Hands may collect information you provide when creating ',
                ) +
                text(
                  context,
                  'your account, such as your username, email address, ',
                ) +
                text(
                  context,
                  'residence, profile picture, and bio. Content you publish, ',
                ) +
                text(
                  context,
                  'including posts, comments, and media, may also be stored ',
                ) +
                text(context, 'to provide the app services.'),
          ),

          _buildSection(
            icon: Icons.home_outlined,
            title: text(context, '2. Residence-based access'),
            content:
                text(
                  context,
                  'Hands is designed to connect students within their ',
                ) +
                text(
                  context,
                  'residence. Your residence information is used to help ',
                ) +
                text(
                  context,
                  'provide residence-based features. This does not mean ',
                ) +
                text(
                  context,
                  'every piece of your personal information is visible ',
                ) +
                text(context, 'to every resident.'),
          ),

          _buildSection(
            icon: Icons.chat_bubble_outline,
            title: text(context, '3. Messages and communication'),
            content:
                text(
                  context,
                  'Hands allows users from the same residence to communicate through messages. ',
                ) +
                text(
                  context,
                  'Messages are intended for the relevant conversation ',
                ) +
                text(
                  context,
                  'participants. Do not share passwords, financial details, ',
                ) +
                text(
                  context,
                  'or other sensitive information in chats. Only describe ',
                ) +
                text(context, 'messages as private or encrypted.'),
          ),

          _buildSection(
            icon: Icons.photo_outlined,
            title: text(context, '4. Posts and profile information'),
            content:
                text(
                  context,
                  'Information you publish on your profile or in posts may ',
                ) +
                text(
                  context,
                  'be visible to other users who are permitted to access it. ',
                ) +
                text(
                  context,
                  'Think carefully before publishing personal details or ',
                ) +
                text(context, 'uploading photos and videos.'),
          ),

          _buildSection(
            icon: Icons.block_outlined,
            title: text(context, '5. Blocking and reporting'),
            content:
                text(
                  context,
                  'You can use available blocking features to limit ',
                ) +
                text(
                  context,
                  'interactions with specific accounts. Reports may be ',
                ) +
                text(
                  context,
                  'reviewed to help address inappropriate content or ',
                ) +
                text(
                  context,
                  'behavior. Blocking should not be treated as a guarantee ',
                ) +
                text(
                  context,
                  'that all previous interactions or content are erased.',
                ),
          ),

          _buildSection(
            icon: Icons.security_outlined,
            title: text(context, '6. Data security'),
            content:
                text(
                  context,
                  'We use technical and organizational measures intended ',
                ) +
                text(
                  context,
                  'to protect account information. No online service can ',
                ) +
                text(
                  context,
                  'guarantee absolute security. Keep your login credentials ',
                ) +
                text(context, 'safe and report suspicious activity.'),
          ),

          _buildSection(
            icon: Icons.cloud_outlined,
            title: text(context, '7. Storage and service providers'),
            content:
                text(
                  context,
                  'Information may be processed by the service providers ',
                ) +
                text(
                  context,
                  'needed to operate Hands, such as database, media storage, ',
                ) +
                text(
                  context,
                  'authentication, and payment providers, where applicable. ',
                ) +
                text(
                  context,
                  'The final policy should identify the providers actually ',
                ) +
                text(context, 'used and explain their relevant roles.'),
          ),

          _buildSection(
            icon: Icons.delete_outline,
            title: text(context, '8. Your choices and your data'),
            content:
                text(
                  context,
                  'You can manage information through the settings and ',
                ) +
                text(
                  context,
                  'features available in Hands. You may request access to, ',
                ) +
                text(
                  context,
                  'correction of, or deletion of your personal information, ',
                ) +
                text(
                  context,
                  'subject to applicable law and legitimate retention ',
                ) +
                text(
                  context,
                  'requirements. Add your actual account-deletion process ',
                ) +
                text(
                  context,
                  'and contact details before publishing this policy.',
                ),
          ),

          _buildSection(
            icon: Icons.child_care_outlined,
            title: text(context, '9. Age requirements'),
            content:
                text(
                  context,
                  'Hands is intended for its eligible student audience. ',
                ) +
                text(
                  context,
                  'The app should apply and communicate its actual minimum ',
                ) +
                text(
                  context,
                  'age requirements and comply with the laws applicable ',
                ) +
                text(context, 'to its users.'),
          ),

          _buildSection(
            icon: Icons.update_outlined,
            title: text(context, '10. Changes to this policy'),
            content:
                text(
                  context,
                  'This policy may be updated when Hands changes its ',
                ) +
                text(
                  context,
                  'features or legal requirements change. When appropriate, ',
                ) +
                text(context, 'users will be informed of significant changes.'),
          ),

          _buildSection(
            icon: Icons.mail_outline,
            title: text(context, '11. Contact us'),
            content:
                text(
                  context,
                  'For questions about this policy or your personal ',
                ) +
                text(
                  context,
                  'information, contact the Hands team at the official ',
                ) +
                text(context, 'privacy email address @@@@@@@@@2@@@@@@@.'),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              text(context, 'Hands - To survive in your residence.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xff999999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
