import 'package:flutter/material.dart';
import 'package:hands/services/user_service.dart';

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
          content: Text('${user['username'] ?? 'User'} has been unblocked.'),
          backgroundColor: Colors.black87,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not unblock user: '
            '${e.toString().replaceFirst('Exception: ', '')}',
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
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: bio.isNotEmpty
            ? Text(
                bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              )
            : null,
        trailing: IconButton(
          tooltip: 'Unblock user',
          onPressed: userId.isEmpty || isRemoving
              ? null
              : () => _unblockUser(user),
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
        const SizedBox(height: 140),
        Icon(Icons.block_outlined, size: 58, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No blocked accounts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Accounts you block will appear here.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
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
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _loadBlockedUsers,
            child: const Text(
              'Try again',
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
        title: const Text(
          'Blocked accounts',
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
