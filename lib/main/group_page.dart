import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/services/post_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hands/utils/langs.dart';
import '../services/group_service.dart';
import 'group_chat_page.dart';

const Color handsYellow = Color(0xfffcc001);

class GroupsPage extends StatefulWidget {
  final GroupService groupService;
  final IO.Socket socket;
  final String currentUserId;
  final PostService postService;

  const GroupsPage({
    super.key,
    required this.groupService,
    required this.socket,
    required this.currentUserId,
    required this.postService,
  });

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<Map<String, dynamic>> groups = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await widget.groupService.getGroups();

      if (!mounted) return;
      setState(() {
        groups = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String groupId(Map<String, dynamic> group) =>
      (group['_id'] ?? group['id'] ?? '').toString();

  String groupName(Map<String, dynamic> group) =>
      (group['name'] ?? 'Unnamed group').toString();

  String lastMessage(Map<String, dynamic> group) {
    final last = group['lastMessage'];

    if (last is Map) {
      return (last['text'] ?? last['content'] ?? 'No messages yet').toString();
    }

    return 'No messages yet';
  }

  Future<void> openCreateGroup() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGroupPage(groupService: widget.groupService),
      ),
    );

    if (created == true) {
      await loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
        foregroundColor: isDark ? Colors.white : Color(0xFF333333),
        elevation: 0,
        title: Text(
          text(context, 'Groups'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: loadGroups, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: handsYellow,
        foregroundColor: isDark ? Colors.white : Color(0xFF333333),
        onPressed: openCreateGroup,
        child: const Icon(Icons.group_add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xfffcc001)),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 45),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loadGroups,
                child: Text(text(context, 'Try again')),
              ),
            ],
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                text(context, 'No groups yet'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                text(
                  context,
                  'Create a study group or a group to connect with students '
                  'in your residence.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: openCreateGroup,
                icon: const Icon(Icons.add),
                label: Text(text(context, 'Create a group')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: handsYellow,
                  foregroundColor: isDark ? Colors.white : Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadGroups,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final group = groups[index];

          return Card(
            color: isDark ? Color(0xFF333333) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.grey : Color(0xffeeeeee)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xfffff1bf),
                child: const Icon(Icons.groups, color: Color(0xff333333)),
              ),
              title: Text(
                groupName(group),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  lastMessage(group),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final id = groupId(group);

                if (id.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(text(context, 'Invalid group ID'))),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatPage(
                      groupId: id,
                      groupName: groupName(group),
                      groupService: widget.groupService,
                      socket: widget.socket,
                      currentUserId: widget.currentUserId,
                      postService: widget.postService,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CreateGroupPage extends StatefulWidget {
  final GroupService groupService;

  const CreateGroupPage({super.key, required this.groupService});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final nameController = TextEditingController();
  final searchController = TextEditingController();

  List<Map<String, dynamic>> results = [];
  final Map<String, Map<String, dynamic>> selected = {};

  bool searching = false;
  bool creating = false;
  String? searchError;

  String studentId(Map<String, dynamic> user) =>
      (user['_id'] ?? user['id'] ?? '').toString();

  String studentName(Map<String, dynamic> user) =>
      (user['username'] ?? user['name'] ?? user['fullName'] ?? 'Student')
          .toString();
  String studentPicture(Map<String, dynamic> user) =>
      (user['profilePicture'] ?? '').toString();
  Future<void> searchStudents(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        results = [];
        searchError = null;
        searching = false;
      });
      return;
    }

    setState(() {
      searching = true;
      searchError = null;
    });

    try {
      final users = await widget.groupService.searchStudents(query);

      if (!mounted) return;

      setState(() {
        results = users;
        searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        searching = false;
        searchError = e.toString();
      });
    }
  }

  Future<void> createGroup() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      showMessage(text(context, 'Enter a group name.'));
      return;
    }

    if (name.length > 60) {
      showMessage(text(context, 'Group name must be 60 characters or fewer.'));
      return;
    }
    if (selected.length + 1 < 3) {
      showMessage(
        text(context, 'Select at least 2 students to create a group.'),
      );
      return;
    }
    if (creating) return;

    setState(() => creating = true);

    try {
      await widget.groupService.createGroup(
        name: name,
        memberIds: selected.keys.toList(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => creating = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
      appBar: AppBar(
        title: Text(text(context, 'Create a group')),
        backgroundColor: isDark ? Color(0xFF333333) : Colors.white,
        foregroundColor: isDark ? Colors.white : Color(0xFF333333),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: nameController,
              cursorColor: isDark ? Colors.white : Color(0xff333333),
              maxLength: 60,
              decoration: InputDecoration(
                hintText: text(context, 'Group name'),
                hintStyle: TextStyle(color: Color(0xffC4C4C4)),
                floatingLabelStyle: const TextStyle(color: Color(0xfffcc001)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/icons/groups.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xffC4C4C4),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                filled: true,
                fillColor: isDark ? Color(0xFF333333) : Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xfffcc001),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xfffcc001),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              cursorColor: isDark ? Colors.white : Color(0xff333333),
              onChanged: searchStudents,
              decoration: InputDecoration(
                hintText: text(context, 'Search users'),
                hintStyle: const TextStyle(color: Color(0xffC4C4C4)),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xfffcc001),
                          ),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Color(0xFF333333) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xfffcc001),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xfffcc001),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          if (selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${selected.length} ' + text(context, 'student(s) selected'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (searchError != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(searchError!),
            ),
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 15),
                ...selected.values.map((user) {
                  final id = studentId(user);

                  return CheckboxListTile(
                    value: true,
                    activeColor: handsYellow,
                    checkColor: isDark ? Colors.white : Color(0xff333333),
                    title: Text(studentName(user)),
                    secondary: CircleAvatar(
                      radius: 24,
                      backgroundColor: isDark
                          ? Color(0xFF333333)
                          : Colors.white,
                      backgroundImage: studentPicture(user).isNotEmpty
                          ? NetworkImage(studentPicture(user))
                          : AssetImage(
                                  isDark
                                      ? 'assets/default_pfp_dark.png'
                                      : 'assets/default_pfp.jpg',
                                )
                                as ImageProvider,
                    ),
                    onChanged: (_) {
                      setState(() => selected.remove(id));
                    },
                  );
                }),
                ...results
                    .where((user) {
                      final id = studentId(user);
                      return id.isNotEmpty && !selected.containsKey(id);
                    })
                    .map((user) {
                      final id = studentId(user);

                      return CheckboxListTile(
                        value: selected.containsKey(id),
                        activeColor: handsYellow,
                        checkColor: isDark ? Colors.white : Color(0xFF333333),
                        title: Text(studentName(user)),
                        secondary: CircleAvatar(
                          radius: 24,
                          backgroundColor: isDark
                              ? Color(0xFF333333)
                              : Colors.white,
                          backgroundImage: studentPicture(user).isNotEmpty
                              ? NetworkImage(studentPicture(user))
                              : AssetImage(
                                      isDark
                                          ? 'assets/default_pfp_dark.png'
                                          : 'assets/default_pfp.jpg',
                                    )
                                    as ImageProvider,
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selected[id] = user;
                            } else {
                              selected.remove(id);
                            }
                          });
                        },
                      );
                    }),
                if (!searching &&
                    searchError == null &&
                    searchController.text.trim().isNotEmpty &&
                    results.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      text(context, 'No students found.'),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 25),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: creating ? null : createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: handsYellow,
                    foregroundColor: isDark ? Colors.white : Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: creating
                      ? const CircularProgressIndicator(
                          color: Color(0xfffcc001),
                        )
                      : Text(
                          text(context, 'Create group'),
                          style: TextStyle(
                            fontSize: 22,
                            color: isDark ? Color(0xff333333) : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
