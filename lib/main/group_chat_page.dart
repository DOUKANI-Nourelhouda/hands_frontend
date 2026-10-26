import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/utils/langs.dart';
import '../services/group_service.dart';

const Color groupChatYellow = Color(0xfffcc001);

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final GroupService groupService;
  final IO.Socket socket;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.groupService,
    required this.socket,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Listen for new messages broadcast by the backend.
    widget.socket.on('group:message:new', onNewMessage);

    // Listen for confirmation that we joined the group room.
    widget.socket.on('group:joined', (data) {
      debugPrint('[GROUP CHAT] Joined confirmation: $data');
    });

    // Display errors returned by the backend.
    widget.socket.on('group:error', onGroupError);

    // Load the previous messages.
    loadMessages();

    // Ask the backend to join this group room.
    widget.socket.emit('group:join', {'groupId': widget.groupId});
  }

  String _id(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  void onNewMessage(dynamic data) {
    if (data is! Map) return;

    final message = Map<String, dynamic>.from(data);
    final receivedGroupId = _id(message['group'] ?? message['groupId']);

    debugPrint('[GROUP CHAT] Received message: $message');
    debugPrint('[GROUP CHAT] Received group ID: $receivedGroupId');

    if (receivedGroupId != widget.groupId) return;

    final messageId = _id(message['_id']);

    if (!mounted) return;

    setState(() {
      // Prevent duplicate entries if the server sends an event twice.
      if (messageId.isNotEmpty &&
          messages.any((item) => _id(item['_id']) == messageId)) {
        return;
      }

      messages.add(message);
      errorMessage = null;
      isSending = false;
    });

    _scrollToLatest();
    if (messageController.text.trim().isNotEmpty) {
      messageController.clear();
    }
  }

  void onGroupError(dynamic data) {
    if (!mounted) return;

    final message = data is Map
        ? (data['message'] ?? 'Group chat error').toString()
        : 'Group chat error';

    setState(() {
      errorMessage = message;
      isSending = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loadMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await widget.groupService.getMessages(widget.groupId);

      if (!mounted) return;

      setState(() {
        // Keep messages that arrived through Socket.IO while
        // the HTTP history request was running.
        final combined = <String, Map<String, dynamic>>{};

        for (final message in result) {
          final id = _id(message['_id']);
          if (id.isNotEmpty) {
            combined[id] = message;
          }
        }

        for (final message in messages) {
          final id = _id(message['_id']);
          if (id.isNotEmpty) {
            combined[id] = message;
          }
        }

        messages = combined.values.toList()
          ..sort((a, b) {
            final dateA = DateTime.tryParse((a['createdAt'] ?? '').toString());
            final dateB = DateTime.tryParse((b['createdAt'] ?? '').toString());

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return -1;
            if (dateB == null) return 1;

            return dateA.compareTo(dateB);
          });

        isLoading = false;
      });

      _scrollToLatest();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty || isSending) return;

    if (text.length > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages cannot exceed 5000 characters.'),
        ),
      );
      return;
    }

    if (!widget.socket.connected) {
      debugPrint('[GROUP CHAT] Socket is NOT connected');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected. Please try again.')),
      );
      return;
    }

    final payload = {'groupId': widget.groupId, 'text': text};

    debugPrint('[GROUP CHAT] Sending event: group:message:send');
    debugPrint('[GROUP CHAT] Payload: $payload');
    debugPrint('[GROUP CHAT] Socket ID: ${widget.socket.id}');

    setState(() {
      isSending = true;
      errorMessage = null;
    });

    widget.socket.emit('group:message:send', payload);

    // Keep the text until the server confirms the message
    // by sending the group:message:new event.
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _senderId(Map<String, dynamic> message) => _id(message['sender']);

  String _senderName(Map<String, dynamic> message) {
    final sender = message['sender'];

    if (sender is Map) {
      return (sender['username'] ?? 'Student').toString();
    }

    return 'Student';
  }

  String _messageText(Map<String, dynamic> message) =>
      (message['text'] ?? message['content'] ?? '').toString();

  String _formatTime(dynamic value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return '';

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    widget.socket.off('group:message:new', onNewMessage);
    widget.socket.off('group:error', onGroupError);

    // Leave the room, but do not disconnect the shared socket.
    widget.socket.emit('group:leave', {'groupId': widget.groupId});

    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<void> _confirmLeaveGroup() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLeave != true || !mounted) return;

    try {
      await widget.groupService.leaveGroup(widget.groupId);

      if (!mounted) return;

      // Return to the previous screen after leaving.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not leave group: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/default_grp.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.groupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'leave') {
                _confirmLeaveGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Leave group', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          if (errorMessage != null)
            Material(
              color: const Color(0xfffff0f0),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      onPressed: loadMessages,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('Send the first message to your group.'),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(5),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];

                      final isMine = _senderId(message) == widget.currentUserId;

                      return _buildMessageBubble(message, isMine);
                    },
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMine) {
    final text = _messageText(message);
    final time = _formatTime(message['createdAt']);

    final sender = message['sender'];
    final profilePicture = sender is Map
        ? (sender['profilePicture'] ?? '').toString().trim()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sender's profile picture: bottom-left for received messages.
          if (!isMine) ...[
            _buildSenderAvatar(profilePicture),
            const SizedBox(width: 7),
          ],

          // Message bubble.
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.70,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? groupChatYellow : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                border: isMine
                    ? null
                    : Border.all(color: const Color(0xffeeeeee)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _senderName(message),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: groupChatYellow,
                        ),
                      ),
                    ),
                  Text(text, style: const TextStyle(fontSize: 15)),
                  if (time.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMine ? Colors.black54 : Colors.black45,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Your own profile picture: bottom-right for sent messages.
          if (isMine) ...[
            const SizedBox(width: 7),
            _buildSenderAvatar(profilePicture),
          ],
        ],
      ),
    );
  }

  Widget _buildSenderAvatar(String imageUrl) {
    const double avatarSize = 32;

    Widget defaultAvatar() {
      return ClipOval(
        child: Image.asset(
          'assets/default_pfp.jpg',
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imageUrl.trim().isEmpty) {
      return defaultAvatar();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return defaultAvatar();
        },
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                minLines: 1,
                maxLines: 5,
                maxLength: 5000,
                onSubmitted: (_) => sendMessage(),

                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Message your group...',
                  filled: true,
                  fillColor: const Color(0xfff5f5f5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isSending ? null : sendMessage,
              style: IconButton.styleFrom(),
              icon: const Icon(
                Icons.send_rounded,
                color: Color(0xFFFCC001),
                size: 27,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
