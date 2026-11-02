import 'package:flutter/material.dart';
import 'package:hands/services/group_service.dart';
import 'package:hands/services/post_service.dart';
import 'package:hands/utils/langs.dart';
import 'package:hands/main/profile.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  final GroupService groupService;
  final PostService postService;
  final Future<void> Function(String recipientId)? onMessageTap;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.groupService,
    required this.postService,
    this.onMessageTap,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Map<String, dynamic>? group;
  bool isLoading = true;
  bool isUpdating = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _id(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  List<Map<String, dynamic>> get _members {
    final raw = group?['members'];

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool get _isCreator {
    return _id(group?['createdBy']) == widget.currentUserId;
  }

  @override
  void initState() {
    super.initState();
    loadGroup();
  }

  Future<void> loadGroup() async {
    try {
      final result = await widget.groupService.getGroupDetails(widget.groupId);

      if (!mounted) return;

      setState(() {
        group = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openProfile(String userId) async {
    if (userId.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          userId: userId,
          postService: widget.postService,
          onMessageTap: widget.onMessageTap,
        ),
      ),
    );
  }

  Future<void> _removeMember(Map<String, dynamic> member) async {
    final memberId = _id(member);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
        title: Text(textRead(context, 'Remove member?')),
        content: Text(
          textRead(context, 'Are you sure you want to remove this member?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              textRead(context, 'Cancel'),
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF333333),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              textRead(context, 'Remove'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => isUpdating = true);

    try {
      final updatedGroup = await widget.groupService.removeMember(
        widget.groupId,
        memberId,
      );

      if (!mounted) return;

      setState(() {
        group = updatedGroup;
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(textRead(context, 'Member removed successfully.')),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _showAddMembersDialog() async {
    List<Map<String, dynamic>> results = [];
    bool searching = false;
    bool adding = false;
    String? searchError;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            Future<void> search(String value) async {
              if (value.trim().isEmpty) {
                setDialogState(() {
                  results = [];
                  searchError = null;
                });
                return;
              }

              setDialogState(() {
                searching = true;
                searchError = null;
              });

              try {
                final found = await widget.groupService.searchStudents(value);

                final existingIds = _members.map(_id).toSet();

                if (!dialogContext.mounted) return;

                setDialogState(() {
                  results = found.where((user) {
                    return !existingIds.contains(_id(user));
                  }).toList();
                  searching = false;
                });
              } catch (e) {
                if (!dialogContext.mounted) return;

                setDialogState(() {
                  searching = false;
                  searchError = e.toString();
                });
              }
            }

            Future<void> addStudent(Map<String, dynamic> student) async {
              final studentId = _id(student);
              if (studentId.isEmpty) return;

              setDialogState(() => adding = true);

              try {
                final updatedGroup = await widget.groupService.addMembers(
                  widget.groupId,
                  [studentId],
                );

                if (!mounted || !dialogContext.mounted) return;

                setState(() => group = updatedGroup);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      textRead(this.context, 'Member added successfully.'),
                    ),
                  ),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;

                setDialogState(() => adding = false);

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(SnackBar(content: Text('$e')));
              }
            }

            return AlertDialog(
              title: Text(textRead(context, 'Add members')),
              backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: search,
                      decoration: InputDecoration(
                        hintText: textRead(context, 'Search ...'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0XFFFCC001),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (searching)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Color(0xfffcc001),
                        ),
                      )
                    else if (searchError != null)
                      Text(
                        searchError!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (results.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            textRead(context, 'Search for students to add.'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final student = results[index];

                            final username =
                                student['username']?.toString() ?? 'Student';

                            final profilePicture =
                                student['profilePicture']?.toString() ?? '';

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Color(0xFF444444)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? Color(0xFF444444)
                                      : Color(0xFFF0F0F0),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.07),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 23,
                                  backgroundColor: const Color(0xFFFFF2C2),
                                  backgroundImage: profilePicture.isNotEmpty
                                      ? NetworkImage(profilePicture)
                                      : AssetImage(
                                              isDark
                                                  ? 'assets/default_pfp_dark.png'
                                                  : 'assets/default_pfp.jpg',
                                            )
                                            as ImageProvider,
                                ),

                                title: Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Color(0xFF333333),
                                  ),
                                ),

                                trailing: IconButton(
                                  onPressed: adding
                                      ? null
                                      : () => addStudent(student),
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Color(0xfffcc001),
                                    size: 27,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    textRead(context, 'Close'),
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = _members;
    final groupName = (group?['name'] ?? 'Group').toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff333333) : const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
        foregroundColor: isDark ? Colors.white : Color(0xFF333333),
        elevation: 0.5,
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xfffcc001)),
            )
          : group == null
          ? Center(child: Text(text(context, 'Could not load group details.')))
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          textRead(context, 'Group members'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if (_isCreator)
                        IconButton(
                          onPressed: isUpdating ? null : _showAddMembersDialog,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xfffcc001),
                            size: 27,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUpdating)
                  const LinearProgressIndicator(color: Color(0xfffcc001)),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      final memberId = _id(member);
                      final username =
                          member['username']?.toString() ?? 'Student';
                      final profilePicture =
                          member['profilePicture']?.toString() ?? '';

                      final isMemberCreator =
                          memberId == _id(group?['createdBy']);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF444444) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Color(0xFF444444)
                                : Color(0xFFF0F0F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : Colors.black.withValues(alpha: 0.07),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            if (memberId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    textRead(
                                      context,
                                      'Could not open this profile.',
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            _openProfile(memberId);
                          },

                          leading: CircleAvatar(
                            radius: 23,
                            backgroundColor: const Color(0xFFFFF2C2),
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : AssetImage(
                                        isDark
                                            ? 'assets/default_pfp_dark.png'
                                            : 'assets/default_pfp.jpg',
                                      )
                                      as ImageProvider,
                          ),

                          title: Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Color(0xFF333333),
                            ),
                          ),

                          subtitle: isMemberCreator
                              ? Text(
                                  textRead(context, 'Group creator'),
                                  style: const TextStyle(
                                    color: Color(0xfffcc001),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : null,

                          // Only the group creator can remove other members.
                          trailing: _isCreator && !isMemberCreator
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                  onPressed: isUpdating
                                      ? null
                                      : () => _removeMember(member),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
