import 'package:flutter/material.dart';

import 'package:hands/widgets/costombuttomnav.dart';
import 'package:hands/main/home.dart';
import 'package:hands/main/search.dart';
import 'package:hands/main/msgs.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/main/createpost.dart';
import 'package:hands/services/post_service.dart';

class MainScreen extends StatefulWidget {
  final PostService postService;

  const MainScreen({super.key, required this.postService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      HomePage(key: homePageKey, postService: widget.postService),
      SearchPage(postService: widget.postService),
      const MsgsPage(),
      const ProfilePage(),
    ];
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
