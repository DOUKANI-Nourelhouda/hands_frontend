import 'package:flutter/material.dart';
import 'package:hands/services/notification_service.dart';
import 'package:hands/utils/langs.dart';

class NotificationsPage extends StatefulWidget {
  final Future<void> Function(String postId)? onPostTap;
  final void Function(String userId)? onProfileTap;
  final Future<void> Function(Map<String, dynamic> conversation)?
  onConversationTap;

  const NotificationsPage({
    super.key,
    this.onPostTap,
    this.onProfileTap,
    this.onConversationTap,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color accent = Color(0xfffcc001);

  final NotificationService _service = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isMarkingAll = false;
  bool _hasNextPage = false;

  String? _errorMessage;
  int _page = 1;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (_hasNextPage && !_isLoadingMore && !_isLoading) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _service.getNotifications(page: 1, limit: 20);

      final rawItems = result['notifications'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _notifications = items;
        _page = (result['page'] as num?)?.toInt() ?? 1;
        _hasNextPage = result['hasNextPage'] == true;
        _unreadCount = (result['unreadCount'] as num?)?.toInt() ?? 0;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasNextPage || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _service.getNotifications(
        page: _page + 1,
        limit: 20,
      );

      final rawItems = result['notifications'];
      final items = rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        final existingIds = _notifications
            .map((n) => n['_id']?.toString())
            .whereType<String>()
            .toSet();

        _notifications.addAll(
          items.where((n) => !existingIds.contains(n['_id']?.toString())),
        );

        _page = (result['page'] as num?)?.toInt() ?? _page + 1;
        _hasNextPage = result['hasNextPage'] == true;
        _unreadCount = (result['unreadCount'] as num?)?.toInt() ?? _unreadCount;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingMore = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textRead(
              context,
              'Could not load more notifications: '
              '${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _markAsRead(int index) async {
    final notification = _notifications[index];

    if (notification['isRead'] == true) return;

    final id = notification['_id']?.toString();
    if (id == null || id.isEmpty) return;

    // Update the UI immediately.
    setState(() {
      _notifications[index]['isRead'] = true;
      if (_unreadCount > 0) _unreadCount--;
    });

    try {
      await _service.markAsRead(id);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _notifications[index]['isRead'] = false;
        _unreadCount++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text(
              context,
              'Could not mark as read: '
              '${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(int index) async {
    if (index < 0 || index >= _notifications.length) {
      debugPrint('[NOTIFICATION TAP] Invalid index: $index');
      return;
    }

    final notification = _notifications[index];
    final type = notification['type']?.toString().toLowerCase();

    debugPrint('\n========== NOTIFICATION TAPPED ==========');
    debugPrint('[NOTIFICATION] Index: $index');
    debugPrint('[NOTIFICATION] Type: $type');
    debugPrint('[NOTIFICATION] Full data: $notification');
    debugPrint('[NOTIFICATION] ID: ${notification['_id']}');
    debugPrint('[NOTIFICATION] Post: ${notification['post']}');
    debugPrint('[NOTIFICATION] Sender: ${notification['sender']}');
    debugPrint('[NOTIFICATION] Conversation: ${notification['conversation']}');

    await _markAsRead(index);

    if (!mounted) return;

    switch (type) {
      case 'like':
      case 'comment':
        debugPrint('\n[NOTIFICATION POST] Processing $type notification');

        final post = _asMap(notification['post']);

        final postId =
            (post?['_id'] ??
                    post?['id'] ??
                    notification['postId'] ??
                    notification['post'] ??
                    '')
                .toString();

        debugPrint('[NOTIFICATION POST] Post object: $post');
        debugPrint('[NOTIFICATION POST] Extracted post ID: $postId');
        debugPrint(
          '[NOTIFICATION POST] Callback available: ${widget.onPostTap != null}',
        );

        if (postId.isEmpty) {
          debugPrint('[NOTIFICATION POST] ERROR: Post ID is empty');
          return;
        }

        if (widget.onPostTap == null) {
          debugPrint('[NOTIFICATION POST] ERROR: onPostTap callback is null');
          return;
        }

        debugPrint('[NOTIFICATION POST] Calling onPostTap...');
        await widget.onPostTap!(postId);
        debugPrint('[NOTIFICATION POST] Callback completed.');
        break;

      case 'follow':
        debugPrint('\n[NOTIFICATION FOLLOW] Processing follow notification');

        final sender = _asMap(notification['sender']);
        final userId = (sender?['_id'] ?? sender?['id'] ?? '').toString();

        debugPrint('[NOTIFICATION FOLLOW] Sender: $sender');
        debugPrint('[NOTIFICATION FOLLOW] User ID: $userId');
        debugPrint(
          '[NOTIFICATION FOLLOW] Callback available: ${widget.onProfileTap != null}',
        );

        if (userId.isNotEmpty && widget.onProfileTap != null) {
          debugPrint('[NOTIFICATION FOLLOW] Calling onProfileTap...');
          widget.onProfileTap!(userId);
        } else {
          debugPrint(
            '[NOTIFICATION FOLLOW] ERROR: Missing user ID or callback',
          );
        }
        break;

      case 'message':
        final conversation = _asMap(notification['conversation']);
        final sender = _asMap(notification['sender']);

        debugPrint('[NOTIFICATION MESSAGE] Conversation: $conversation');
        debugPrint('[NOTIFICATION MESSAGE] Sender: $sender');

        if (conversation != null && widget.onConversationTap != null) {
          // Copy the conversation and attach the sender information.
          final conversationWithSender = Map<String, dynamic>.from(
            conversation,
          );

          if (sender != null) {
            conversationWithSender['sender'] = sender;
          }

          debugPrint(
            '[NOTIFICATION MESSAGE] Opening conversation with sender: '
            '${sender?['_id']}',
          );

          await widget.onConversationTap!(conversationWithSender);
        } else {
          debugPrint(
            '[NOTIFICATION MESSAGE] Cannot open: '
            'conversation or callback is null.',
          );
        }
        break;

      default:
        debugPrint('[NOTIFICATION] Unknown notification type: $type');
    }

    debugPrint('========== END NOTIFICATION TAP ==========\n');
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0 || _isMarkingAll) return;

    setState(() => _isMarkingAll = true);

    try {
      await _service.markAllAsRead();

      if (!mounted) return;

      setState(() {
        for (final notification in _notifications) {
          notification['isRead'] = true;
        }
        _unreadCount = 0;
        _isMarkingAll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(textRead(context, 'All notifications marked as read.')),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isMarkingAll = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text(context, e.toString().replaceFirst('Exception: ', '')),
          ),
        ),
      );
    }
  }

  Future<void> _deleteNotification(int index) async {
    final notification = _notifications[index];
    final id = notification['_id']?.toString();

    if (id == null || id.isEmpty) return;

    final wasUnread = notification['isRead'] != true;

    // Remove it immediately for a responsive UI.
    setState(() {
      _notifications.removeAt(index);
      if (wasUnread && _unreadCount > 0) _unreadCount--;
    });

    try {
      await _service.deleteNotification(id);
    } catch (e) {
      if (!mounted) return;

      // Restore the item if the deletion failed.
      setState(() {
        _notifications.insert(
          index.clamp(0, _notifications.length),
          notification,
        );
        if (wasUnread) _unreadCount++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text(
              context,
              'Could not delete notification: '
              '${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAll() async {
    if (_notifications.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xff333333) : Colors.white,
        title: Text(textRead(context, 'Delete all notifications?')),
        content: Text(
          textRead(
            context,
            'This will permanently delete all your notifications.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              textRead(context, 'Cancel'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xff333333),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              textRead(context, 'Delete all'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _service.deleteAllNotifications();

      if (!mounted) return;

      setState(() {
        _notifications.clear();
        _unreadCount = 0;
        _hasNextPage = false;
        _page = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text(context, 'All notifications deleted.'))),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text(context, e.toString().replaceFirst('Exception: ', '')),
          ),
        ),
      );
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _username(Map<String, dynamic> notification) {
    final sender = _asMap(notification['sender']);

    if (sender == null) {
      return 'Someone';
    }

    final username = sender['username']?.toString();

    if (username == null || username.isEmpty) {
      return 'Someone';
    }

    return username;
  }

  String _message(Map<String, dynamic> notification) {
    final username = _username(notification);

    switch (notification['type']?.toString()) {
      case 'like':
        return '$username liked your post.';

      case 'comment':
        return '$username commented on your post.';

      case 'follow':
        return '$username started following you.';

      case 'message':
        return '$username sent you a message.';

      default:
        return 'You received a notification.';
    }
  }

  IconData _notificationIcon(Map<String, dynamic> notification) {
    final type = (notification['type'] ?? '').toString().toLowerCase();

    if (type.contains('like')) return Icons.favorite_rounded;
    if (type.contains('comment') || type.contains('reply')) {
      return Icons.chat_bubble_rounded;
    }
    if (type.contains('follow')) return Icons.person_add_alt_1_rounded;
    if (type.contains('message')) return Icons.message_rounded;
    if (type.contains('group')) return Icons.groups_rounded;
    if (type.contains('mention')) return Icons.alternate_email_rounded;

    return Icons.notifications_rounded;
  }

  String _timeAgo(dynamic value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return '';

    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inSeconds < 60) {
      return textRead(context, 'Just now');
    }
    if (difference.inMinutes < 60) return '${difference.inMinutes}' + 'm ago';
    if (difference.inHours < 24) return '${difference.inHours}' + 'h ago';
    if (difference.inDays < 7) return '${difference.inDays}' + 'd ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff333333) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xff333333) : Colors.white,
        surfaceTintColor: isDark ? const Color(0xff333333) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Color(0xff333333),
            size: 26,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Text(
              text(context, 'Notifications'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_unreadCount',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xff333333),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white : Color(0xff333333),
              ),
              color: isDark ? const Color(0xff333333) : Colors.white,

              onSelected: (value) {
                if (value == 'read') _markAllAsRead();
                if (value == 'delete') _confirmDeleteAll();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(textRead(context, 'Mark all as read')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text(textRead(context, 'Delete all')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              Text(
                text(context, 'Could not load notifications'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadNotifications(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: isDark
                      ? Colors.white
                      : const Color(0xff333333),
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        color: accent,
        onRefresh: () => _loadNotifications(showLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 140),
            Icon(
              Icons.notifications_none_rounded,
              size: 76,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                text(context, 'You’re all caught up!'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                text(context, 'Your notifications will appear here.'),
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: accent,
      onRefresh: () => _loadNotifications(showLoading: false),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: accent)),
            );
          }

          final notification = _notifications[index];
          final sender = _asMap(notification['sender']);
          final profilePicture = sender?['profilePicture']?.toString() ?? '';
          final isRead = notification['isRead'] == true;

          return Dismissible(
            key: ValueKey(
              notification['_id']?.toString() ?? 'notification_$index',
            ),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.delete_outline,
                color: isDark ? Color(0xff333333) : Colors.white,
                size: 26,
              ),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: isDark
                          ? const Color(0xff333333)
                          : Colors.white,
                      title: Text(textRead(context, 'Delete notification?')),
                      content: Text(
                        textRead(
                          context,
                          'This notification will be permanently deleted.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(
                            textRead(context, 'Cancel'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Color(0xff333333),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(
                            textRead(context, 'Delete'),
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            },
            onDismissed: (_) => _deleteNotification(index),
            child: Material(
              color: isRead
                  ? isDark
                        ? Color(0xff444444)
                        : Colors.white
                  : isDark
                  ? Color(0xFF8A6800)
                  : const Color(0xfffff8dc),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _handleNotificationTap(index),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead
                          ? isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : Colors.black.withValues(alpha: 0.09)
                          : accent.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: isDark
                                ? const Color(0xFF444444)
                                : const Color(0xFFFFF2C2),
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : AssetImage(
                                        isDark
                                            ? 'assets/default_pfp_dark.png'
                                            : 'assets/default_pfp.jpg',
                                      )
                                      as ImageProvider,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 23,
                              height: 23,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xff333333)
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _notificationIcon(notification),
                                size: 12,
                                color: isDark
                                    ? Colors.white
                                    : Color(0xff333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text(context, _message(notification)),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              text(
                                context,
                                _timeAgo(notification['createdAt']),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      IconButton(
                        tooltip: textRead(context, 'Delete notification'),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _deleteNotification(index),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
