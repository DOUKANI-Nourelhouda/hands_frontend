import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/main/settings/blocklist.dart';
import 'package:hands/main/settings/editprofile.dart';
import 'package:hands/main/settings/followers&followings.dart';
import 'package:hands/main/settings/privacy.dart';
import 'package:hands/services/profile_service.dart';
import 'package:hands/splash/welcome_screen.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/main/settings/terms.dart';
import 'package:hands/main/settings/help&support.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hands/services/user_service.dart';
import 'package:hands/services/payment_service.dart';
import 'package:hands/main/post_credits.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCreditsTap;
  final PostService postService;
  const ProfilePage({
    super.key,
    this.userId,
    this.onSettingsTap,
    this.onCreditsTap,
    required this.postService,
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

  Future<void> _shareProfile() async {
    final username = (_user?['username'] ?? '').toString();
    final profileId = (_user?['_id'] ?? _user?['id'] ?? '').toString();

    if (username.isEmpty || profileId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share this profile.')),
      );
      return;
    }

    final baseUrl = dotenv.env['BASE_URL']?.replaceAll(RegExp(r'/+$'), '');

    if (baseUrl == null || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile link is unavailable.')),
      );
      return;
    }

    final profileLink = '$baseUrl/user/$profileId';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out @$username on Hands!\n$profileLink',
          subject: 'Check out @$username on Hands',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not share profile: $e')));
    }
  }

  Future<bool> _showBlockUserDialog(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Block user?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to block $username? '
            'Their posts will no longer appear in your feed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<bool?> _showReportUserDialog() async {
    final detailsController = TextEditingController();

    const reasons = <String, String>{
      'inappropriate': 'Inappropriate profile or content',
      'scam': 'Scam or fraud',
      'spam': 'Spam or fake account',
      'harassment': 'Harassment or bullying',
      'impersonation': 'Pretending to be someone else',
      'other': 'Other',
    };

    String selectedReason = 'inappropriate';
    bool isSubmitting = false;
    String? errorMessage;

    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Report user',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why are you reporting this user?',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    ...reasons.entries.map((entry) {
                      return RadioListTile<String>(
                        value: entry.key,
                        groupValue: selectedReason,
                        activeColor: const Color(0xfffcc001),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                if (value == null) return;

                                setDialogState(() {
                                  selectedReason = value;
                                  errorMessage = null;
                                });
                              },
                      );
                    }),

                    const SizedBox(height: 12),

                    TextField(
                      controller: detailsController,
                      maxLength: 500,
                      maxLines: 6,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'Additional details (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xfffcc001),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffcc001),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.amber.shade200,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() {
                            isSubmitting = true;
                            errorMessage = null;
                          });

                          try {
                            final reportedUserId =
                                (_user?['_id'] ?? _user?['id'] ?? '')
                                    .toString();

                            if (reportedUserId.isEmpty ||
                                reportedUserId == _currentUserId) {
                              throw Exception('Invalid user to report.');
                            }

                            final token = await _authService.getSavedToken();

                            if (token == null || token.isEmpty) {
                              throw Exception(
                                'Please log in again to report this user.',
                              );
                            }

                            await _profileService.reportUser(
                              baseUrl: dotenv.env['BASE_URL']!,
                              token: token,
                              userId: reportedUserId,
                              reason: selectedReason,
                              details: detailsController.text.trim(),
                            );
                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isSubmitting = false;
                              errorMessage = e is PostException
                                  ? e.message
                                  : 'Could not submit report. Please try again.';
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Submit report'),
                ),
              ],
            );
          },
        );
      },
    );

    detailsController.dispose();

    if (!mounted || submitted != true) return false;

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text('User reported successfully.')),
    );

    return true;
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

  String _selectedLanguage = 'English';

  void _showLanguageDialog(BuildContext context) {
    String tempLanguage = _selectedLanguage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Choose a language',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff333333),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['English', 'Français', 'العربية'].map((language) {
                  final selected = tempLanguage == language;

                  return RadioListTile<String>(
                    value: language,
                    groupValue: tempLanguage,
                    activeColor: const Color(0xfffcc001),
                    title: Text(language),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => tempLanguage = value);
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfffcc001),
                      foregroundColor: const Color(0xff333333),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedLanguage = tempLanguage;
                      });

                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _selectedDisplayMode = 'System';

  void _showDisplayModeDialog(BuildContext context) {
    String tempMode = _selectedDisplayMode;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Choose display mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff333333),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _modeOption(
                    title: 'Light',
                    icon: Icons.light_mode_outlined,
                    selected: tempMode == 'Light',
                    onTap: () => setDialogState(() => tempMode = 'Light'),
                  ),
                  _modeOption(
                    title: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    selected: tempMode == 'Dark',
                    onTap: () => setDialogState(() => tempMode = 'Dark'),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfffcc001),
                      foregroundColor: const Color(0xff333333),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDisplayMode = tempMode;
                      });

                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _modeOption({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? const Color(0xffc99700) : Colors.grey,
      ),
      title: Text(title),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Color(0xfffcc001))
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfilePage(postService: widget.postService),
                        ),
                      );
                    },
                  ),
                  _optionTile(
                    svgPath: 'assets/icons/groups.svg',

                    title: 'Followers & following',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowersFollowingPage(
                            postService: widget.postService,
                            userId: _currentUserId,
                          ),
                        ),
                      );
                    },
                  ),

                  _optionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Open notification settings
                    },
                  ),
                  _optionTile(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                  ),
                  _optionTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Mode',
                    onTap: () {
                      _showDisplayModeDialog(context);
                    },
                  ),

                  _optionTile(
                    icon: Icons.block_outlined,
                    title: 'Blocked accounts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BlockedUsersPage()),
                      );
                    },
                  ),
                  _optionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
                      );
                    },
                  ),
                  _optionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: () {
                      Navigator.pop(sheetContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsPage()),
                      );
                    },
                  ),

                  _optionTile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () {
                      Navigator.pop(sheetContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportPage(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 20),

                  _optionTile(
                    icon: Icons.logout,
                    title: 'Log out',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              24,
                              24,
                              24,
                              12,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  'Log out?',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1e1f24),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  'Are you sure you want to log out of your '
                                  'Hands account?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            actionsPadding: const EdgeInsets.fromLTRB(
                              20,
                              12,
                              20,
                              20,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xff1e1f24,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xff333333),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);

                                        try {
                                          await AuthService().logout();

                                          if (!context.mounted) return;

                                          Navigator.of(
                                            context,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WelcomeScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        } catch (e) {
                                          debugPrint('Logout error: $e');

                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to log out. Please try again.',
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Log out'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  _optionTile(
                    icon: Icons.delete_outline,
                    title: 'Delete account',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(sheetContext);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) {
                          bool isDeleting = false;

                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  12,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.red,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    const Text(
                                      'Delete account?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1e1f24),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    const Text(
                                      'Are you sure you want to permanently '
                                      'delete your Hands account? This action '
                                      'cannot be undone.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    const Text(
                                      'Your account and associated data may be '
                                      'deleted according to our data retention policy.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                actionsPadding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  20,
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: isDeleting
                                              ? null
                                              : () {
                                                  Navigator.pop(dialogContext);
                                                },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xff1e1f24,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 13,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color(0xff333333),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isDeleting
                                              ? null
                                              : () async {
                                                  setDialogState(() {
                                                    isDeleting = true;
                                                  });

                                                  try {
                                                    final result =
                                                        await AuthService()
                                                            .deleteAccount();

                                                    if (!dialogContext.mounted)
                                                      return;

                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop();

                                                    if (!context.mounted)
                                                      return;

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          result['message'] ??
                                                              'Account deleted successfully.',
                                                        ),
                                                      ),
                                                    );

                                                    Navigator.of(
                                                      context,
                                                    ).pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const WelcomeScreen(),
                                                      ),
                                                      (route) => false,
                                                    );
                                                  } catch (e) {
                                                    debugPrint(
                                                      'Delete account error: $e',
                                                    );

                                                    if (!dialogContext
                                                        .mounted) {
                                                      return;
                                                    }

                                                    setDialogState(() {
                                                      isDeleting = false;
                                                    });

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Failed to delete account. '
                                                          'Please try again.',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.red
                                                .withValues(alpha: 0.5),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 13,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isDeleting
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
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
                    icon: Icons.share_outlined,
                    title: 'Share profile',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareProfile();
                    },
                  ),
                  _optionTile(
                    icon: Icons.block,
                    title: 'Block account',
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      final username = (_user?['username'] ?? 'this user')
                          .toString();
                      final userId = (_user?['_id'] ?? _user?['id'] ?? '')
                          .toString();

                      if (userId.isEmpty || userId == _currentUserId) {
                        return;
                      }

                      final confirmed = await _showBlockUserDialog(username);

                      if (!confirmed || !mounted) return;

                      try {
                        // Replace UserService() with your existing service instance
                        // if it is already declared in this class.
                        await UserService().blockUser(userId);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$username has been blocked.'),
                          ),
                        );

                        // If this is another user's profile, return to the previous page.
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not block user: ${e.toString().replaceFirst('Exception: ', '')}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _optionTile(
                    icon: Icons.flag_outlined,
                    title: 'Report account',
                    color: Colors.red,
                    onTap: () {
                      _showReportUserDialog();
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostCreditsPage(
                                        onBuyPackage: (packageId) async {
                                          final result = await PaymentService()
                                              .createPostPackagePayment(
                                                packageId: packageId,
                                              );

                                          debugPrint(
                                            'PAYMENT RESPONSE: $result',
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
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
    IconData? icon,
    String? svgPath,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: svgPath != null
          ? SvgPicture.asset(svgPath, width: 24, height: 24)
          : Icon(icon, color: color),
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
