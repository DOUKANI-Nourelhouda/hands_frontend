import 'package:hands/main/msgs.dart';
import 'package:hands/widgets/costombuttomnav.dart';
import 'package:hands/main/home.dart';
import 'package:hands/main/search.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/main/createpost.dart';
import 'package:hands/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/group_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/main/group_chat_page.dart';

class MainScreen extends StatefulWidget {
  final PostService postService;

  const MainScreen({super.key, required this.postService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  IO.Socket? socket;
  final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? currentUser;
  String? authToken;
  GroupService? groupService;

  bool isLoadingMessagesSetup = true;
  String? messagesSetupError;
  List<Widget> get pages => [
    HomePage(key: homePageKey, postService: widget.postService),

    if (groupService != null && socket != null)
      SearchPage(postService: widget.postService, socket: socket!)
    else
      const Center(child: CircularProgressIndicator(color: Color(0xfffcc001))),

    _buildMessagesPage(),

    ProfilePage(postService: widget.postService),
  ];
  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  void _initializeSocket(String token) {
    final socketUrl = dotenv.env['SOCKET_URL'];

    if (socketUrl == null || socketUrl.isEmpty) {
      debugPrint('[SOCKET] ERROR: SOCKET_URL is missing');
      return;
    }

    // Avoid creating duplicate connections.
    socket?.dispose();

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('[SOCKET] CONNECTED: ${socket!.id}');
    });

    socket!.onConnectError((error) {
      debugPrint('[SOCKET] CONNECT ERROR: $error');
    });

    socket!.onError((error) {
      debugPrint('[SOCKET] ERROR: $error');
    });

    socket!.onDisconnect((reason) {
      debugPrint('[SOCKET] DISCONNECTED: $reason');
    });

    socket!.connect();
    debugPrint('[SOCKET] Connection requested with authentication');
  }

  Future<void> _initializeMessages() async {
    try {
      final token = await _authService.getSavedToken();

      if (token == null || token.isEmpty) {
        debugPrint('[SOCKET] ERROR: Authentication token is missing');

        if (!mounted) return;

        setState(() {
          messagesSetupError = 'Your session has expired. Please log in again.';
          isLoadingMessagesSetup = false;
        });

        return;
      }

      final userResult = await _authService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        authToken = token;
        currentUser = userResult;
        groupService = GroupService(
          baseUrl: dotenv.env['BASE_URL']!,
          token: token,
        );
        isLoadingMessagesSetup = false;
      });

      _initializeSocket(token);
    } catch (e, stackTrace) {
      debugPrint('[MSGS] Initialization error: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        setState(() {
          messagesSetupError = 'Failed to initialize messages. Please retry.';
          isLoadingMessagesSetup = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _initializeMessages();
  }

  Widget _buildMessagesPage() {
    if (isLoadingMessagesSetup) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (messagesSetupError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 12),
            Text(messagesSetupError!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoadingMessagesSetup = true;
                  messagesSetupError = null;
                });
                _initializeMessages();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final user = currentUser;
    final token = authToken;
    final groups = groupService;

    if (user == null || token == null || groups == null) {
      return const Center(child: Text('Messages could not be initialized.'));
    }

    // Change these field names if your user model uses different ones.
    final userId = user['_id']?.toString();

    if (userId == null || userId.isEmpty) {
      return const Center(child: Text('Could not identify the current user.'));
    }

    return MsgsPage(
      baseUrl: dotenv.env['BASE_URL']!,
      token: token,
      currentUserId: userId,
      currentUser: user,
      groupService: groups,
      onOpenConversation: onOpenConversation,
      onOpenGroup: onOpenGroup,
    );
  }

  void onOpenConversation(Map<String, dynamic> conversation) {
    debugPrint('[MSGS] Opening conversation: ${conversation['_id']}');

    // TODO: Navigate to your direct chat page.
  }

  void onOpenGroup(Map<String, dynamic> group) {
    final groupId = (group['_id'] ?? group['id'] ?? '').toString();
    final groupName = (group['name'] ?? group['groupName'] ?? 'Group')
        .toString();
    final currentUserId = (currentUser?['_id'] ?? currentUser?['id'] ?? '')
        .toString();

    final service = groupService;
    final connectedSocket = socket;

    debugPrint('[OPEN GROUP] groupId: $groupId');
    debugPrint('[OPEN GROUP] currentUserId: $currentUserId');
    debugPrint('[OPEN GROUP] service available: ${service != null}');
    debugPrint('[OPEN GROUP] socket available: ${connectedSocket != null}');
    debugPrint('[OPEN GROUP] socket connected: ${connectedSocket?.connected}');

    if (groupId.isEmpty ||
        currentUserId.isEmpty ||
        service == null ||
        connectedSocket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group chat is not initialized yet.')),
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
          socket: connectedSocket,
        ),
      ),
    );
  }

  Future<void> _openCreatePost() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(postService: widget.postService),
      ),
    );

    if (!mounted || result == null) return;

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
