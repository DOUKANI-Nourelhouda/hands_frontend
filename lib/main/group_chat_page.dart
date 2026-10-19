import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

    widget.socket.on('group:message:new', onNewMessage);
    widget.socket.on('group:error', onGroupError);

    loadMessages();

    // The backend verifies membership before joining the room.
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
    if (_id(message['group']) != widget.groupId) return;

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
        messages = result;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected. Check your internet connection.'),
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
      errorMessage = null;
    });

    widget.socket.emit('group:message:send', {
      'groupId': widget.groupId,
      'text': text,
    });

    messageController.clear();

    // The server's group:error or group:message:new event will
    // update the sending state.
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
            const CircleAvatar(
              backgroundColor: Color(0xfffff1bf),
              child: Icon(Icons.groups, color: Colors.black87),
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
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Material(
              color: const Color(0xfffff0f0),
              child: Padding(
                padding: const EdgeInsets.all(10),
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
                    padding: const EdgeInsets.all(14),
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

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? groupChatYellow : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: const Color(0xffeeeeee)),
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
              style: IconButton.styleFrom(
                backgroundColor: groupChatYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(46, 46),
              ),
              icon: isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
