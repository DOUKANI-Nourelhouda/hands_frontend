import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/utils/langs.dart';
import '../services/group_service.dart';
import 'package:hands/services/post_service.dart';
import 'group_info_page.dart';

const Color groupChatYellow = Color(0xfffcc001);

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final GroupService groupService;
  final IO.Socket socket;
  final PostService postService;
  final Future<void> Function(String recipientId)? onMessageTap;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.groupService,
    required this.socket,
    required this.postService,
    this.onMessageTap,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final TextEditingController editMessageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  Map<String, dynamic>? groupDetails;
  @override
  void initState() {
    super.initState();

    // Listen for new messages broadcast by the backend.
    widget.socket.on('group:message:new', onNewMessage);

    // Listen for confirmation that we joined the group room.
    widget.socket.on('group:joined', (data) {
      debugPrint('[GROUP CHAT] Joined confirmation: $data');
    });
    // LISTEN FOR EDITED GROUP MESSAGES
    widget.socket.on('group:message:updated', (data) {
      if (!mounted || data is! Map) return;

      final updatedMessage = Map<String, dynamic>.from(data);
      final messageId = _id(updatedMessage['_id']);

      if (messageId.isEmpty) return;

      setState(() {
        final index = messages.indexWhere(
          (message) => _id(message['_id']) == messageId,
        );

        if (index != -1) {
          messages[index] = updatedMessage;
        }
      });
    });

    // LISTEN FOR DELETED GROUP MESSAGES
    widget.socket.on('group:message:deleted', (data) {
      if (!mounted || data is! Map) return;

      final messageId = data['messageId']?.toString();

      if (messageId == null || messageId.isEmpty) return;

      setState(() {
        messages.removeWhere((message) => _id(message['_id']) == messageId);
      });
    });
    // Display errors returned by the backend.
    widget.socket.on('group:error', onGroupError);

    // Load the previous messages.
    loadMessages();

    // Ask the backend to join this group room.
    widget.socket.emit('group:join', {'groupId': widget.groupId});
    loadGroupDetails();
  }

  String _id(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  Future<void> loadGroupDetails() async {
    try {
      final result = await widget.groupService.getGroupDetails(widget.groupId);

      if (!mounted) return;

      setState(() {
        groupDetails = result;
      });
    } catch (e) {
      debugPrint('[GROUP CHAT] Could not load group details: $e');
    }
  }

  Future<void> _showMessageOptions(Map<String, dynamic> message) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF333333) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(textRead(context, 'Edit message')),
                onTap: () => Navigator.pop(sheetContext, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  textRead(context, 'Delete message'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(sheetContext, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice == 'edit') {
      await _editMessage(message);
    } else if (choice == 'delete') {
      await _deleteMessage(message);
    }
  }

  Future<void> _editMessage(Map<String, dynamic> message) async {
    final messageId = _id(message['_id'] ?? message['id']);

    if (messageId.isEmpty) return;

    editMessageController.text = _messageText(message);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF333333) : Colors.white,
          title: Text(textRead(context, 'Edit message')),
          content: TextField(
            cursorColor: const Color(0xfffcc001),
            controller: editMessageController,
            autofocus: true,
            maxLength: 5000,
            maxLines: 5,
            minLines: 1,
            decoration: InputDecoration(
              hintText: textRead(context, 'Write your message'),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xfffcc001), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                textRead(context, 'Cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF333333),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, editMessageController.text.trim());
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xfffcc001)),
              ),
            ),
          ],
        );
      },
    );

    if (newContent == null || !mounted) return;

    if (newContent.isEmpty) return;

    if (newContent.length > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textRead(context, 'Messages cannot exceed 5000 characters.'),
          ),
        ),
      );
      return;
    }

    if (newContent == _messageText(message)) return;

    try {
      final updatedMessage = await widget.groupService.editGroupMessage(
        groupId: widget.groupId,
        messageId: messageId,
        content: newContent,
      );

      if (!mounted) return;

      setState(() {
        final index = messages.indexWhere(
          (message) => message['_id']?.toString() == messageId,
        );

        if (index != -1) {
          messages[index] = updatedMessage;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final messageId = _id(message['_id'] ?? message['id']);

    if (messageId.isEmpty) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF333333) : Colors.white,
          title: Text(textRead(context, 'Delete message?')),
          content: Text(
            textRead(context, 'Are you sure you want to delete this message?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                textRead(context, 'Cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF333333),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.groupService.deleteGroupMessage(
        groupId: widget.groupId,
        messageId: messageId,
      );

      if (!mounted) return;

      setState(() {
        messages.removeWhere(
          (message) => message['_id']?.toString() == messageId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(textRead(context, 'Message deleted successfully')),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openGroupInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupInfoPage(
          groupId: widget.groupId,
          currentUserId: widget.currentUserId,
          groupService: widget.groupService,
          postService: widget.postService,
          onMessageTap: widget.onMessageTap,
        ),
      ),
    ).then((_) {
      loadGroupDetails();
    });
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
        SnackBar(content: Text('Messages cannot exceed 5000 characters.')),
      );
      return;
    }

    if (!widget.socket.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not connected. Please try again.')),
      );
      return;
    }

    final payload = {'groupId': widget.groupId, 'text': text};

    setState(() {
      isSending = true;
      errorMessage = null;
    });

    widget.socket.emit('group:message:send', payload);
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
    widget.socket.off('group:message:updated');
    widget.socket.off('group:message:deleted');
    widget.socket.emit('group:leave', {'groupId': widget.groupId});

    messageController.dispose();
    editMessageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<void> _confirmLeaveGroup() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(textRead(context, 'Leave group?')),
        content: Text(
          textRead(context, 'Are you sure you want to leave this group?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              textRead(context, 'Cancel'),
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xff333333),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              textRead(context, 'Leave'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave != true || !mounted) return;

    try {
      await widget.groupService.leaveGroup(widget.groupId);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textRead(context, 'Could not leave group: $e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff333333) : Colors.white,

      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xff333333) : Colors.white,
        foregroundColor: isDark ? Colors.white : Color(0xff333333),
        elevation: 0.5,
        titleSpacing: 0,
        title: InkWell(
          onTap: _openGroupInfo,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  isDark
                      ? 'assets/default_grp_dark.png'
                      : 'assets/default_grp.png',
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(groupDetails?['members'] as List?)?.length ?? 0} ' +
                          '${textRead(context, 'members')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: isDark ? Color(0xff333333) : Colors.white,
            onSelected: (value) {
              if (value == 'leave') {
                _confirmLeaveGroup();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: textRead(context, 'leave'),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text(
                      textRead(context, 'Leave group'),
                      style: TextStyle(color: Colors.red),
                    ),
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
              color: isDark ? Color(0xff333333) : Color(0xfffff0f0),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xfffcc001)),
                  )
                : messages.isEmpty
                ? Center(
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
                            text(context, 'Start the conversation!'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            text(
                              context,
                              'Send the first message to your group.',
                            ),
                          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onLongPress: isMine ? () => _showMessageOptions(message) : null,
      child: Padding(
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

            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMine
                      ? isDark
                            ? Color(0xfffcc001)
                            : Color(0xfffcc001)
                      : Color.fromARGB(255, 231, 231, 231),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  border: isMine
                      ? null
                      : Border.all(
                          color: isDark ? Colors.grey : const Color(0xffeeeeee),
                        ),
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
                            color: Color(0xfffcc001),
                          ),
                        ),
                      ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMine
                            ? Color(0xfffcc001)
                            : isDark
                            ? Color(0xff444444)
                            : Color(0xfff5f5f5),
                      ),
                    ),
                    if (time.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 10,
                              color: isMine
                                  ? isDark
                                        ? Colors.black54
                                        : Colors.black54
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isMine) ...[
              const SizedBox(width: 7),
              _buildSenderAvatar(profilePicture),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSenderAvatar(String imageUrl) {
    const double avatarSize = 32;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget defaultAvatar() {
      return ClipOval(
        child: Image.asset(
          isDark ? 'assets/default_pfp_dark.png' : 'assets/default_pfp.jpg',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        color: isDark ? Color(0xff333333) : Colors.white,
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
                  hintText: text(context, 'Message your group...'),
                  filled: true,
                  fillColor: isDark ? Color(0xff333333) : Color(0xfff5f5f5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? Color(0xff333333) : Color(0xfff5f5f5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? Color(0xfffcc001) : Color(0xfffcc001),
                      width: 2,
                    ),
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
