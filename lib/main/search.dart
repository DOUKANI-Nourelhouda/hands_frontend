import 'package:flutter/material.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/services/user_service.dart';
import 'dart:async';
import 'package:hands/services/group_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/main/group_chat_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hands/utils/langs.dart';

class SearchPage extends StatefulWidget {
  final PostService postService;
  final IO.Socket socket;
  final Future<void> Function(String recipientId)? onMessageTap;
  const SearchPage({
    super.key,
    required this.postService,
    required this.socket,
    this.onMessageTap,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> searchResults = [];

  Timer? _searchDebounce;
  int _searchRequestId = 0;
  GroupService? _groupService;

  bool isLoadingGroups = true;
  String? groupsError;
  bool isSearching = false;
  String? searchErrorMessage;
  static const Color accent = Color(0xfffcc001);
  static const Color textColor = Color(0xff333333);

  final TextEditingController _searchController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String selectedFilter = 'Posts';
  String searchQuery = '';

  bool isLoading = true;
  String? errorMessage;
  bool isLoadingFollowing = false;
  String? followingError;
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> groups = [];

  String currentUserId = '';

  final List<Map<String, String>> filters = const [
    {'name': 'Posts', 'icon': 'assets/icons/posts.svg'},
    {'name': 'Users', 'icon': 'assets/icons/user.svg'},
    {'name': 'Groups', 'icon': 'assets/icons/groups.svg'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSearch();
    _initializeGroups();
  }

  Future<void> _initializeGroups() async {
    try {
      final token = await _authService.getSavedToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again.');
      }

      final service = GroupService(
        baseUrl: dotenv.env['BASE_URL']!,
        token: token,
      );

      if (!mounted) return;

      _groupService = service;

      await _loadGroups();
    } catch (e, stackTrace) {
      debugPrint('[SEARCH GROUPS INIT ERROR] $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        groupsError = e.toString();
        isLoadingGroups = false;
      });
    }
  }

  Future<void> _loadGroups() async {
    final service = _groupService;

    if (service == null) {
      return;
    }

    setState(() {
      isLoadingGroups = true;
      groupsError = null;
    });

    try {
      final fetchedGroups = await service.getGroups();

      if (!mounted) return;

      setState(() {
        groups = fetchedGroups;
      });

      debugPrint('[SEARCH GROUPS] Loaded ${groups.length} groups');
    } catch (e, stackTrace) {
      debugPrint('[SEARCH GROUPS ERROR] $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        groupsError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingGroups = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchRequestId++;

    _searchController.dispose();

    super.dispose();
  }

  Future<void> _initializeSearch() async {
    await _loadCurrentUser();
    await _loadPosts();
    await _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    if (currentUserId.isEmpty) {
      debugPrint('[FOLLOWING] Current user ID is empty.');

      if (mounted) {
        setState(() {
          isLoadingFollowing = false;
          followingError = 'Could not identify your account.';
        });
      }
      return;
    }

    setState(() {
      isLoadingFollowing = true;
      followingError = null;
    });

    try {
      debugPrint('[FOLLOWING] Loading accounts for $currentUserId');

      final result = await _userService.getFollowing(currentUserId);

      debugPrint('[FOLLOWING] API response: $result');

      final rawFollowing = result['following'];

      final fetchedUsers = rawFollowing is List
          ? rawFollowing
                .whereType<Map>()
                .map((user) => Map<String, dynamic>.from(user))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        users = fetchedUsers;
        isLoadingFollowing = false;
      });

      debugPrint('[FOLLOWING] Loaded ${fetchedUsers.length} accounts.');
    } catch (e, stackTrace) {
      debugPrint('[FOLLOWING ERROR] $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoadingFollowing = false;
        followingError = 'Could not load the accounts you follow.';
      });
    }
  }

  Future<void> _searchUsers(String query, int requestId) async {
    if (query.trim().isEmpty) return;

    debugPrint('[USER SEARCH] Searching for: $query');

    try {
      final result = await _userService.searchUsers(
        query: query,
        page: 1,
        limit: 20,
      );

      debugPrint('[USER SEARCH] API response: $result');

      final rawUsers = result['users'];

      final matchingUsers = rawUsers is List
          ? rawUsers
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted ||
          requestId != _searchRequestId ||
          selectedFilter != 'Users' ||
          searchQuery != query.toLowerCase()) {
        return;
      }

      setState(() {
        users = matchingUsers;
        isSearching = false;
        searchErrorMessage = null;
      });

      debugPrint('[USER SEARCH] Found ${matchingUsers.length} users');
    } catch (e, stackTrace) {
      debugPrint('[USER SEARCH ERROR] $e');
      debugPrint('$stackTrace');

      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        isSearching = false;
        searchErrorMessage = 'Could not search students. Please try again.';
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();

      final user = userData['user'] is Map
          ? Map<String, dynamic>.from(userData['user'])
          : userData;

      if (!mounted) return;

      setState(() {
        currentUserId = (user['_id'] ?? user['id'] ?? '').toString();
      });
    } catch (e) {
      debugPrint('Could not load current user: $e');
    }
  }

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await widget.postService.getPosts(page: 1, limit: 50);

      final rawPosts = result['posts'] as List<dynamic>? ?? [];

      if (!mounted) return;

      setState(() {
        posts = rawPosts
            .whereType<Map>()
            .map((post) => Map<String, dynamic>.from(post))
            .toList();

        isLoading = false;
      });
    } on PostException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load posts. Please try again.';
        isLoading = false;
      });

      debugPrint('Search posts error: $e');
    }
  }

  List<Map<String, dynamic>> get filteredPosts {
    return searchQuery.isEmpty ? posts : searchResults;
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    _searchDebounce?.cancel();
    final requestId = ++_searchRequestId;

    setState(() {
      searchQuery = query.toLowerCase();
      searchResults = [];
      searchErrorMessage = null;
      isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      if (selectedFilter == 'Users') {
        _loadFollowing();
      } else {
        setState(() {
          isSearching = false;
        });
      }
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (selectedFilter == 'Users') {
        _searchUsers(query, requestId);
      } else if (selectedFilter == 'Posts') {
        _searchPosts(query, requestId);
      } else {
        if (!mounted || requestId != _searchRequestId) return;
        setState(() {
          isSearching = false;
        });
      }
    });
  }

  Future<void> _searchPosts(String query, int requestId) async {
    try {
      final result = await widget.postService.searchPosts(
        query: query,
        page: 1,
        limit: 50,
      );

      final rawPosts = result['posts'] as List<dynamic>? ?? [];

      final matchingPosts = rawPosts
          .whereType<Map>()
          .map((post) => Map<String, dynamic>.from(post))
          .toList();

      if (!mounted ||
          requestId != _searchRequestId ||
          searchQuery != query.toLowerCase()) {
        return;
      }

      setState(() {
        searchResults = matchingPosts;
        isSearching = false;
        searchErrorMessage = null;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        isSearching = false;
        searchErrorMessage = 'Search failed. Please try again.';
      });

      debugPrint('Backend search error: $e');
    }
  }

  void _selectFilter(String filter) {
    FocusScope.of(context).unfocus();

    if (selectedFilter == filter) return;

    _searchDebounce?.cancel();
    final requestId = ++_searchRequestId;

    setState(() {
      selectedFilter = filter;
      searchResults = [];
      searchErrorMessage = null;
      isSearching = false;
    });

    final query = searchQuery.trim();

    if (filter == 'Users' && query.isEmpty) {
      _loadFollowing();
      return;
    }

    if (query.isEmpty) return;

    setState(() {
      isSearching = filter == 'Posts' || filter == 'Users';
    });

    _searchDebounce = Timer(const Duration(milliseconds: 100), () {
      if (filter == 'Users') {
        _searchUsers(query, requestId);
      } else if (filter == 'Posts') {
        _searchPosts(query, requestId);
      } else {
        if (!mounted || requestId != _searchRequestId) return;
        setState(() => isSearching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),

            const SizedBox(height: 16),

            // Fixed horizontal filter chips
            _buildFilterRow(),

            const SizedBox(height: 12),

            // Only the results scroll
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
      child: Row(
        children: [
          // Back arrow
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : textColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 4),

          // Search bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF444444) : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isDark ? Colors.grey : Color(0xFFEEEEEE),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: isDark ? Colors.white : Color(0xff333333),
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: text(context, 'Search ...'),
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey : Color(0xff8E92A0),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.grey : Color(0xff8E92A0),
                    size: 22,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xff8E92A0),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['name'];

          return GestureDetector(
            onTap: () => _selectFilter(filter['name']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent
                    : isDark
                    ? Color(0xFF444444)
                    : Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accent
                      : isDark
                      ? Colors.grey
                      : const Color(0xFFEEEEEE),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterIcon(
                    filter['name']!,
                    filter['icon']!,
                    isSelected,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    text(context, filter['name']!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? isDark
                                ? textColor
                                : Colors.white
                          : textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterIcon(String name, String assetPath, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      assetPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        isSelected
            ? isDark
                  ? textColor
                  : Colors.white
            : textColor,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildResults() {
    if (selectedFilter == 'Posts') {
      return _buildPostResults();
    }

    if (selectedFilter == 'Users') {
      return _buildUserResults();
    }

    return _buildGroupResults();
  }

  Widget _buildPostResults() {
    if (searchQuery.isNotEmpty && isSearching) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    if (searchQuery.isNotEmpty && searchErrorMessage != null) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/no_wifi.svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: searchErrorMessage!,
      );
    }

    if (searchQuery.isEmpty && isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    if (searchQuery.isEmpty && errorMessage != null && posts.isEmpty) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/no_wifi.svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: errorMessage!,
        showRetry: true,
      );
    }

    final results = filteredPosts;

    if (results.isEmpty) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/posts.svg',
          width: 80,
          height: 80,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: searchQuery.isEmpty
            ? textRead(context, 'No posts yet.')
            : textRead(context, 'No posts found for ') + "$searchQuery",
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      color: accent,
      onRefresh: searchQuery.isEmpty
          ? _loadPosts
          : () async {
              _searchDebounce?.cancel();
              final requestId = ++_searchRequestId;

              setState(() {
                isSearching = true;
                searchErrorMessage = null;
              });

              await _searchPosts(searchQuery, requestId);
            },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final post = results[index];

          return PostWidget(
            key: ValueKey(post['_id'] ?? index),
            post: post,
            postService: widget.postService,
            currentUserId: currentUserId,
            searchQuery: searchQuery,
          );
        },
      ),
    );
  }

  Widget _buildUserResults() {
    if (searchQuery.trim().isNotEmpty && isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (searchErrorMessage != null && searchQuery.trim().isNotEmpty) {
      return Center(child: Text(text(context, searchErrorMessage!)));
    }

    // No query: show the accounts the user follows
    if (searchQuery.trim().isEmpty && isLoadingFollowing) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (searchQuery.trim().isEmpty && followingError != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text(context, followingError!)),
            TextButton(
              onPressed: _loadFollowing,
              child: Text(
                text(context, 'Try again'),
                style: TextStyle(color: Color(0xfffcc001)),
              ),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/user.svg',
          width: 52,
          height: 52,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: searchQuery.trim().isEmpty
            ? textRead(context, 'You are not following anyone yet.')
            : textRead(context, 'No users found.'),
        subtitle: searchQuery.trim().isEmpty
            ? textRead(context, 'Follow users to see them here.')
            : textRead(context, 'Try searching for another username.'),
      );
    }

    // Keep your existing user-card ListView.builder here.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final username = user['username']?.toString() ?? 'Student';
        final bio = user['bio']?.toString() ?? '';
        final profilePicture = user['profilePicture']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF444444) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Color(0xFF444444) : Color(0xFFF0F0F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFF000000).withValues(alpha: 0.07),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFFFF2C2),
              backgroundImage: profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : AssetImage(
                          isDark
                              ? 'assets/default_pfp_dark.png'
                              : 'assets/default_pfp.jpg',
                        )
                        as ImageProvider,
            ),
            title: _highlightSearchText(
              context,
              username,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Color(0xFF333333),
              ),
            ),
            subtitle: bio.isNotEmpty
                ? _highlightSearchText(
                    context,
                    bio,
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF333333),
                    ),
                    maxLines: 2,
                  )
                : null,

            onTap: () {
              final selectedUserId = (user['_id'] ?? user['id'] ?? '')
                  .toString();

              if (selectedUserId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      text(context, 'Could not open this profile.'),
                    ),
                  ),
                );
                return;
              }

              debugPrint('[SEARCH] Opening profile: $selectedUserId');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    userId: selectedUserId,
                    postService: widget.postService,
                    onMessageTap: (recipientId) async {
                      debugPrint('[SEARCH] Opening direct chat: $recipientId');

                      await widget.onMessageTap?.call(recipientId);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoadingGroups && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    if (groupsError != null && groups.isEmpty) {
      return _buildMessage(
        icon: const Icon(
          Icons.error_outline_rounded,
          size: 60,
          color: Color(0xffC4C4C4),
        ),
        message: textRead(context, 'Could not load your groups.'),
        subtitle: textRead(context, 'Check your connection and try again.'),
        showRetry: true,
      );
    }

    final query = searchQuery.trim().toLowerCase();

    final results = groups.where((group) {
      final name = (group['name'] ?? '').toString().toLowerCase();
      final description = (group['description'] ?? '').toString().toLowerCase();

      return query.isEmpty ||
          name.contains(query) ||
          description.contains(query);
    }).toList();

    if (results.isEmpty) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/groups.svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: query.isEmpty
            ? textRead(context, 'You have not joined any groups yet.')
            : textRead(context, 'No groups found.'),
        subtitle: query.isEmpty
            ? textRead(context, 'Groups you join will appear here.')
            : textRead(context, 'Try searching for another group.'),
      );
    }

    return RefreshIndicator(
      color: accent,
      onRefresh: _loadGroups,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final group = results[index];

          final groupId = (group['_id'] ?? group['id'] ?? '').toString();
          final groupName = (group['name'] ?? 'Student group').toString();
          final description = (group['description'] ?? '').toString();

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF444444) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Color(0xFF444444) : Color(0xFFF0F0F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : const Color(0xFF000000).withValues(alpha: 0.07),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: accent.withValues(alpha: 0.22),
                child: ClipOval(
                  child: Image.asset(
                    isDark
                        ? 'assets/default_grp_dark.png'
                        : 'assets/default_grp.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: _highlightSearchText(
                context,
                groupName,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Color(0xFF333333),
                ),
              ),
              subtitle: description.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: _highlightSearchText(
                        context,
                        description,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Color(0xff8E92A0),
                        ),
                      ),
                    )
                  : null,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white : Color(0xff8E92A0),
              ),
              onTap: () {
                final service = _groupService;
                final socket = widget.socket;

                if (groupId.isEmpty ||
                    currentUserId.isEmpty ||
                    service == null ||
                    socket == null ||
                    !socket.connected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        text(
                          context,
                          'Connecting to chat. Please try again in a moment.',
                        ),
                      ),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      currentUserId: currentUserId,
                      groupService: service,
                      socket: socket,
                      postService: widget.postService,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage({
    required Widget icon,
    required String message,
    String? subtitle,
    bool showRetry = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        icon,
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text(context, message),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Color(0xffC4C4C4) : textColor,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              text(context, subtitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Color(0xff8E92A0) : Color(0xff8E92A0),
              ),
            ),
          ),
        ],
        if (showRetry) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: selectedFilter == 'Groups' ? _loadGroups : _loadPosts,
              child: Text(
                text(context, 'Try again'),
                style: TextStyle(color: accent),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _highlightSearchText(
    BuildContext context,
    String value, {
    int? maxLines,
    TextStyle? style,
  }) {
    final query = searchQuery.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spans = <TextSpan>[];

    if (query.isEmpty || value.isEmpty) {
      spans.add(TextSpan(text: value));
    } else {
      final lowerValue = value.toLowerCase();
      final lowerQuery = query.toLowerCase();

      int start = 0;

      while (true) {
        final matchIndex = lowerValue.indexOf(lowerQuery, start);

        if (matchIndex == -1) {
          if (start < value.length) {
            spans.add(TextSpan(text: value.substring(start)));
          }
          break;
        }

        if (matchIndex > start) {
          spans.add(TextSpan(text: value.substring(start, matchIndex)));
        }

        spans.add(
          TextSpan(
            text: value.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              backgroundColor: isDark ? Color(0xFF8A6800) : Color(0xFFFFE082),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        start = matchIndex + query.length;
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
