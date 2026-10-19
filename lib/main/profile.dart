import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/services/profile_service.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCreditsTap;

  const ProfilePage({
    super.key,
    this.userId,
    this.onSettingsTap,
    this.onCreditsTap,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color yellow = Color(0xfffcc001);
  final AuthService _authService = AuthService();

  PostService? _postService;
  String _currentUserId = '';
  final ProfileService _profileService = ProfileService();
  String? currentUserId;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _posts = [];
  bool _isFollowing = false;
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  bool _isFollowLoading = false;
  String? _error;

  bool get _isOwnProfile =>
      widget.userId == null ||
      widget.userId!.isEmpty ||
      widget.userId == _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializePostService();
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _user = null;
      _posts = [];
    });

    try {
      // Get the logged-in user's profile first.
      final myProfile = await _profileService.getMyProfile();

      final currentUser = myProfile['user'] is Map
          ? Map<String, dynamic>.from(myProfile['user'])
          : myProfile;

      _currentUserId = (currentUser['_id'] ?? currentUser['id'] ?? '')
          .toString();

      final requestedId = widget.userId;

      if (requestedId == null ||
          requestedId.isEmpty ||
          requestedId == _currentUserId) {
        _user = currentUser;
        _isFollowing = false;
      } else {
        final result = await _profileService.getUserProfile(requestedId);

        _user = Map<String, dynamic>.from(result['user'] as Map);
        _isFollowing = result['isFollowing'] == true;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      await _loadPosts();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadPosts() async {
    final profileId = (_user?['_id'] ?? _user?['id'] ?? '').toString();

    if (!_isOwnProfile && profileId.isEmpty) return;

    setState(() => _isLoadingPosts = true);

    try {
      final result = await _profileService.getProfilePosts(
        userId: _isOwnProfile ? null : profileId,
        page: 1,
        limit: 30,
      );

      final rawPosts = result['posts'];

      if (!mounted) return;

      setState(() {
        _posts = rawPosts is List
            ? rawPosts
                  .whereType<Map>()
                  .map((post) => Map<String, dynamic>.from(post))
                  .toList()
            : [];
        _isLoadingPosts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _toggleFollow() async {
    final userId = (_user?['_id'] ?? _user?['id'] ?? '').toString();

    if (userId.isEmpty || _isFollowLoading) return;

    setState(() => _isFollowLoading = true);

    try {
      if (_isFollowing) {
        await _profileService.unfollowUser(userId);
      } else {
        await _profileService.followUser(userId);
      }

      if (!mounted) return;

      setState(() {
        _isFollowing = !_isFollowing;

        final followers = _user?['followers'];
        if (followers is List) {
          if (_isFollowing) {
            followers.add(_currentUserId);
          } else {
            followers.remove(_currentUserId);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  int _count(String key, {String? fallbackKey}) {
    final value = _user?[key];

    if (value is List) return value.length;
    if (value is num) return value.toInt();

    if (fallbackKey != null) {
      final fallback = _user?[fallbackKey];
      if (fallback is num) return fallback.toInt();
    }

    return 0;
  }

  Future<void> _initializePostService() async {
    final token = await _authService.getSavedToken();

    if (token == null || token.isEmpty) return;

    final userData = await _authService.getCurrentUser();

    final user = userData['user'] is Map
        ? Map<String, dynamic>.from(userData['user'])
        : userData;

    if (!mounted) return;

    setState(() {
      _postService = PostService(baseUrl: AuthService.baseUrl, token: token);

      _currentUserId = (user['_id'] ?? user['id'] ?? '').toString();
    });
  }

  void _showProfileOptions() {
    final bool isOwnProfile =
        widget.userId == null || widget.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isOwnProfile ? 'Settings' : 'Profile options',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (isOwnProfile) ...[
                  _optionTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open EditProfilePage
                    },
                  ),
                  _optionTile(
                    icon: Icons.people_outline,
                    title: 'Followers & following',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open FollowersFollowingPage
                    },
                  ),
                  _optionTile(
                    icon: Icons.block_outlined,
                    title: 'Blocked accounts',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open BlockedUsersPage
                    },
                  ),
                  _optionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open notification settings
                    },
                  ),
                  _optionTile(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open language settings
                    },
                  ),
                  _optionTile(
                    icon: Icons.post_add_outlined,
                    title: 'Post credits',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      widget.onCreditsTap?.call();
                    },
                  ),
                  _optionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open PrivacyPolicyPage or a policy URL
                    },
                  ),
                  _optionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open TermsPage or a terms URL
                    },
                  ),
                  _optionTile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open HelpSupportPage
                    },
                  ),
                  const Divider(height: 20),
                  _optionTile(
                    icon: Icons.logout,
                    title: 'Log out',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Confirm logout, clear token, then navigate to login
                    },
                  ),
                  _optionTile(
                    icon: Icons.delete_outline,
                    title: 'Delete account',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Confirm deletion and call your backend
                    },
                  ),
                ] else ...[
                  _optionTile(
                    icon: Icons.message_outlined,
                    title: 'Send message',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open or create a direct conversation
                    },
                  ),
                  _optionTile(
                    icon: Icons.person_add_alt_1,
                    title: 'Follow / Unfollow',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Call your follow/unfollow service
                    },
                  ),
                  _optionTile(
                    icon: Icons.person_remove_outlined,
                    title: 'Remove from followers',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Remove this student from your followers
                    },
                  ),
                  _optionTile(
                    icon: Icons.block,
                    title: 'Block account',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Confirm and call your block service
                    },
                  ),
                  _optionTile(
                    icon: Icons.flag_outlined,
                    title: 'Report account',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Open report dialog and submit the report
                    },
                  ),
                  _optionTile(
                    icon: Icons.share_outlined,
                    title: 'Share profile',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      // TODO: Share a profile link
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: yellow))
            : _error != null
            ? _buildError()
            : _buildProfile(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final user = _user ?? {};
    final username = user['username']?.toString() ?? 'Student';
    final bio = user['bio']?.toString() ?? '';
    final picture = user['profilePicture']?.toString() ?? '';

    final residence = user['residence'];
    final residenceName = residence is Map
        ? residence['name']?.toString() ?? 'My residence'
        : 'My residence';

    final wilaya = residence is Map ? residence['wilaya']?.toString() : null;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 5, 5),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xff333333),
                  size: 26,
                ),
              ),
              const Spacer(),
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xff333333),
                ),
              ),
              const Spacer(),

              IconButton(
                onPressed: _showProfileOptions,
                icon: const Icon(Icons.menu),
                tooltip: 'Settings',
              ),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            color: yellow,
            onRefresh: _loadProfile,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + user information
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: yellow,
                              ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: const Color(0xFFFFF2C2),
                                backgroundImage: picture.isNotEmpty
                                    ? NetworkImage(picture)
                                    : const AssetImage('assets/default_pfp.jpg')
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff333333),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/location.svg',
                                          width: 16,
                                          height: 16,
                                          colorFilter: const ColorFilter.mode(
                                            yellow,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            wilaya == null || wilaya.isEmpty
                                                ? residenceName
                                                : '$residenceName, $wilaya',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (bio.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            bio,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xff333333),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Statistics
                        Row(
                          children: [
                            _stat('Posts', _posts.length),
                            _stat('Following', _count('following')),
                            _stat(
                              'Followers',
                              _count(
                                'followers',
                                fallbackKey: 'followersCount',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Own profile: credits.
                        // Other profile: follow/unfollow.
                        if (_isOwnProfile)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Material(
                              color: const Color(0xfffcc001),
                              borderRadius: BorderRadius.circular(13),
                              child: InkWell(
                                onTap: widget.onCreditsTap,
                                borderRadius: BorderRadius.circular(13),
                                child: const Center(
                                  child: Text(
                                    'Post Credits',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _isFollowLoading
                                  ? null
                                  : _toggleFollow,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _isFollowing
                                    ? Colors.white
                                    : yellow,
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                  color: yellow,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isFollowLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: yellow,
                                      ),
                                    )
                                  : Text(
                                      _isFollowing ? 'Followed' : 'Follow',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        const Text(
                          'Posts',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),

                if (_isLoadingPosts)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: CircularProgressIndicator(color: yellow),
                      ),
                    ),
                  )
                else if (_posts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No posts yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else if (_postService == null || _currentUserId.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xfffcc001),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 10,
                    ),
                    sliver: _buildPostsFeed(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPostsFeed() {
    if (_posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No posts yet.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = _posts[index];
        final postId = (post['_id'] ?? post['id'] ?? '').toString();

        return PostWidget(
          key: ValueKey(postId),
          post: post,
          postService: _postService!,
          currentUserId: _currentUserId,

          onPostReported: (reportedPostId) {
            if (!mounted) return;

            setState(() {
              _posts.removeWhere(
                (item) =>
                    (item['_id'] ?? item['id'])?.toString() == reportedPostId,
              );
            });
          },

          onPostUpdated: (updatedPost) {
            if (!mounted) return;

            setState(() {
              final index = _posts.indexWhere(
                (item) =>
                    (item['_id'] ?? item['id'])?.toString() ==
                    (updatedPost['_id'] ?? updatedPost['id'])?.toString(),
              );

              if (index != -1) {
                _posts[index] = updatedPost;
              }
            });
          },
        );
      }, childCount: _posts.length),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
