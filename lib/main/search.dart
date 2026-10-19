import 'package:flutter/material.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/services/user_service.dart';
import 'dart:async';
import 'package:hands/main/profile.dart';

class SearchPage extends StatefulWidget {
  final PostService postService;

  const SearchPage({super.key, required this.postService});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> searchResults = [];

  Timer? _searchDebounce;
  int _searchRequestId = 0;

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
      users = [];
      searchErrorMessage = null;
      isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (selectedFilter == 'Users') {
        _searchUsers(query, requestId);
      } else if (selectedFilter == 'Posts') {
        _searchPosts(query, requestId);
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

    setState(() {
      selectedFilter = filter;
      searchResults = [];
      users = [];
      searchErrorMessage = null;
      isSearching = false;
    });

    _searchDebounce?.cancel();

    // Invalidate any previous search request.
    final requestId = ++_searchRequestId;

    if (searchQuery.trim().isEmpty) return;

    final query = searchQuery.trim();

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
    return Scaffold(
      backgroundColor: Colors.white,
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: textColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 4),

          // Search bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search ...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff8E92A0),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xff8E92A0),
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
                color: isSelected ? accent : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? accent : const Color(0xFFEEEEEE),
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
                    filter['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : textColor,
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
    return SvgPicture.asset(
      assetPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        isSelected ? Colors.white : textColor,
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
          'assets/icons/post.svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(
            Color(0xffC4C4C4),
            BlendMode.srcIn,
          ),
        ),
        message: searchQuery.isEmpty
            ? 'No posts yet.'
            : 'No posts found for "$searchQuery".',
      );
    }

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
          );
        },
      ),
    );
  }

  Widget _buildUserResults() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (searchErrorMessage != null) {
      return Center(child: Text(searchErrorMessage!));
    }

    if (searchQuery.trim().isEmpty) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/empty_users.svg',
          width: 52,
          height: 52,
        ),
        message: 'Search for students in your residence.',
        subtitle: 'Enter a username to find students.',
      );
    }

    if (users.isEmpty) {
      return _buildMessage(
        icon: SvgPicture.asset(
          'assets/icons/empty_users.svg',
          width: 52,
          height: 52,
        ),
        message: 'No students found.',
        subtitle: 'Try searching for another username.',
      );
    }

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
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
                  : const AssetImage('assets/default_pfp.jpg') as ImageProvider,
            ),
            title: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            subtitle: bio.isNotEmpty ? Text(bio) : null,
            onTap: () {
              final userId = (user['_id'] ?? user['id'] ?? '').toString();

              if (userId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open this profile.')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(userId: userId)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupResults() {
    final results = groups.where((group) {
      final name = (group['name'] ?? '').toString().toLowerCase();
      final description = (group['description'] ?? '').toString().toLowerCase();

      return searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          description.contains(searchQuery);
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
        message: 'Discover student groups.',
        subtitle: 'Connect your groups API to show results here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final group = results[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFFFF4CC),
            child: Icon(Icons.groups_rounded, color: accent),
          ),
          title: Text(
            (group['name'] ?? 'Student group').toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            (group['description'] ?? '').toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            // Open the group page here.
          },
        );
      },
    );
  }

  Widget _buildMessage({
    required Widget icon,
    required String message,
    String? subtitle,
    bool showRetry = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        icon,
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xff8E92A0)),
            ),
          ),
        ],
        if (showRetry) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _loadPosts,
              child: const Text('Try again', style: TextStyle(color: accent)),
            ),
          ),
        ],
      ],
    );
  }
}
