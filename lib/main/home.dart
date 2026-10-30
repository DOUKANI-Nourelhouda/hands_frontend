import 'package:flutter/material.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/widgets/homeheader.dart';
import 'package:hands/widgets/home_catigores.dart';
import 'package:hands/widgets/postwidget.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/utils/langs.dart';

class HomePage extends StatefulWidget {
  final PostService postService;
  final Future<void> Function(String recipientId) onMessageTap;
  const HomePage({
    super.key,
    required this.postService,
    required this.onMessageTap,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedCategory;
  bool isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _initializePostService();
  }

  final AuthService _authService = AuthService();

  PostService? _postService;
  String _currentUserId = '';
  Future<void> loadPostsForCategory(String? category) async {
    setState(() {
      selectedCategory = category;
      isLoadingPosts = true;
      errorMessage = null;
    });

    try {
      final result;

      if (category == null || category == 'All') {
        result = await widget.postService.getPosts(page: 1, limit: 10);
      } else {
        result = await widget.postService.getPostsByCategory(
          category,
          page: 1,
          limit: 10,
        );
      }

      if (!mounted) return;

      final rawPosts = result['posts'] as List<dynamic>? ?? [];

      setState(() {
        posts = rawPosts
            .whereType<Map>()
            .map((post) => Map<String, dynamic>.from(post))
            .toList();

        isLoading = false;
        isLoadingPosts = false;
      });
    } on PostException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.message;
        isLoading = false;
        isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load posts. Please try again.';
        isLoading = false;
        isLoadingPosts = false;
      });

      debugPrint('Error filtering posts: $e');
    }
  }

  Future<void> _initializePostService() async {
    final token = await _authService.getSavedToken();

    if (token == null || token.isEmpty) {
      return;
    }

    final userData = await _authService.getCurrentUser();

    final user = userData['user'] is Map
        ? Map<String, dynamic>.from(userData['user'])
        : userData;

    final userId = (user['_id'] ?? user['id'] ?? '').toString();

    if (!mounted) return;

    setState(() {
      _postService = PostService(baseUrl: AuthService.baseUrl, token: token);
      _currentUserId = userId;
    });
  }

  Future<void> refresh() async {
    await _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await widget.postService.getPosts(page: 1, limit: 10);

      final rawPosts = result['posts'] as List<dynamic>? ?? [];

      if (!mounted) return;

      setState(() {
        posts = rawPosts.whereType<Map<String, dynamic>>().toList();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            const HomeHeader(),

            const SizedBox(height: 5),

            // Category widget
            HomeCategories(
              selectedCategory: selectedCategory,
              onCategorySelected: loadPostsForCategory,
            ),

            // Only the feed scrolls.
            Expanded(
              child: RefreshIndicator(onRefresh: refresh, child: _buildFeed()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed() {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (errorMessage != null && posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 200),
          Center(child: Text(errorMessage!)),
        ],
      );
    }

    if (posts.isEmpty) {
      final category = selectedCategory;

      final message = category == null || category == 'All'
          ? 'No posts yet. Be the first who post!'
          : textRead(context, 'No posts about') +
                " " +
                textRead(context, '$category') +
                ' ' +
                textRead(context, 'yet.');

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 250),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    text(context, message),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostWidget(
          key: ValueKey(posts[index]['_id']),
          post: posts[index],
          postService: widget.postService,
          onPostReported: (postId) {
            setState(() {
              posts.removeWhere((post) => post['_id']?.toString() == postId);
            });
          },
          onPostUpdated: (updatedPost) {
            setState(() {
              final index = posts.indexWhere(
                (p) => p['_id']?.toString() == updatedPost['_id']?.toString(),
              );

              if (index != -1) {
                posts[index] = updatedPost;
              }
            });
          },
          currentUserId: _currentUserId,
          onOpenChat: (post) async {
            debugPrint('[POST CHAT] Post: $post');
            debugPrint('[POST CHAT] Current user: $_currentUserId');

            final owner = post['user'] ?? post['owner'] ?? post['author'];

            String ownerId = '';

            if (owner is Map) {
              ownerId = (owner['_id'] ?? owner['id'] ?? '').toString();
            } else {
              ownerId = (owner ?? post['userId'] ?? '').toString();
            }

            debugPrint('[POST CHAT] Owner ID: $ownerId');

            if (ownerId.isEmpty) {
              debugPrint('[POST CHAT] ERROR: Owner ID not found');
              return;
            }

            await widget.onMessageTap(ownerId);
          },
        );
      },
    );
  }
}
