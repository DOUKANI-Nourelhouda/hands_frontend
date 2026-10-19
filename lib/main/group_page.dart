import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../services/group_service.dart';
import 'group_chat_page.dart';

const Color handsYellow = Color(0xfffcc001);

class GroupsPage extends StatefulWidget {
  final GroupService groupService;
  final IO.Socket socket;
  final String currentUserId;

  const GroupsPage({
    super.key,
    required this.groupService,
    required this.socket,
    required this.currentUserId,
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
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Groups',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: loadGroups, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: handsYellow,
        foregroundColor: Colors.black,
        onPressed: openCreateGroup,
        child: const Icon(Icons.group_add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                child: const Text('Try again'),
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
              const Text(
                'No groups yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a study group or a group to connect with students '
                'in your residence.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: openCreateGroup,
                icon: const Icon(Icons.add),
                label: const Text('Create a group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: handsYellow,
                  foregroundColor: Colors.black,
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
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xffeeeeee)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xfffff1bf),
                child: const Icon(Icons.groups, color: Colors.black87),
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
                    const SnackBar(content: Text('Invalid group ID')),
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

      // Hide the current result if it is already selected.
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
      showMessage('Enter a group name.');
      return;
    }

    if (name.length > 60) {
      showMessage('Group name must be 60 characters or fewer.');
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
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        title: const Text('Create a group'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: nameController,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: 'Group name',
                hintText: 'e.g. Study Group',
                prefixIcon: const Icon(Icons.groups_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: searchStudents,
              decoration: InputDecoration(
                hintText: 'Search students',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
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
                  '${selected.length} student(s) selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (searchError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(searchError!),
            ),
          Expanded(
            child: ListView(
              children: [
                ...selected.values.map((user) {
                  final id = studentId(user);

                  return CheckboxListTile(
                    value: true,
                    activeColor: handsYellow,
                    checkColor: Colors.black,
                    title: Text(studentName(user)),
                    secondary: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xfff5f5f5),
                      backgroundImage: studentPicture(user).isNotEmpty
                          ? NetworkImage(studentPicture(user))
                          : const AssetImage('assets/default_pfp.jpg')
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
                        checkColor: Colors.black,
                        title: Text(studentName(user)),
                        secondary: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xfff5f5f5),
                          backgroundImage: studentPicture(user).isNotEmpty
                              ? NetworkImage(studentPicture(user))
                              : const AssetImage('assets/default_pfp.jpg')
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
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No students found.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: creating ? null : createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: handsYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: creating
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Create group',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
