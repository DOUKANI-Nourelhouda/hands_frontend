import 'package:flutter/material.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/services/user_service.dart';
import 'package:hands/services/profile_service.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/utils/langs.dart';

class FollowersFollowingPage extends StatefulWidget {
  final PostService postService;
  final String userId;
  final Future<void> Function(String recipientId)? onMessageTap;
  const FollowersFollowingPage({
    super.key,
    required this.postService,
    required this.userId,
    this.onMessageTap,
  });

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final ProfileService _profileService = ProfileService();

  late final TabController _tabController;

  List<dynamic> _followers = [];
  List<dynamic> _following = [];

  bool _isLoading = true;
  String? _error;

  static const Color _yellow = Color(0xfffcc001);
  static const Color _textColor = Color(0xff333333);
  static const Color _red = Color(0xffe53935);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _idOf(dynamic user) {
    if (user is! Map) return '';
    return (user['_id'] ?? user['id'] ?? '').toString();
  }

  String _usernameOf(dynamic user) {
    if (user is! Map) return 'Unknown user';
    return (user['username'] ?? user['name'] ?? 'Unknown user').toString();
  }

  String _bioOf(dynamic user) {
    if (user is! Map) return '';
    return (user['bio'] ?? '').toString();
  }

  String _pictureOf(dynamic user) {
    if (user is! Map) return '';
    return (user['profilePicture'] ?? user['profilePictureUrl'] ?? '')
        .toString();
  }

  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        _userService.getFollowers(widget.userId),
        _userService.getFollowing(widget.userId),
      ]);

      if (!mounted) return;

      setState(() {
        _followers = List<dynamic>.from(results[0]['followers'] ?? []);
        _following = List<dynamic>.from(results[1]['following'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _removeUser({
    required dynamic user,
    required bool isFollower,
  }) async {
    final userId = _idOf(user);
    if (userId.isEmpty) {
      _showMessage('Could not identify this user.');
      return;
    }

    final username = _usernameOf(user);
    final action = isFollower
        ? textRead(context, 'remove') +
              ' $username ' +
              textRead(context, 'from your followers?')
        : textRead(context, 'unfollow') + ' $username ';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isFollower
              ? textRead(context, 'Remove follower?')
              : textRead(context, 'Unfollow user?'),
        ),
        content: Text(
          textRead(context, 'Are you sure you want to') +
              textRead(context, '$action'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              textRead(context, 'Cancel'),
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF333333),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              textRead(context, 'Remove'),
              style: TextStyle(color: _red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      if (isFollower) {
        await _userService.removeFollower(userId);
      } else {
        await _profileService.unfollowUser(userId);
      }

      if (!mounted) return;

      setState(() {
        if (isFollower) {
          _followers.removeWhere((item) => _idOf(item) == userId);
        } else {
          _following.removeWhere((item) => _idOf(item) == userId);
        }
      });

      _showMessage(
        isFollower
            ? textRead(context, 'Follower removed.')
            : textRead(context, 'User unfollowed.'),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(textRead(context, message))));
  }

  Widget _buildUserCard(dynamic user, {required bool isFollower}) {
    final username = _usernameOf(user);
    final bio = _bioOf(user);
    final profilePicture = _pictureOf(user);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF333333) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Color(0xFF444444) : const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFFFFF2C2),
          backgroundImage: profilePicture.isNotEmpty
              ? NetworkImage(profilePicture)
              : AssetImage(
                      isDark
                          ? 'assets/default_pfp_dark.png'
                          : 'assets/default_pfp.jpg',
                    )
                    as ImageProvider,
        ),
        title: Text(
          text(context, username),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Color(0xFF333333),
          ),
        ),
        subtitle: bio.isNotEmpty
            ? Text(
                text(context, bio),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          tooltip: isFollower ? 'Remove follower' : 'Unfollow',
          onPressed: () => _removeUser(user: user, isFollower: isFollower),
          icon: const Icon(Icons.remove_circle, color: _red, size: 27),
        ),

        onTap: () {
          final selectedUserId = _idOf(user);

          if (selectedUserId.isEmpty) {
            _showMessage('Could not identify this user.');
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(
                userId: selectedUserId,
                postService: widget.postService,
                onMessageTap: (recipientId) async {
                  Navigator.pop(context);
                  await widget.onMessageTap?.call(recipientId);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> users, {required bool isFollower}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _yellow));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text(context, _error!), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadUsers,
                child: Text(text(context, 'Try again')),
              ),
            ],
          ),
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              isFollower
                  ? text(context, 'You don’t have any followers yet.')
                  : text(context, 'You aren’t following anyone yet.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _yellow,
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: users.length,
        itemBuilder: (context, index) =>
            _buildUserCard(users[index], isFollower: isFollower),
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
        surfaceTintColor: isDark ? Color(0xFF333333) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 27,
            color: isDark ? Colors.white : Color(0xff333333),
          ),
        ),

        title: Text(
          text(context, 'Followers & Following'),
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.white : Color(0xFF333333),
          unselectedLabelColor: Colors.grey,
          indicatorColor: _yellow,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: text(context, 'Followers') + '(${_followers.length})'),
            Tab(text: text(context, 'Following') + '(${_following.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_followers, isFollower: true),
          _buildList(_following, isFollower: false),
        ],
      ),
    );
  }
}
