import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/main/notification.dart';
import 'package:hands/services/notification_service.dart';

class HomeHeader extends StatefulWidget {
  final Future<void> Function(String postId)? onPostTap;
  final void Function(String userId)? onProfileTap;
  final Future<void> Function(Map<String, dynamic> conversation)?
  onConversationTap;
  const HomeHeader({
    super.key,
    this.onPostTap,
    this.onProfileTap,
    this.onConversationTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  static const Color accent = Color(0xfffcc001);

  final NotificationService _notificationService = NotificationService();

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();

      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread notifications: $e');
    }
  }

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

            Expanded(
              child: Center(
                child: Text(
                  'Hands',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : const Color(0xff333333),
                  ),
                ),
              ),
            ),

            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(
                      onPostTap: (postId) async {
                        Navigator.pop(context);

                        await widget.onPostTap?.call(postId);
                      },

                      onProfileTap: (userId) {
                        widget.onProfileTap?.call(userId);
                      },

                      onConversationTap: (conversation) async {
                        await widget.onConversationTap?.call(conversation);
                      },
                    ),
                  ),
                );

                _loadUnreadCount();
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/icons/notification.svg',
                    width: 33,
                    height: 33,
                    colorFilter: const ColorFilter.mode(
                      accent,
                      BlendMode.srcIn,
                    ),
                  ),

                  // Yellow circle for unread notifications
                  if (_unreadCount > 0)
                    Positioned(
                      top: 1.5,
                      right: -2.5,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
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
}
