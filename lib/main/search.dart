import 'package:flutter/material.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchPage extends StatefulWidget {
  final PostService postService;

  const SearchPage({super.key, required this.postService});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color accent = Color(0xfffcc001);
  static const Color textColor = Color(0xff333333);

  final TextEditingController _searchController = TextEditingController();

  final AuthService _authService = AuthService();

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
    {'name': 'Users', 'icon': 'assets/icons/profile.svg'},
    {'name': 'Groups', 'icon': 'assets/icons/groups.svg'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeSearch() async {
    await _loadCurrentUser();
    await _loadPosts();
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

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim().toLowerCase();
    });
  }

  void _selectFilter(String filter) {
    FocusScope.of(context).unfocus();

    setState(() {
      selectedFilter = filter;
    });
  }

  List<Map<String, dynamic>> get filteredPosts {
    if (searchQuery.isEmpty) return posts;

    return posts.where((post) {
      final title = (post['title'] ?? '').toString().toLowerCase();
      final description = (post['description'] ?? '').toString().toLowerCase();
      final category = (post['category'] ?? '').toString().toLowerCase();

      final author = post['user'] is Map
          ? Map<String, dynamic>.from(post['user'])
          : post['user'] is String
          ? <String, dynamic>{'username': post['user']}
          : <String, dynamic>{};

      final username = (author['username'] ?? '').toString().toLowerCase();

      return title.contains(searchQuery) ||
          description.contains(searchQuery) ||
          category.contains(searchQuery) ||
          username.contains(searchQuery);
    }).toList();
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
    if (isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    if (errorMessage != null && posts.isEmpty) {
      return _buildMessage(
        icon: Icons.wifi_off_rounded,
        message: errorMessage!,
        showRetry: true,
      );
    }

    final results = filteredPosts;

    if (results.isEmpty) {
      return _buildMessage(
        icon: Icons.search_off_rounded,
        message: searchQuery.isEmpty
            ? 'No posts yet.'
            : 'No posts found for "$searchQuery".',
      );
    }

    return RefreshIndicator(
      color: accent,
      onRefresh: _loadPosts,
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
    final results = users.where((user) {
      final username = (user['username'] ?? '').toString().toLowerCase();
      final name = (user['name'] ?? '').toString().toLowerCase();

      return searchQuery.isEmpty ||
          username.contains(searchQuery) ||
          name.contains(searchQuery);
    }).toList();

    if (results.isEmpty) {
      return _buildMessage(
        icon: Icons.people_outline_rounded,
        message: 'Search for students in your residence.',
        subtitle: 'Connect your users search API to show results here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFFFF4CC),
            backgroundImage: user['profilePicture'] != null
                ? NetworkImage(user['profilePicture'].toString())
                : null,
            child: user['profilePicture'] == null
                ? const Icon(Icons.person, color: accent)
                : null,
          ),
          title: Text(
            (user['username'] ?? user['name'] ?? 'Student').toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            (user['bio'] ?? 'Hands student').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            // Open the user's profile page here.
          },
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
        icon: Icons.groups_outlined,
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
    required IconData icon,
    required String message,
    String? subtitle,
    bool showRetry = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(icon, size: 52, color: const Color(0xffC4C4C4)),
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
