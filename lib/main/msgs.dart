import 'package:flutter/material.dart';
import '../services/group_service.dart';
import 'package:hands/services/msgs_service.dart';
import 'package:hands/main/group_page.dart';
import 'package:hands/utils/langs.dart';

class MsgsPage extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String currentUserId;
  final Map<String, dynamic> currentUser;
  final GroupService groupService;
  final Future<void> Function(String recipientId)? onMessageTap;

  final void Function(Map<String, dynamic> conversation) onOpenConversation;
  final void Function(Map<String, dynamic> group) onOpenGroup;
  final VoidCallback? onRefreshRequested;
  const MsgsPage({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.currentUserId,
    required this.currentUser,
    required this.groupService,
    required this.onOpenConversation,
    required this.onOpenGroup,
    this.onRefreshRequested,
    this.onMessageTap,
  });

  @override
  State<MsgsPage> createState() => _MsgsPageState();
}

class _MsgsPageState extends State<MsgsPage> {
  static const Color accent = Color(0xfffcc001);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> groups = [];
  bool isLoadingGroups = false;
  String? groupsError;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  late final MsgService _msgService;

  String get _baseUrl => widget.baseUrl.replaceAll(RegExp(r'/+$'), '');
  @override
  void initState() {
    super.initState();

    debugPrint('[MSGS] Page initialized');

    _msgService = MsgService(baseUrl: _baseUrl, token: widget.token);

    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MsgsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadChats();
  }

  Future<void> _loadChats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[MSGS] Loading direct conversations...');
      final conversations = await _msgService.getConversations();
      debugPrint('[MSGS] Conversations loaded: ${conversations.length}');

      debugPrint('[MSGS] Loading groups...');
      final allGroups = await widget.groupService.getGroups();

      debugPrint('[MSGS] Groups returned by API: ${allGroups.length}');

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _groups = allGroups;

        debugPrint('[MSGS] Current user ID: ${widget.currentUserId}');
        debugPrint('[MSGS] Groups returned by API: ${allGroups.length}');
        debugPrint('[MSGS] Groups displayed: ${_groups.length}');
        debugPrint('[MSGS] Group data: $_groups');

        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('[MSGS] Loading failed: $error');
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

    if (participants is! List || participants.isEmpty) {
      return null;
    }

    // First, try to find the other participant.
    for (final participant in participants) {
      if (_idOf(participant) != widget.currentUserId) {
        if (participant is Map) {
          return Map<String, dynamic>.from(participant);
        }
      }
    }

    // If nobody is different from the current user,
    // this is probably a self-chat.
    final firstParticipant = participants.first;

    if (firstParticipant is Map &&
        _idOf(firstParticipant) == widget.currentUserId) {
      return Map<String, dynamic>.from(firstParticipant);
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

    return textRead(context, 'Start chatting with your group');
  }

  bool _matches(String value) {
    return value.toLowerCase().contains(_searchQuery.trim().toLowerCase());
  }

  List<Map<String, dynamic>> get _filteredConversations {
    return _conversations.where((conversation) {
      final user = _otherParticipant(conversation);

      if (user == null) return false;

      final participants = conversation['participants'];

      final isSelfChat =
          participants is List &&
          participants.isNotEmpty &&
          participants.every(
            (participant) => _idOf(participant) == widget.currentUserId,
          );

      final username = _usernameOf(user);

      return _matches(username) ||
          _matches(_usernameOf(user)) ||
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFFFF2C2),
      backgroundImage: url.isNotEmpty
          ? NetworkImage(url)
          : AssetImage(
                  isDark
                      ? 'assets/default_pfp_dark.png'
                      : 'assets/default_pfp.jpg',
                )
                as ImageProvider,
    );
  }

  Widget _buildProfileHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Color(0xFF333333),
              size: 26,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: _buildSearchBar()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
        cursorColor: Colors.black,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: text(context, 'Search people or groups'),
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey : Color(0xff8E92A0),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.grey : Color(0xff8E92A0),
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF8E92A0),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Text(
            text(context, title),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otherUser = _otherParticipant(conversation);

    if (otherUser == null) {
      return const SizedBox.shrink();
    }

    final participants = conversation['participants'];

    final isSelfChat =
        participants is List &&
        participants.isNotEmpty &&
        participants.every(
          (participant) => _idOf(participant) == widget.currentUserId,
        );

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
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    '${_lastGroupMessage(group)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      extendBody: false,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildProfileHeader(),

                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xfffcc001),
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(_errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadChats,
                              child: Text(text(context, 'Try again')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xfffcc001),
                      onRefresh: _loadChats,
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 90),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _buildSectionTitle(
                            'Direct messages',
                            _filteredConversations.length,
                          ),

                          if (_filteredConversations.isEmpty)
                            _buildEmptyState(
                              _searchQuery.isEmpty
                                  ? 'No conversations yet.'
                                  : 'No conversations match your search.',
                            )
                          else
                            ..._filteredConversations.map(
                              _buildConversationTile,
                            ),

                          _buildSectionTitle('Groups', _filteredGroups.length),

                          if (_filteredGroups.isEmpty)
                            _buildEmptyState(
                              _searchQuery.isEmpty
                                  ? textRead(
                                      context,
                                      'You have not joined any groups yet.',
                                    )
                                  : textRead(
                                      context,
                                      'No groups match your search.',
                                    ),
                            )
                          else
                            ..._filteredGroups.map(_buildGroupTile),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Floating button
            Positioned(
              right: 20,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'msgs_fab',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateGroupPage(groupService: widget.groupService),
                    ),
                  );

                  if (mounted) {
                    await _loadChats();
                  }
                },
                backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
                foregroundColor: Color(0xfffcc001),
                elevation: 6,
                shape: const CircleBorder(),
                child: const Icon(Icons.edit_rounded, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
