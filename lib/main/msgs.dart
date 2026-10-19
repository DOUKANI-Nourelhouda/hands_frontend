import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/group_service.dart';
import 'package:hands/main/group_page.dart';
import 'package:hands/services/msgs_service.dart';
import '../services/auth_service.dart';
import '../services/msgs_service.dart';

class MsgsPage extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String currentUserId;
  final Map<String, dynamic> currentUser;
  final GroupService groupService;

  final void Function(Map<String, dynamic> conversation) onOpenConversation;
  final void Function(Map<String, dynamic> group) onOpenGroup;

  const MsgsPage({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.currentUserId,
    required this.currentUser,
    required this.groupService,
    required this.onOpenConversation,
    required this.onOpenGroup,
  });

  @override
  State<MsgsPage> createState() => _MsgsPageState();
}

class _MsgsPageState extends State<MsgsPage> {
  static const Color accent = Color(0xfffcc001);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _groups = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  late final MsgService _msgService;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'token': widget.token,
  };

  String get _baseUrl => widget.baseUrl.replaceAll(RegExp(r'/+$'), '');
  @override
  void initState() {
    super.initState();

    debugPrint('[MSGS] Page initialized');

    _msgService = MsgService();

    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _msgService.getConversations(),
        widget.groupService.getGroups(),
      ]);

      final conversations = results[0] as List<Map<String, dynamic>>;

      final groups = results[1] as List<Map<String, dynamic>>;

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _groups = groups;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('❌ Messages loading failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _idOf(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  String _usernameOf(dynamic user) {
    if (user is Map) {
      return user['username']?.toString() ??
          user['name']?.toString() ??
          'Student';
    }
    return 'Student';
  }

  String _pictureOf(dynamic user) {
    if (user is Map) {
      return user['profilePicture']?.toString() ?? '';
    }
    return '';
  }

  String _imageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('https://') || path.startsWith('http://')) {
      return path;
    }

    // Handles relative image paths returned by your backend.
    final uri = Uri.parse(_baseUrl);
    final origin = '${uri.scheme}://${uri.authority}';

    return '$origin/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Map<String, dynamic>? _otherParticipant(Map<String, dynamic> conversation) {
    final participants = conversation['participants'];

    if (participants is! List) return null;

    for (final participant in participants) {
      if (_idOf(participant) != widget.currentUserId) {
        if (participant is Map) {
          return Map<String, dynamic>.from(participant);
        }
      }
    }

    return null;
  }

  String _lastDirectMessage(Map<String, dynamic> conversation) {
    final message = conversation['lastMessage'];

    if (message is Map) {
      final content = message['content']?.toString() ?? '';
      final picture = message['picture']?.toString() ?? '';

      if (content.trim().isNotEmpty) return content;
      if (picture.isNotEmpty) return '📷 Photo';
    }

    return 'Start a conversation';
  }

  String _lastGroupMessage(Map<String, dynamic> group) {
    final message = group['lastMessage'];

    if (message is Map) {
      final text =
          message['text']?.toString() ?? message['content']?.toString() ?? '';

      if (text.trim().isNotEmpty) {
        return text;
      }

      return 'Sent an attachment';
    }

    return 'Start chatting with your group';
  }

  String _groupMemberCount(Map<String, dynamic> group) {
    final members = group['members'];
    if (members is List) {
      return '${members.length} members';
    }
    return 'Group chat';
  }

  bool _matches(String value) {
    return value.toLowerCase().contains(_searchQuery.trim().toLowerCase());
  }

  List<Map<String, dynamic>> get _filteredConversations {
    return _conversations.where((conversation) {
      final user = _otherParticipant(conversation);
      if (user == null) return false;

      return _matches(_usernameOf(user)) ||
          _matches(_lastDirectMessage(conversation));
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredGroups {
    return _groups.where((group) {
      return _matches(group['name']?.toString() ?? '') ||
          _matches(_lastGroupMessage(group));
    }).toList();
  }

  Widget _buildAvatar({
    required String picture,
    required String fallbackText,
    double radius = 25,
  }) {
    final url = _imageUrl(picture);

    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFFFF2C2),
      backgroundImage: picture.isNotEmpty
          ? NetworkImage(picture)
          : const AssetImage('assets/default_pfp.jpg') as ImageProvider,
    );
  }

  Widget _buildProfileHeader() {
    final username = widget.currentUser['username']?.toString() ?? 'Student';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Center(
        child: Column(
          children: [
            _buildAvatar(
              picture: _pictureOf(widget.currentUser),
              fallbackText: username,
              radius: 34,
            ),
            const SizedBox(height: 9),
            Text(
              username,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Messages',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search people or groups',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: const Color(0xfff5f5f5),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final otherUser = _otherParticipant(conversation);

    if (otherUser == null) {
      return const SizedBox.shrink();
    }

    final username = _usernameOf(otherUser);

    return InkWell(
      onTap: () => widget.onOpenConversation(conversation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            _buildAvatar(
              picture: _pictureOf(otherUser),
              fallbackText: username,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _lastDirectMessage(conversation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    final name = group['name']?.toString() ?? 'Group';

    return InkWell(
      onTap: () => widget.onOpenGroup(group),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: accent.withValues(alpha: 0.22),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.black87,
                size: 27,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_groupMemberCount(group)} · '
                    '${_lastGroupMessage(group)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages DEBUG'),
        backgroundColor: const Color(0xfffcc001),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'MSGS PAGE IS OPEN',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                debugPrint('TEST BUTTON PRESSED');
                _loadChats();
              },
              child: const Text('TEST BACKEND REQUESTS'),
            ),
          ],
        ),
      ),
    );
  }
}
