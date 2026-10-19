import 'package:hands/widgets/costombuttomnav.dart';
import 'package:hands/main/home.dart';
import 'package:hands/main/search.dart';
import 'package:hands/main/msgs.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/main/createpost.dart';
import 'package:hands/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/group_service.dart';

class MainScreen extends StatefulWidget {
  final PostService postService;

  const MainScreen({super.key, required this.postService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? currentUser;
  String? authToken;
  GroupService? groupService;

  bool isLoadingMessagesSetup = true;
  String? messagesSetupError;
  late final List<Widget> pages;

  Future<void> _initializeMessages() async {
    try {
      final results = await Future.wait([
        _authService.getSavedToken(),
        _authService.getCurrentUser(),
      ]);

      final token = results[0] as String?;
      final userResult = results[1];

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again.');
      }

      // Adjust this if getCurrentUser() returns a wrapper
      // such as {"user": {...}} instead of the user map.
      if (userResult is! Map<String, dynamic>) {
        throw Exception('Could not retrieve your user information.');
      }

      final user = userResult;

      if (!mounted) return;

      setState(() {
        authToken = token;
        currentUser = user;
        groupService = GroupService(
          baseUrl: 'http://10.140.155.2:5000/api',
          token: token,
        );
        isLoadingMessagesSetup = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messagesSetupError = e.toString().replaceFirst('Exception: ', '');
        isLoadingMessagesSetup = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    pages = [
      HomePage(key: homePageKey, postService: widget.postService),
      SearchPage(postService: widget.postService),
      const SizedBox.shrink(), // Messages placeholder
      const ProfilePage(),
    ];

    _initializeMessages();
  }

  Future<void> _openCreatePost() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(postService: widget.postService),
      ),
    );

    if (!mounted || result == null) return;

    // Refresh the home feed after a successful post.
    await homePageKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      extendBody: true,
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        onCenterTap: _openCreatePost,
      ),
    );
  }
}
