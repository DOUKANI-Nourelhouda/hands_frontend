import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/services/msgs_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/main/profile.dart';
import 'package:hands/utils/langs.dart';

const Color chatYellow = Color(0xfffcc001);

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPicture;
  final MsgService msgService;
  final PostService postService;
  final IO.Socket socket;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPicture,
    required this.msgService,
    required this.socket,
    required this.postService,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    widget.socket.on('message:new', onNewMessage);
    widget.socket.on('message:error', onMessageError);

    loadMessages();

    // These events must match your backend's Socket.IO handlers.
    widget.socket.emit('conversation:join', {
      'conversationId': widget.conversationId,
    });
  }

  String _id(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }

    return value?.toString() ?? '';
  }

  String _messageConversationId(Map<String, dynamic> message) {
    return _id(message['conversation'] ?? message['conversationId']);
  }

  String _senderId(Map<String, dynamic> message) {
    return _id(message['sender'] ?? message['senderId']);
  }

  String _messageText(Map<String, dynamic> message) {
    return (message['content'] ?? message['text'] ?? '').toString();
  }

  String _senderName(Map<String, dynamic> message) {
    final sender = message['sender'];

    if (sender is Map) {
      return (sender['username'] ?? 'Student').toString();
    }

    return widget.otherUserName;
  }

  String _senderPicture(Map<String, dynamic> message) {
    final sender = message['sender'];

    if (sender is Map) {
      return (sender['profilePicture'] ?? '').toString().trim();
    }

    // If sender details aren't populated, use the other user's picture
    // for received messages and the default avatar for sent messages.
    return _senderId(message) == widget.currentUserId
        ? ''
        : widget.otherUserPicture;
  }

  DateTime? _dateOf(Map<String, dynamic> message) {
    return DateTime.tryParse(
      (message['createdAt'] ?? message['timestamp'] ?? '').toString(),
    );
  }

  void _sortMessages() {
    messages.sort((a, b) {
      final dateA = _dateOf(a);
      final dateB = _dateOf(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return -1;
      if (dateB == null) return 1;

      return dateA.compareTo(dateB);
    });
  }

  void _addMessage(Map<String, dynamic> message) {
    final id = _id(message['_id'] ?? message['id']);

    if (id.isNotEmpty &&
        messages.any((item) => _id(item['_id'] ?? item['id']) == id)) {
      return;
    }

    messages.add(message);
    _sortMessages();
  }

  void onNewMessage(dynamic data) {
    if (data is! Map) return;

    final message = Map<String, dynamic>.from(data);
    final receivedConversationId = _messageConversationId(message);

    // Ignore messages belonging to another direct conversation.
    if (receivedConversationId != widget.conversationId) return;
    if (!mounted) return;

    setState(() {
      _addMessage(message);
      errorMessage = null;
      isSending = false;
    });

    _scrollToLatest();
  }

  void onMessageError(dynamic data) {
    if (!mounted) return;

    final error = data is Map
        ? (data['message'] ?? 'Could not send message.').toString()
        : 'Could not send message.';

    setState(() {
      errorMessage = error;
      isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> loadMessages() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await widget.msgService.getMessages(widget.conversationId);

      if (!mounted) return;

      setState(() {
        // Merge history with any socket messages received during loading.
        final merged = <String, Map<String, dynamic>>{};

        for (final message in result) {
          final id = _id(message['_id'] ?? message['id']);

          if (id.isNotEmpty) {
            merged[id] = message;
          }
        }

        for (final message in messages) {
          final id = _id(message['_id'] ?? message['id']);

          if (id.isNotEmpty) {
            merged[id] = message;
          }
        }

        messages = merged.values.toList();
        _sortMessages();
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

  Future<void> sendMessage() async {
    final content = messageController.text.trim();

    if (content.isEmpty || isSending) return;

    if (content.length > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages cannot exceed 5000 characters.'),
        ),
      );
      return;
    }

    if (!widget.socket.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected. Please try again.')),
      );
      return;
    }

    setState(() {
      isSending = true;
      errorMessage = null;
    });

    try {
      final sentMessage = await widget.msgService.sendMessage(
        conversationId: widget.conversationId,
        content: content,
      );

      if (!mounted) return;

      setState(() {
        _addMessage(sentMessage);
        isSending = false;
      });

      // Clear only after the HTTP request succeeds.
      messageController.clear();
      _scrollToLatest();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isSending = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send message: $e')));
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      // The list is reversed, so the newest message is at minScrollExtent.
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

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
    widget.socket.off('message:new', onNewMessage);
    widget.socket.off('message:error', onMessageError);

    // Leave the room if your backend implements this event.
    widget.socket.emit('conversation:leave', {
      'conversationId': widget.conversationId,
    });

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
            _buildAvatar(widget.otherUserPicture, size: 42),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.otherUserId.isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(
                        userId: widget.otherUserId,
                        postService: widget.postService,
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.otherUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
                    child: CircularProgressIndicator(color: chatYellow),
                  )
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
                          Text('Send your first message.'),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(10),
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
    final time = _formatTime(message['createdAt'] ?? message['timestamp']);
    final senderPicture = _senderPicture(message);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            _buildAvatar(senderPicture, size: 32),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.70,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? chatYellow : Colors.white,
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
                          color: chatYellow,
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
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
            _buildAvatar(senderPicture, size: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, {required double size}) {
    Widget fallback() {
      return ClipOval(
        child: Image.asset(
          'assets/default_pfp.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imageUrl.trim().isEmpty) {
      return fallback();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
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
                  hintText: 'Message ${widget.otherUserName}...',
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
              icon: const Icon(Icons.send_rounded, color: chatYellow, size: 27),
            ),
          ],
        ),
      ),
    );
  }
}
