import 'package:flutter/material.dart';
import 'package:hands/services/user_service.dart';
import 'package:hands/utils/langs.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _removingUsers = {};

  static const Color _yellow = Color(0xfffcc001);

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawUsers = await _userService.getBlockedUsers();

      final loadedUsers = rawUsers
          .whereType<Map>()
          .map((user) => Map<String, dynamic>.from(user))
          .toList();

      if (!mounted) return;

      setState(() {
        _blockedUsers = loadedUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(Map<String, dynamic> user) async {
    final userId = (user['_id'] ?? user['id'] ?? '').toString();

    if (userId.isEmpty || _removingUsers.contains(userId)) return;

    setState(() {
      _removingUsers.add(userId);
    });

    try {
      await _userService.unblockUser(userId);

      if (!mounted) return;

      setState(() {
        _blockedUsers.removeWhere(
          (item) => (item['_id'] ?? item['id'] ?? '').toString() == userId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user['username'] ?? 'User'}' +
                textRead(context, 'has been unblocked.'),
          ),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text(
              context,
              'Could not unblock user: '
              '${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _removingUsers.remove(userId);
        });
      }
    }
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    final picture = (user['profilePicture'] ?? '').toString();

    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFFFF2C2),
      backgroundImage: picture.isNotEmpty ? NetworkImage(picture) : null,
      onBackgroundImageError: picture.isNotEmpty ? (_, __) {} : null,
      child: picture.isEmpty
          ? Image.asset(
              'assets/default_pfp.jpg',
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_outline,
                size: 27,
                color: Color(0xFF888888),
              ),
            )
          : null,
    );
  }

  Widget _buildBlockedUser(Map<String, dynamic> user) {
    final username = (user['username'] ?? 'Student').toString();
    final bio = (user['bio'] ?? '').toString();
    final userId = (user['_id'] ?? user['id'] ?? '').toString();
    final isRemoving = _removingUsers.contains(userId);
    Future<void> _confirmUnblockUser(Map<String, dynamic> user) async {
      final username = (user['username'] ?? 'this user').toString();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              textRead(context, 'Unblock account?'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: Text(
              textRead(context, 'Are you sure you want to unblock') +
                  ' $username?',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  textRead(context, 'Cancel'),
                  style: TextStyle(color: Color(0xff333333)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfffcc001),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  textRead(context, 'Unblock'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        await _unblockUser(user);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
        leading: _buildAvatar(user),
        title: Text(
          text(context, username),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: bio.isNotEmpty
            ? Text(
                text(context, bio),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              )
            : null,
        trailing: IconButton(
          tooltip: 'Unblock user',
          onPressed: userId.isEmpty || isRemoving
              ? null
              : () => _confirmUnblockUser(user),
          icon: isRemoving
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _yellow,
                  ),
                )
              : const Icon(Icons.remove_circle, color: Colors.red, size: 27),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 200),
        Icon(Icons.block_outlined, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Center(
          child: Text(
            text(context, 'No blocked accounts'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text(context, _errorMessage ?? 'Something went wrong.'),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _loadBlockedUsers,
            child: Text(
              text(context, 'Try again'),
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          text(context, 'Blocked accounts'),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: _yellow,
        onRefresh: _loadBlockedUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _yellow))
            : _errorMessage != null
            ? _buildErrorState()
            : _blockedUsers.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _blockedUsers.length,
                itemBuilder: (context, index) {
                  return _buildBlockedUser(_blockedUsers[index]);
                },
              ),
      ),
    );
  }
}
