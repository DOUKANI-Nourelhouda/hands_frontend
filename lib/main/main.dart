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
import 'package:hands/main/chat_page.dart';
import 'package:hands/services/msgs_service.dart';
import 'package:hands/utils/langs.dart';

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
  int _groupsRefreshKey = 0;
  Map<String, dynamic>? currentUser;
  String? authToken;
  GroupService? groupService;

  bool isLoadingMessagesSetup = true;
  String? messagesSetupError;
  List<Widget> get pages => [
    HomePage(
      key: homePageKey,
      postService: widget.postService,
      onMessageTap: _openDirectChat,
    ),

    if (groupService != null && socket != null)
      SearchPage(
        postService: widget.postService,
        socket: socket!,
        onMessageTap: _openDirectChat,
      )
    else
      const Center(child: CircularProgressIndicator(color: Color(0xfffcc001))),

    _buildMessagesPage(),

    ProfilePage(postService: widget.postService, onMessageTap: _openDirectChat),
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

  Future<void> _openDirectChat(String recipientId) async {
    final targetId = recipientId.trim();

    if (targetId.isEmpty) {
      debugPrint('[DIRECT CHAT] ERROR: Empty recipient ID');
      return;
    }

    if (!mounted) return;

    try {
      // Make sure we have the authentication token.
      final token = authToken ?? await _authService.getSavedToken();

      if (token == null || token.isEmpty) {
        throw Exception('Please log in again.');
      }

      // Make sure we know the logged-in user's ID.
      Map<String, dynamic>? user = currentUser;

      if (user == null) {
        final result = await _authService.getCurrentUser();

        user = result['user'] is Map
            ? Map<String, dynamic>.from(result['user'])
            : Map<String, dynamic>.from(result);
      }

      final myId = (user['_id'] ?? user['id'] ?? '').toString();

      if (myId.isEmpty) {
        throw Exception('Could not identify your account.');
      }

      // A connected socket is required by your ChatPage.
      final activeSocket = socket;

      if (activeSocket == null || !activeSocket.connected) {
        throw Exception('Chat connection is unavailable. Please try again.');
      }

      final baseUrl = dotenv.env['BASE_URL'];

      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BASE_URL is missing from your environment.');
      }

      final msgService = MsgService(baseUrl: baseUrl, token: token);

      debugPrint('[DIRECT CHAT] Opening conversation with $targetId');

      // Create the conversation or retrieve the existing one.
      final conversation = await msgService.createConversation(targetId);
      debugPrint('[DIRECT CHAT] Full conversation response: $conversation');
      debugPrint('[DIRECT CHAT] My ID: $myId');
      debugPrint('[DIRECT CHAT] Target ID: $targetId');
      debugPrint('[DIRECT CHAT] Participants: ${conversation['participants']}');
      final conversationId = (conversation['_id'] ?? conversation['id'] ?? '')
          .toString();

      if (conversationId.isEmpty) {
        debugPrint('[DIRECT CHAT] Invalid response: $conversation');
        throw Exception('The server did not return a conversation ID.');
      }

      if (!mounted) return;

      debugPrint('[DIRECT CHAT] Conversation ID: $conversationId');
      // Find the recipient inside the conversation participants.
      final participants =
          (conversation['participants'] as List?)
              ?.whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p))
              .toList() ??
          <Map<String, dynamic>>[];

      final recipient = participants.firstWhere(
        (p) => (p['_id'] ?? p['id'] ?? '').toString() == targetId,
        orElse: () => <String, dynamic>{},
      );

      if (recipient.isEmpty) {
        throw Exception('Could not find the recipient in the conversation.');
      }

      final recipientName =
          (recipient['username'] ?? recipient['name'] ?? 'Student').toString();

      final recipientPicture =
          (recipient['profilePicture'] ??
                  recipient['profileImage'] ??
                  recipient['avatar'] ??
                  '')
              .toString();

      debugPrint('[DIRECT CHAT] Recipient name: $recipientName');
      debugPrint('[DIRECT CHAT] Recipient picture: $recipientPicture');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,
            postService: widget.postService,
            currentUserId: myId,
            otherUserId: targetId,
            otherUserName: recipientName,
            otherUserPicture: recipientPicture,
            msgService: msgService,
            socket: activeSocket,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[DIRECT CHAT] ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
            Text(text(context, messagesSetupError!)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoadingMessagesSetup = true;
                  messagesSetupError = null;
                });
                _initializeMessages();
              },
              child: Text(text(context, 'Retry')),
            ),
          ],
        ),
      );
    }

    final user = currentUser;
    final token = authToken;
    final groups = groupService;

    if (user == null || token == null || groups == null) {
      return Center(
        child: Text(textRead(context, 'Messages could not be initialized.')),
      );
    }

    // Change these field names if your user model uses different ones.
    final userId = user['_id']?.toString();

    if (userId == null || userId.isEmpty) {
      return Center(
        child: Text(textRead(context, 'Could not identify the current user.')),
      );
    }

    return MsgsPage(
      key: ValueKey(_groupsRefreshKey),
      baseUrl: dotenv.env['BASE_URL']!,
      token: token,
      currentUserId: userId,
      currentUser: user,
      groupService: groups,
      onOpenConversation: onOpenConversation,
      onOpenGroup: onOpenGroup,
    );
  }

  Future<void> onOpenConversation(Map<String, dynamic> conversation) async {
    final conversationId = (conversation['_id'] ?? conversation['id'] ?? '')
        .toString();

    final userId = (currentUser?['_id'] ?? currentUser?['id'] ?? '').toString();

    final connectedSocket = socket;
    final token = authToken;

    if (conversationId.isEmpty ||
        userId.isEmpty ||
        token == null ||
        token.isEmpty ||
        connectedSocket == null ||
        !connectedSocket.connected) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textRead(context, 'Chat is not initialized. Please try again.'),
          ),
        ),
      );
      return;
    }

    // Get the other participant in this conversation.
    final participants = conversation['participants'] is List
        ? List<Map<String, dynamic>>.from(
            (conversation['participants'] as List).whereType<Map>().map(
              (item) => Map<String, dynamic>.from(item),
            ),
          )
        : <Map<String, dynamic>>[];
    Map<String, dynamic> otherUser;

    if (participants.isEmpty) {
      debugPrint('[CHAT] No participants found: $conversation');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textRead(context, 'Could not find the other participant.'),
          ),
        ),
      );
      return;
    }

    // Find the other participant for a normal conversation.
    final otherParticipant = participants.where((participant) {
      final participantId = (participant['_id'] ?? participant['id'] ?? '')
          .toString();

      return participantId.isNotEmpty && participantId != userId;
    }).toList();

    // Normal chat: use the other user.
    // Self-chat: use the current user.
    otherUser = otherParticipant.isNotEmpty
        ? otherParticipant.first
        : participants.first;

    final otherUserId = (otherUser['_id'] ?? otherUser['id'] ?? '').toString();

    final otherUserName = (otherUser['username'] ?? otherUser['name'] ?? 'User')
        .toString();

    final otherUserPicture =
        (otherUser['profilePicture'] ??
                otherUser['profileImage'] ??
                otherUser['avatar'] ??
                '')
            .toString();

    // Use the same base URL convention as your existing MsgsPage.
    final msgService = MsgService(
      baseUrl: dotenv.env['BASE_URL']!.replaceAll(RegExp(r'/+$'), ''),
      token: token,
    );

    debugPrint('[CHAT] Conversation ID: $conversationId');
    debugPrint('[CHAT] Current user ID: $userId');
    debugPrint('[CHAT] Other user ID: $otherUserId');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          postService: widget.postService,
          currentUserId: userId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPicture: otherUserPicture,
          msgService: msgService,
          socket: connectedSocket,
        ),
      ),
    );
  }

  Future<void> onOpenGroup(Map<String, dynamic> group) async {
    final groupId = (group['_id'] ?? group['id'] ?? '').toString();
    final groupName = (group['name'] ?? group['groupName'] ?? 'Group')
        .toString();
    final currentUserId = (currentUser?['_id'] ?? currentUser?['id'] ?? '')
        .toString();

    final service = groupService;
    final connectedSocket = socket;

    debugPrint('[OPEN GROUP] groupId: $groupId');
    debugPrint('[OPEN GROUP] currentUserId: $currentUserId');

    if (groupId.isEmpty ||
        currentUserId.isEmpty ||
        service == null ||
        connectedSocket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textRead(context, 'Group chat is not initialized yet.'),
          ),
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          groupId: groupId,
          groupName: groupName,
          currentUserId: currentUserId,
          groupService: service,
          socket: connectedSocket,
          postService: widget.postService,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _groupsRefreshKey++;
      });
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
