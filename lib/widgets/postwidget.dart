import 'package:flutter/material.dart';
import 'package:hands/main/media_viewer_page.dart';
import 'package:hands/services/post_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/main/createpost.dart';
import 'package:hands/services/user_service.dart';
import 'package:hands/utils/langs.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final PostService postService;
  final String currentUserId;
  final void Function(String postId)? onPostReported;
  final void Function(Map<String, dynamic> post)? onPostUpdated;
  final void Function(String userId)? onUserBlocked;
  final Future<void> Function(Map<String, dynamic> post)? onOpenChat;
  final String searchQuery;
  const PostWidget({
    super.key,
    required this.post,
    required this.postService,
    required this.currentUserId,
    this.onPostReported,
    this.onPostUpdated,
    this.onUserBlocked,
    this.onOpenChat,
    this.searchQuery = '',
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  static const Color accent = Color(0xfffcc001);
  late final TextEditingController _commentController = TextEditingController();
  Map<String, dynamic> get post => widget.post;

  bool _isLiked = false;
  bool _isLiking = false;
  int _likeCount = 0;
  int _commentCount = 0;

  String get _postId => (post['_id'] ?? post['id'] ?? '').toString();

  String _idOf(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  final UserService userService = UserService();
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final likes = post['likes'] is List ? post['likes'] as List : [];

    final comments = post['comments'] is List ? post['comments'] as List : [];

    _likeCount = likes.length;
    _commentCount = comments.length;

    _isLiked = likes.any((like) => _idOf(like) == widget.currentUserId);
  }

  Future<bool> _showBlockUserDialog(String username) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff333333) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            textRead(context, 'Block user?'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xff333333),
            ),
          ),
          content: Text(
            textRead(
              context,
              'Are you sure you want to block $username? '
              'Their posts will no longer appear in your feed.',
            ),
            style: TextStyle(color: isDark ? Colors.white : Color(0xff333333)),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: isDark ? Color(0xff333333) : Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                textRead(context, 'Block'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _toggleLike() async {
    if (_isLiking || _postId.isEmpty) return;

    final wasLiked = _isLiked;
    setState(() => _isLiking = true);

    try {
      final result = wasLiked
          ? await widget.postService.unlikePost(_postId)
          : await widget.postService.likePost(_postId);

      if (!mounted) return;

      setState(() {
        _isLiked = result['likedByMe'] as bool? ?? !wasLiked;
        _likeCount =
            result['likesCount'] as int? ?? (_likeCount + (wasLiked ? -1 : 1));
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textRead(context, 'Could not update like: $e'))),
      );
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _openComments() async {
    if (_postId.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<Map<String, dynamic>> loadedComments;

    try {
      loadedComments = await widget.postService.getComments(_postId);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(textRead(context, 'Could not load comments: $e')),
        ),
      );
      return;
    }

    if (!mounted) return;

    var comments = loadedComments;
    var sending = false;

    bool isSheetClosing = false;
    try {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: isDark ? Color(0xff333333) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (sheetContext) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                isSheetClosing = true;
              }
            },
            child: StatefulBuilder(
              builder: (sheetContext, setSheetState) {
                final keyboardHeight = MediaQuery.of(
                  sheetContext,
                ).viewInsets.bottom;
                final screenHeight = MediaQuery.of(sheetContext).size.height;

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: SizedBox(
                    height: screenHeight * 0.7,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 0),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color(0xff333333)
                                  : Color(0xFFD0D0D0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // HEADER
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Text(
                            textRead(context, 'Comments'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xff333333),
                            ),
                          ),
                        ),

                        Divider(
                          height: 1,
                          color: isDark ? Colors.grey : Color(0xFFEEEEEE),
                        ),

                        // WHITE COMMENTS LIST BACKGROUND
                        Expanded(
                          child: Container(
                            color: isDark ? Color(0xff333333) : Colors.white,
                            child: comments.isEmpty
                                ? Center(
                                    child: Text(
                                      textRead(
                                        context,
                                        'No comments yet. Be the first !',
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: comments.length,
                                    itemBuilder: (context, index) {
                                      final comment = comments[index];

                                      final userData = comment['user'];

                                      final replies =
                                          (comment['replies'] as List? ?? [])
                                              .whereType<Map>()
                                              .map(
                                                (reply) =>
                                                    Map<String, dynamic>.from(
                                                      reply,
                                                    ),
                                              )
                                              .toList();

                                      final user = userData is Map
                                          ? Map<String, dynamic>.from(userData)
                                          : <String, dynamic>{};

                                      final commentId = _idOf(
                                        comment['_id'] ?? comment['id'],
                                      );

                                      final commentUserId = _idOf(
                                        user['_id'] ?? user['id'],
                                      );

                                      final isMyComment =
                                          commentUserId == widget.currentUserId;

                                      final profilePicture =
                                          (user['profilePicture'] ?? '')
                                              .toString()
                                              .trim();

                                      final username =
                                          user['username']?.toString() ??
                                          'Student';
                                      final isDark =
                                          Theme.of(context).brightness ==
                                          Brightness.dark;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          // GRAY BACKGROUND FOR EACH COMMENT
                                          color: isDark
                                              ? Color(0xff444444)
                                              : Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),

                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // CIRCULAR PROFILE PICTURE
                                                ClipOval(
                                                  child: SizedBox(
                                                    width: 44,
                                                    height: 44,
                                                    child:
                                                        profilePicture
                                                            .isNotEmpty
                                                        ? Image.network(
                                                            profilePicture,
                                                            fit: BoxFit.cover,
                                                            width: 44,
                                                            height: 44,
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Image.asset(
                                                                    isDark
                                                                        ? 'assets/default_pfp_dark.png'
                                                                        : 'assets/default_pfp.jpg',
                                                                    width: 44,
                                                                    height: 44,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                },
                                                          )
                                                        : Image.asset(
                                                            isDark
                                                                ? 'assets/default_pfp_dark.png'
                                                                : 'assets/default_pfp.jpg',
                                                            width: 44,
                                                            height: 44,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // USERNAME AND COMMENT
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        textRead(
                                                          context,
                                                          username,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF333333,
                                                                ),
                                                        ),
                                                      ),

                                                      const SizedBox(height: 6),

                                                      Text(
                                                        textRead(
                                                          context,
                                                          comment['content']
                                                                  ?.toString() ??
                                                              '',
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          height: 1.4,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF444444,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // DELETE ICON AT TOP-RIGHT
                                                // THREE-DOT COMMENT MENU
                                                PopupMenuButton<String>(
                                                  tooltip: 'Comment options',
                                                  icon: Icon(
                                                    Icons.more_horiz,
                                                    size: 23,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Color(0xFF777777),
                                                  ),
                                                  color: isDark
                                                      ? Color(0xff333333)
                                                      : Colors.white,
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  onSelected: (action) async {
                                                    if (action == 'edit') {
                                                      final editedText =
                                                          await showDialog<
                                                            String
                                                          >(
                                                            context: context,

                                                            builder: (_) => CommentTextDialog(
                                                              title: textRead(
                                                                context,
                                                                'Edit comment',
                                                              ),
                                                              initialText:
                                                                  comment['content']
                                                                      ?.toString() ??
                                                                  '',
                                                              hintText: textRead(
                                                                context,
                                                                'Edit your comment...',
                                                              ),
                                                              actionLabel:
                                                                  textRead(
                                                                    context,
                                                                    'Save',
                                                                  ),
                                                            ),
                                                          );

                                                      if (!sheetContext
                                                              .mounted ||
                                                          isSheetClosing)
                                                        return;

                                                      if (editedText == null ||
                                                          editedText
                                                              .trim()
                                                              .isEmpty ||
                                                          editedText.trim() ==
                                                              (comment['content']
                                                                          ?.toString() ??
                                                                      '')
                                                                  .trim()) {
                                                        return;
                                                      }

                                                      try {
                                                        final result =
                                                            await widget
                                                                .postService
                                                                .editComment(
                                                                  postId:
                                                                      _postId,
                                                                  commentId:
                                                                      commentId,
                                                                  text: editedText
                                                                      .trim(),
                                                                );

                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;

                                                        final updated =
                                                            result['comment'];

                                                        if (updated is Map) {
                                                          setSheetState(() {
                                                            final updatedComment =
                                                                Map<
                                                                  String,
                                                                  dynamic
                                                                >.from(updated);

                                                            if (!updatedComment
                                                                .containsKey(
                                                                  'replies',
                                                                )) {
                                                              updatedComment['replies'] =
                                                                  comments[index]['replies'] ??
                                                                  [];
                                                            }

                                                            comments[index] =
                                                                updatedComment;
                                                          });
                                                        }
                                                      } catch (e) {
                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              textRead(
                                                                context,
                                                                'Could not edit comment: $e',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else if (action ==
                                                        'reply') {
                                                      final replyText =
                                                          await showDialog<
                                                            String
                                                          >(
                                                            context: context,
                                                            builder: (_) => CommentTextDialog(
                                                              title:
                                                                  textRead(
                                                                    context,
                                                                    'Reply to ',
                                                                  ) +
                                                                  '$username',

                                                              hintText: textRead(
                                                                context,
                                                                'Write a reply...',
                                                              ),
                                                              actionLabel:
                                                                  textRead(
                                                                    context,
                                                                    'Reply',
                                                                  ),
                                                            ),
                                                          );

                                                      if (!sheetContext
                                                              .mounted ||
                                                          isSheetClosing)
                                                        return;
                                                      if (replyText == null ||
                                                          replyText
                                                              .trim()
                                                              .isEmpty)
                                                        return;

                                                      try {
                                                        final result =
                                                            await widget
                                                                .postService
                                                                .replyToComment(
                                                                  postId:
                                                                      _postId,
                                                                  commentId:
                                                                      commentId,
                                                                  text: replyText
                                                                      .trim(),
                                                                );

                                                        final refreshedComments =
                                                            await widget
                                                                .postService
                                                                .getComments(
                                                                  _postId,
                                                                );

                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;

                                                        setSheetState(() {
                                                          comments =
                                                              refreshedComments;
                                                        });

                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              textRead(
                                                                context,
                                                                result['message']
                                                                        ?.toString() ??
                                                                    'Reply added successfully',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              textRead(
                                                                context,
                                                                'Could not reply: $e',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else if (action ==
                                                        'delete') {
                                                      final confirmed = await showDialog<bool>(
                                                        context: context,
                                                        builder: (dialogContext) => AlertDialog(
                                                          backgroundColor:
                                                              isDark
                                                              ? Color(
                                                                  0xFF333333,
                                                                )
                                                              : Colors.white,
                                                          title: Text(
                                                            textRead(
                                                              context,
                                                              'Delete comment?',
                                                            ),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xff333333,
                                                                    ),
                                                            ),
                                                          ),
                                                          content: Text(
                                                            textRead(
                                                              context,
                                                              'This action cannot be undone.',
                                                            ),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xff333333,
                                                                    ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    dialogContext,
                                                                    false,
                                                                  ),
                                                              child: Text(
                                                                textRead(
                                                                  context,
                                                                  'Cancel',
                                                                ),
                                                                style: TextStyle(
                                                                  color: isDark
                                                                      ? Colors
                                                                            .white
                                                                      : Color(
                                                                          0xff333333,
                                                                        ),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    dialogContext,
                                                                    true,
                                                                  ),
                                                              child: Text(
                                                                textRead(
                                                                  context,
                                                                  'Delete',
                                                                ),
                                                                style: TextStyle(
                                                                  color: Color(
                                                                    0xfffcc001,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirmed != true ||
                                                          !sheetContext.mounted)
                                                        return;

                                                      try {
                                                        await widget.postService
                                                            .deleteComment(
                                                              postId: _postId,
                                                              commentId:
                                                                  commentId,
                                                            );

                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;

                                                        setSheetState(() {
                                                          comments.removeAt(
                                                            index,
                                                          );
                                                        });

                                                        if (mounted) {
                                                          setState(() {
                                                            _commentCount =
                                                                comments.length;
                                                          });
                                                        }
                                                      } catch (e) {
                                                        if (!sheetContext
                                                                .mounted ||
                                                            isSheetClosing)
                                                          return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              textRead(
                                                                context,
                                                                'Could not delete comment: $e',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    if (isMyComment) ...[
                                                      PopupMenuItem<String>(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              'assets/icons/edit.svg',
                                                              width: 19,
                                                              height: 19,
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xff333333,
                                                                    ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              textRead(
                                                                context,
                                                                'Edit',
                                                              ),
                                                              style: TextStyle(
                                                                color: isDark
                                                                    ? Colors
                                                                          .white
                                                                    : Color(
                                                                        0xff333333,
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              'assets/icons/delete.svg',
                                                              width: 19,
                                                              height: 19,
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xff333333,
                                                                    ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              textRead(
                                                                context,
                                                                'Delete',
                                                              ),
                                                              style: TextStyle(
                                                                color: isDark
                                                                    ? Colors
                                                                          .white
                                                                    : Color(
                                                                        0xff333333,
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    PopupMenuItem<String>(
                                                      value: 'reply',
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/icons/reply.svg',
                                                            width: 19,
                                                            height: 19,
                                                            color: isDark
                                                                ? Colors.white
                                                                : Color(
                                                                    0xff333333,
                                                                  ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            textRead(
                                                              context,
                                                              'Reply',
                                                            ),
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Color(
                                                                      0xff333333,
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            if (replies.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16,
                                                  top: 12,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // REPLIES HEADER
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/icons/reply.svg',
                                                          width: 17,
                                                          height: 17,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff333333,
                                                                ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          textRead(
                                                            context,
                                                            'Replies',
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? Colors.white
                                                                : Color(
                                                                    0xFF777777,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),

                                                    ...replies.map((reply) {
                                                      final replyUserData =
                                                          reply['user'];

                                                      final replyUser =
                                                          replyUserData is Map
                                                          ? Map<
                                                              String,
                                                              dynamic
                                                            >.from(
                                                              replyUserData,
                                                            )
                                                          : <String, dynamic>{};

                                                      final replyId = _idOf(
                                                        reply['_id'] ??
                                                            reply['id'],
                                                      );

                                                      final replyUserId = _idOf(
                                                        replyUser['_id'] ??
                                                            replyUser['id'],
                                                      );

                                                      final isMyReply =
                                                          replyUserId ==
                                                          widget.currentUserId;

                                                      final replyUsername =
                                                          replyUser['username']
                                                              ?.toString() ??
                                                          'Student';

                                                      final replyPicture =
                                                          (replyUser['profilePicture'] ??
                                                                  '')
                                                              .toString()
                                                              .trim();

                                                      return Container(
                                                        width: double.infinity,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isDark
                                                              ? Color(
                                                                  0xff333333,
                                                                )
                                                              : Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // REPLY PROFILE PICTURE
                                                            // CIRCULAR PROFILE PICTURE
                                                            ClipOval(
                                                              child: SizedBox(
                                                                width: 44,
                                                                height: 44,
                                                                child:
                                                                    profilePicture
                                                                        .isNotEmpty
                                                                    ? Image.network(
                                                                        profilePicture,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            44,
                                                                        height:
                                                                            44,
                                                                        errorBuilder:
                                                                            (
                                                                              context,
                                                                              error,
                                                                              stackTrace,
                                                                            ) {
                                                                              return Image.asset(
                                                                                isDark
                                                                                    ? 'assets/default_pfp_dark.png'
                                                                                    : 'assets/default_pfp.jpg',
                                                                                width: 44,
                                                                                height: 44,
                                                                                fit: BoxFit.cover,
                                                                              );
                                                                            },
                                                                      )
                                                                    : Image.asset(
                                                                        isDark
                                                                            ? 'assets/default_pfp_dark.png'
                                                                            : 'assets/default_pfp.jpg',
                                                                        width:
                                                                            44,
                                                                        height:
                                                                            44,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              width: 10,
                                                            ),

                                                            // REPLY USERNAME AND TEXT
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    textRead(
                                                                      context,
                                                                      replyUsername,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          isDark
                                                                          ? Colors.white
                                                                          : Color(
                                                                              0xFF202124,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    reply['content']
                                                                            ?.toString() ??
                                                                        '',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      height:
                                                                          1.4,
                                                                      color:
                                                                          isDark
                                                                          ? Colors.white
                                                                          : Color(
                                                                              0xFF444444,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // REPLY OPTIONS
                                                            if (isMyReply)
                                                              PopupMenuButton<
                                                                String
                                                              >(
                                                                tooltip:
                                                                    'Reply options',
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                constraints:
                                                                    const BoxConstraints(
                                                                      minWidth:
                                                                          40,
                                                                      minHeight:
                                                                          40,
                                                                    ),
                                                                icon: Icon(
                                                                  Icons
                                                                      .more_horiz,
                                                                  size: 21,
                                                                  color: isDark
                                                                      ? Colors
                                                                            .white
                                                                      : Color(
                                                                          0xFF777777,
                                                                        ),
                                                                ),
                                                                color: isDark
                                                                    ? Color(
                                                                        0xff333333,
                                                                      )
                                                                    : Colors
                                                                          .white,
                                                                onSelected: (action) async {
                                                                  if (action ==
                                                                      'edit') {
                                                                    final editedText = await showDialog<String>(
                                                                      context:
                                                                          context,
                                                                      builder: (_) => CommentTextDialog(
                                                                        title: text(
                                                                          context,
                                                                          'Edit reply',
                                                                        ),
                                                                        initialText:
                                                                            reply['content']?.toString() ??
                                                                            '',
                                                                        hintText:
                                                                            'Edit your reply...',
                                                                        actionLabel:
                                                                            'Save',
                                                                      ),
                                                                    );

                                                                    if (!context
                                                                            .mounted ||
                                                                        editedText ==
                                                                            null ||
                                                                        editedText
                                                                            .trim()
                                                                            .isEmpty) {
                                                                      return;
                                                                    }

                                                                    try {
                                                                      await widget.postService.editReply(
                                                                        postId:
                                                                            _postId,
                                                                        commentId:
                                                                            commentId,
                                                                        replyId:
                                                                            replyId,
                                                                        text: editedText
                                                                            .trim(),
                                                                      );

                                                                      final refreshed = await widget
                                                                          .postService
                                                                          .getComments(
                                                                            _postId,
                                                                          );

                                                                      if (!context
                                                                          .mounted)
                                                                        return;

                                                                      setSheetState(() {
                                                                        comments =
                                                                            refreshed;
                                                                      });
                                                                    } catch (
                                                                      e
                                                                    ) {
                                                                      if (!context
                                                                          .mounted)
                                                                        return;

                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(
                                                                            textRead(
                                                                              context,
                                                                              'Could not edit reply: $e',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  } else if (action ==
                                                                      'delete') {
                                                                    final confirmed = await showDialog<bool>(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (
                                                                            dialogContext,
                                                                          ) => AlertDialog(
                                                                            backgroundColor:
                                                                                isDark
                                                                                ? Color(
                                                                                    0xff333333,
                                                                                  )
                                                                                : Colors.white,
                                                                            title: Text(
                                                                              text(
                                                                                context,
                                                                                'Delete reply?',
                                                                              ),
                                                                            ),
                                                                            content: Text(
                                                                              text(
                                                                                context,
                                                                                'This action cannot be undone.',
                                                                              ),
                                                                            ),
                                                                            actions: [
                                                                              TextButton(
                                                                                onPressed: () => Navigator.pop(
                                                                                  dialogContext,
                                                                                  false,
                                                                                ),
                                                                                child: Text(
                                                                                  text(
                                                                                    context,
                                                                                    'Cancel',
                                                                                  ),
                                                                                  style: TextStyle(
                                                                                    color: isDark
                                                                                        ? Colors.white
                                                                                        : Color(
                                                                                            0xff333333,
                                                                                          ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () => Navigator.pop(
                                                                                  dialogContext,
                                                                                  true,
                                                                                ),
                                                                                child: Text(
                                                                                  text(
                                                                                    context,
                                                                                    'Delete',
                                                                                  ),
                                                                                  style: TextStyle(
                                                                                    color: Color(
                                                                                      0xfffcc001,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    );

                                                                    if (confirmed !=
                                                                            true ||
                                                                        !context
                                                                            .mounted) {
                                                                      return;
                                                                    }

                                                                    try {
                                                                      await widget.postService.deleteReply(
                                                                        postId:
                                                                            _postId,
                                                                        commentId:
                                                                            commentId,
                                                                        replyId:
                                                                            replyId,
                                                                      );

                                                                      final refreshed = await widget
                                                                          .postService
                                                                          .getComments(
                                                                            _postId,
                                                                          );

                                                                      if (!context
                                                                          .mounted)
                                                                        return;

                                                                      setSheetState(() {
                                                                        comments =
                                                                            refreshed;
                                                                      });
                                                                    } catch (
                                                                      e
                                                                    ) {
                                                                      if (!context
                                                                          .mounted)
                                                                        return;

                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(
                                                                            text(
                                                                              context,
                                                                              'Could not delete reply: $e',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                itemBuilder: (_) => [
                                                                  PopupMenuItem<
                                                                    String
                                                                  >(
                                                                    value:
                                                                        'edit',
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          'assets/icons/edit.svg',
                                                                          width:
                                                                              19,
                                                                          height:
                                                                              19,
                                                                          color:
                                                                              isDark
                                                                              ? Colors.white
                                                                              : Color(
                                                                                  0xff333333,
                                                                                ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          textRead(
                                                                            context,
                                                                            'Edit',
                                                                          ),
                                                                          style: TextStyle(
                                                                            color:
                                                                                isDark
                                                                                ? Colors.white
                                                                                : Color(
                                                                                    0xff333333,
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem<
                                                                    String
                                                                  >(
                                                                    value:
                                                                        'delete',
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          'assets/icons/delete.svg',
                                                                          width:
                                                                              19,
                                                                          height:
                                                                              19,
                                                                          color:
                                                                              isDark
                                                                              ? Colors.white
                                                                              : Color(
                                                                                  0xff333333,
                                                                                ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          textRead(
                                                                            context,
                                                                            'Delete',
                                                                          ),
                                                                          style: TextStyle(
                                                                            color:
                                                                                isDark
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),

                        Divider(
                          height: 1,
                          color: isDark ? Colors.grey : Color(0xFFEEEEEE),
                        ),

                        // WRITE COMMENT FIELD
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            10,
                            12,
                            16 + MediaQuery.of(sheetContext).padding.bottom,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Color(0xff333333),
                                  ),
                                  controller: _commentController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: text(
                                      context,
                                      'Write a comment...',
                                    ),
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? Color(0xFF333333)
                                        : Color(0xFFF2F2F2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFCC001),
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 11,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // SEND BUTTON
                              IconButton(
                                onPressed: sending || isSheetClosing
                                    ? null
                                    : () async {
                                        if (!sheetContext.mounted ||
                                            isSheetClosing)
                                          return;

                                        final commentText = _commentController
                                            .text
                                            .trim();
                                        if (commentText.isEmpty) return;

                                        setSheetState(() {
                                          sending = true;
                                        });

                                        try {
                                          final result = await widget
                                              .postService
                                              .addComment(
                                                postId: _postId,
                                                text: commentText,
                                              );

                                          if (!sheetContext.mounted ||
                                              isSheetClosing)
                                            return;

                                          final newComment = result['comment'];

                                          if (newComment is Map) {
                                            setSheetState(() {
                                              comments.insert(
                                                0,
                                                Map<String, dynamic>.from(
                                                  newComment,
                                                ),
                                              );
                                            });

                                            _commentController.clear();

                                            if (mounted) {
                                              setState(() {
                                                _commentCount =
                                                    result['commentsCount']
                                                        as int? ??
                                                    comments.length;
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          if (!sheetContext.mounted ||
                                              isSheetClosing)
                                            return;

                                          ScaffoldMessenger.of(
                                            sheetContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Could not add comment: $e',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (sheetContext.mounted &&
                                              !isSheetClosing) {
                                            setSheetState(() {
                                              sending = false;
                                            });
                                          }
                                        }
                                      },
                                icon: const Icon(
                                  Icons.send_rounded,
                                  color: Color(0xFFFCC001),
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } finally {}
  }

  Future<bool?> _showReportPostDialog() async {
    final detailsController = TextEditingController();

    const reasons = <String, String>{
      'inappropriate': 'Inappropriate content',
      'scam': 'Scam or fraud',
      'spam': 'Spam or misleading content',
      'harassment': 'Harassment or bullying',
      'prohibited': 'Prohibited or unsafe service',
      'other': 'Other',
    };

    String selectedReason = 'inappropriate';
    bool isSubmitting = false;
    String? errorMessage;
    bool? submitted;
    try {
      submitted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: isDark ? Color(0xFF333333) : Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                title: Text(
                  textRead(context, 'Report post'),
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textRead(context, 'Why are you reporting this post?'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Color(0xff333333),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...reasons.entries.map((entry) {
                        return RadioListTile<String>(
                          value: entry.key,
                          groupValue: selectedReason,
                          activeColor: const Color(0xfffcc001),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            text(context, entry.value),
                            style: const TextStyle(fontSize: 14),
                          ),
                          onChanged: isSubmitting
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    selectedReason = value;
                                    errorMessage = null;
                                  });
                                },
                        );
                      }),

                      const SizedBox(height: 12),

                      TextField(
                        controller: detailsController,
                        maxLength: 500,
                        maxLines: 4,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          hintText: textRead(
                            context,
                            'Additional details (optional)',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xfffcc001),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          textRead(context, errorMessage!),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    child: Text(
                      textRead(context, 'Cancel'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Color(0xff333333),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfffcc001),
                      foregroundColor: isDark
                          ? Colors.white
                          : Color(0xff333333),
                      disabledBackgroundColor: Colors.amber.shade200,
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                            });

                            try {
                              await widget.postService.reportPost(
                                postId: _postId,
                                reason: selectedReason,
                                details: detailsController.text,
                              );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext, true);
                            } catch (e) {
                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                isSubmitting = false;
                                errorMessage = e is PostException
                                    ? e.message
                                    : textRead(
                                        context,
                                        'Could not submit report. Please try again.',
                                      );
                              });
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xfffcc001),
                            ),
                          )
                        : Text(textRead(context, 'Submit report')),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      detailsController.dispose();
    }
    if (!mounted || submitted != true) return false;

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(textRead(context, 'Report submitted successfully.')),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dynamic userData = post['user'];

    final String postUserId = _idOf(userData);
    final bool isMyPost = postUserId == widget.currentUserId;

    final Map<String, dynamic> user = userData is Map<String, dynamic>
        ? userData
        : userData is Map
        ? Map<String, dynamic>.from(userData)
        : {};

    final String username = user['username']?.toString() ?? 'Student';
    final String profilePicture = user['profilePicture']?.toString() ?? '';
    final String category = post['category']?.toString() ?? 'Other';
    final String caption = post['caption']?.toString() ?? '';

    final List<dynamic> postMedia = post['media'] is List
        ? post['media'] as List<dynamic>
        : [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF333333) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Color(0xFF555555) : const Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Color(0xFF000000).withValues(alpha: 0.035)
                : Color(0xFF000000).withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // USER HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 5),
            child: Row(
              children: [
                _buildAvatar(profilePicture, username),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text(context, username),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF8A6800) : Color(0xFFFFF7D6),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          text(context, category),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Color(0xFFFFF7D6)
                                : Color(0xFF8A6800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Post options',
                  color: isDark ? Color(0xFF333333) : Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white : Color(0xFF777777),
                    size: 24,
                  ),

                  onSelected: (action) async {
                    itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(textRead(context, 'Edit post')),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/delete.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(textRead(context, 'Delete post')),
                          ],
                        ),
                      ),
                    ];
                    switch (action) {
                      case 'edit':
                        final result =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreatePostPage(
                                  postService: widget.postService,
                                  post: widget.post,
                                ),
                              ),
                            );

                        if (!context.mounted) return;

                        if (result != null && mounted) {
                          widget.onPostUpdated?.call(result);
                        }
                        break;

                      case 'delete':
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: isDark
                                ? Color(0xFF333333)
                                : Colors.white,
                            title: Text(textRead(context, 'Delete post?')),
                            content: Text(
                              textRead(
                                context,
                                'Are you sure you want to delete this post? This action cannot be undone.',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: Text(
                                  textRead(context, 'Cancel'),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Color(0xff333333),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: Text(
                                  textRead(context, 'Delete'),
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true || !context.mounted) {
                          break;
                        }

                        try {
                          await widget.postService.deletePost(_postId);

                          if (!context.mounted) break;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textRead(context, 'Post deleted successfully.'),
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) break;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textRead(context, 'Could not delete post: $e'),
                              ),
                            ),
                          );
                        }
                        break;

                      case 'report':
                        final reported = await _showReportPostDialog();

                        if (reported == true && mounted) {
                          widget.onPostReported?.call(_postId);
                        }
                        break;

                      case 'block':
                        final confirmed = await _showBlockUserDialog(username);

                        if (!confirmed || !mounted) break;

                        final postUser = widget.post['user'];

                        final String? userId = postUser is Map
                            ? postUser['_id']?.toString()
                            : postUser?.toString();

                        if (userId == null || userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textRead(
                                  context,
                                  'Could not identify this user.',
                                ),
                              ),
                            ),
                          );
                          break;
                        }

                        try {
                          await userService.blockUser(userId);

                          if (!mounted) break;

                          widget.onUserBlocked?.call(userId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textRead(
                                  context,
                                  '$username' +
                                      textRead(context, ' has been blocked.'),
                                ),
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) break;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                textRead(context, 'Could not block user: $e'),
                              ),
                            ),
                          );
                        }

                        break;
                    }
                  },

                  itemBuilder: (context) => [
                    if (isMyPost) ...[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 19),
                            SizedBox(width: 10),
                            Text(textRead(context, 'Edit post')),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              textRead(context, 'Delete post'),
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 19),
                            SizedBox(width: 10),
                            Text(textRead(context, 'Report post')),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(
                              Icons.block_outlined,
                              color: Colors.red,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              textRead(context, 'Block user'),
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // POST CAPTION
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: _highlightSearchText(
                context,
                caption,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white : Color(0xff333333),
                ),
              ),
            ),

          // POST MEDIA (PHOTOS AND VIDEOS)
          if (postMedia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: postMedia.length == 1
                  ? _buildMediaItem(
                      context,
                      postMedia.first,
                      double.infinity,
                      300,
                      0,
                      postMedia,
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: postMedia.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _buildMediaItem(
                            context,
                            postMedia[index],
                            240,
                            180,
                            index,
                            postMedia,
                          );
                        },
                      ),
                    ),
            ),
          // DIVIDER
          Padding(
            padding: EdgeInsets.only(top: 7),
            child: Divider(
              height: 1,
              color: isDark ? Colors.grey : Color(0xFFEEEEEE),
            ),
          ),

          // LIKE AND COMMENT COUNTS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                // LIKE ICON
                GestureDetector(
                  onTap: _isLiking ? null : _toggleLike,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      _isLiked
                          ? 'assets/icons/full_heart.svg'
                          : 'assets/icons/empty_heart.svg',
                      width: 25,
                      height: 25,
                      colorFilter: ColorFilter.mode(
                        _isLiked
                            ? Colors.red
                            : isDark
                            ? Colors.white
                            : const Color(0xFF666666),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // LIKE COUNT
                Text(
                  '$_likeCount',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF666666),
                  ),
                ),

                const Spacer(),

                // COMMENT ICON
                GestureDetector(
                  onTap: _openComments,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      'assets/icons/comment.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : const Color(0xFF666666),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // COMMENT COUNT
                Text(
                  '$_commentCount',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF666666),
                  ),
                ),

                const Spacer(),

                // share ICON
                // DM ICON
                GestureDetector(
                  onTap: () async {
                    if (widget.onOpenChat != null) {
                      await widget.onOpenChat!(widget.post);
                    }
                  },
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(
                      'assets/icons/send.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : const Color(0xFF666666),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(
    BuildContext context,
    dynamic item,
    double width,
    double height,
    int index,
    List<dynamic> postMedia,
  ) {
    if (item is! Map) {
      return const SizedBox.shrink();
    }

    final String url = item['url']?.toString() ?? '';
    final String type = item['type']?.toString() ?? 'image';

    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isVideo = type.toLowerCase() == 'video';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaViewerPage(
              media: postMedia
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList(),
              initialIndex: index,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          height: height,
          child: isVideo
              ? Container(
                  color: isDark ? Colors.white : Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: isDark ? Colors.black : Colors.white,
                      size: 58,
                    ),
                  ),
                )
              : Image.network(
                  url,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: accent),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? Color(0xFF333333)
                          : const Color(0xFFF5F5F5),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                        size: 35,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String username) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFFFF2C2),
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : AssetImage(
                  isDark
                      ? 'assets/default_pfp_dark.png'
                      : 'assets/default_pfp.jpg',
                )
                as ImageProvider,
    );
  }

  Widget _highlightSearchText(
    BuildContext context,
    String value, {
    int? maxLines,
    TextStyle? style,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = widget.searchQuery.trim();

    final spans = <TextSpan>[];

    if (query.isEmpty || value.isEmpty) {
      spans.add(TextSpan(text: value));
    } else {
      final lowerValue = value.toLowerCase();
      final lowerQuery = query.toLowerCase();

      int start = 0;

      while (true) {
        final matchIndex = lowerValue.indexOf(lowerQuery, start);

        if (matchIndex == -1) {
          if (start < value.length) {
            spans.add(TextSpan(text: value.substring(start)));
          }
          break;
        }

        if (matchIndex > start) {
          spans.add(TextSpan(text: value.substring(start, matchIndex)));
        }

        spans.add(
          TextSpan(
            text: value.substring(matchIndex, matchIndex + query.length),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFE082),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        start = matchIndex + query.length;
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}

class CommentTextDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final String hintText;
  final String actionLabel;

  const CommentTextDialog({
    super.key,
    required this.title,
    this.initialText = '',
    required this.hintText,
    required this.actionLabel,
  });

  @override
  State<CommentTextDialog> createState() => _CommentTextDialogState();
}

class _CommentTextDialogState extends State<CommentTextDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        cursorColor: isDark ? Colors.white : Color(0xFF333333),
        autofocus: true,
        maxLength: 500,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: widget.hintText,

          // Line color when the TextField is not selected
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? Colors.white : Color(0xFf000000),
              width: 1.5,
            ),
          ),

          // Line color when the user taps the TextField
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? Colors.white : Color(0xFF000000), // Hands yellow
              width: 1.5,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            textRead(context, 'Cancel'),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _controller.text.trim());
          },
          child: Text(
            textRead(context, widget.actionLabel),
            style: const TextStyle(color: Color(0xFFFCC001)),
          ),
        ),
      ],
    );
  }
}
