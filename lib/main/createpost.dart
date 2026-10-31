import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hands/widgets/catigory_dropdown.dart';
import 'dart:io';
import 'package:hands/utils/langs.dart';
import 'package:hands/services/payment_service.dart';
import 'package:hands/main/post_credits.dart';

class CreatePostPage extends StatefulWidget {
  final PostService postService;
  final Map<String, dynamic>? post;

  const CreatePostPage({super.key, required this.postService, this.post});

  bool get isEditing => post != null;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  static const Color accent = Color(0xfffcc001);

  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _pictureController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedMedia = [];
  List<Map<String, dynamic>> _existingMedia = [];
  final PaymentService _paymentService = PaymentService();

  int freePostsRemaining = 0;
  int paidPostCredits = 0;

  bool isLoadingCredits = true;

  @override
  void initState() {
    super.initState();

    _loadCredits();

    final post = widget.post;

    if (post != null) {
      _captionController.text = post['caption']?.toString() ?? '';

      selectedCategory = post['category']?.toString();

      final rawMedia = post['media'] ?? post['postMedia'];

      if (rawMedia is List) {
        _existingMedia = rawMedia
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
  }

  Future<void> _loadCredits() async {
    try {
      final data = await _paymentService.getCredits();

      if (!mounted) return;

      setState(() {
        freePostsRemaining = (data['freePostsRemaining'] as num?)?.toInt() ?? 0;

        paidPostCredits = (data['paidPostCredits'] as num?)?.toInt() ?? 0;

        isLoadingCredits = false;
      });
    } catch (e) {
      debugPrint('[CREATE POST] Could not load credits: $e');

      if (!mounted) return;

      setState(() {
        isLoadingCredits = false;
      });
    }
  }

  Future<void> _pickMedia() async {
    try {
      final List<XFile> files = await _picker.pickMultipleMedia(
        limit: 5,
        imageQuality: 80,
      );

      debugPrint('[PICKER] Files returned: ${files.length}');

      if (files.isEmpty) {
        debugPrint('[PICKER] No files selected.');
        return;
      }

      for (final file in files) {
        debugPrint(
          '[PICKER] name=${file.name}, '
          'path=${file.path}, '
          'mimeType=${file.mimeType}, '
          'extension=${file.path.split('.').last}',
        );
      }

      if (!mounted) return;

      setState(() {
        final existingPaths = _selectedMedia.map((f) => f.path).toSet();

        for (final file in files) {
          if (!existingPaths.contains(file.path) && _selectedMedia.length < 5) {
            _selectedMedia.add(file);
          }
        }
      });

      debugPrint('[PICKER] Total selected: ${_selectedMedia.length}');
      debugPrint('=================================\n');
    } catch (e, stackTrace) {
      debugPrint('[PICKER ERROR] $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  final List<String> categories = const [
    'Food',
    'Beauty',
    'Sports',
    'Delivery',
    'Printing & Copying',
    'Lost & Found',
    'Rentals & Borrowing',
    'Questions & Answers',
    'Sewing',
    'Phone & PC Repair',
    'Education',
    'Design',
    'Photography',
    'Video Editing',
    'Hairdressing',
    'Cleaning',
    'Laundry',
    'Handmade',
    'Electronics',
    'Clothing',
    'Jewelry',
    'Exchange',
    'Projects',
    'Programming',
    'Trips',
    'Other',
  ];

  String? selectedCategory;
  bool isSubmitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    _pictureController.dispose();
    super.dispose();
  }

  Future<void> _showNoCreditsDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            textRead(context, 'Free posts finished'),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            textRead(
              context,
              'You have used all your free posts. Buy post credits to continue publishing.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                textRead(context, 'Cancel'),
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfffcc001),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostCreditsPage(onBuyPackage: (packageId) async {}),
                  ),
                );

                if (!mounted) return;

                await _loadCredits();
              },
              child: Text(
                textRead(context, 'Credit posts'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPost() async {
    debugPrint('\n========== SUBMIT POST ==========');
    debugPrint('[SUBMIT] Category: $selectedCategory');
    debugPrint('[SUBMIT] Caption: ${_captionController.text.trim()}');
    debugPrint('[SUBMIT] Selected media count: ${_selectedMedia.length}');
    // Check credits only when creating a new post.
    if (!widget.isEditing) {
      if (isLoadingCredits) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textRead(context, 'Please wait while we check your credits.'),
            ),
          ),
        );
        return;
      }

      // Refresh the balance before deciding whether publishing is allowed.
      await _loadCredits();

      if (!mounted) return;

      if (freePostsRemaining <= 0 && paidPostCredits <= 0) {
        await _showNoCreditsDialog();
        return;
      }
    }
    for (final file in _selectedMedia) {
      debugPrint(
        '[SUBMIT] File=${file.name}, '
        'mime=${file.mimeType}, path=${file.path}',
      );
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('[SUBMIT] Form validation FAILED');
      return;
    }

    if (selectedCategory == null) {
      debugPrint('[SUBMIT] ERROR: category is null');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // STEP 1: Upload newly selected media
      final List<Map<String, dynamic>> uploadedMedia = await widget.postService
          .uploadMedia(_selectedMedia);

      // Keep existing media that the user did not remove.
      final List<Map<String, dynamic>> allMedia = [
        ..._existingMedia,
        ...uploadedMedia,
      ];

      Map<String, dynamic> result;

      if (widget.isEditing) {
        // UPDATE EXISTING POST
        result = await widget.postService.updatePost(
          postId: widget.post!['_id'].toString(),
          category: selectedCategory!,
          caption: _captionController.text.trim(),
          media: allMedia,
        );
      } else {
        // CREATE NEW POST
        result = await widget.postService.createPost(
          category: selectedCategory!,
          caption: _captionController.text.trim(),
          media: allMedia,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, result);
    } catch (error, stackTrace) {
      debugPrint('[SUBMIT ERROR] $error');
      debugPrint('[SUBMIT ERROR TYPE] ${error.runtimeType}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is PostException
                ? text(context, error.message)
                : text(context, 'Could not create post: $error'),
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffffff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditing
              ? text(context, 'Edit post')
              : text(context, 'Create a post'),
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.isEditing
                    ? text(context, 'Update your service details')
                    : text(context, 'Share your service with your residence !'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 24),

              CategoryDropdown(
                selectedCategory: selectedCategory,
                categories: categories,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _captionController,
                maxLength: 300,
                maxLines: 5,
                decoration: _decoration(text(context, 'Caption')).copyWith(
                  hintText: text(context, 'Describe your service...'),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return text(context, 'Caption is required');
                  }
                  if (value.trim().length > 300) {
                    return text(context, 'Maximum 300 characters');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),
              SizedBox(
                height: 55, // Change this value
                width: double.infinity, // Optional: full width
                child: OutlinedButton.icon(
                  onPressed: _pickMedia,
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 26,
                  ),
                  label: Text(
                    text(context, 'Add photos or videos'),
                    style: TextStyle(fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xfffcc001),
                    side: const BorderSide(color: Color(0xfffcc001), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Existing media from the post

              // EXISTING MEDIA FROM THE POST
              if (_existingMedia.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text(context, 'Existing media'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingMedia.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _existingMedia[index];
                      final url = item['url']?.toString() ?? '';
                      final type = item['type']?.toString().toLowerCase() ?? '';
                      final isVideo = type.contains('video');

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: isVideo
                                  ? Container(
                                      color: Colors.black87,
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      url,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: ColoredBox(
                                              color: Color(0xFFF2F2F2),
                                              child: Icon(
                                                Icons.broken_image_outlined,
                                              ),
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _existingMedia.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 19,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          if (isVideo)
                            const Positioned(
                              bottom: 5,
                              left: 5,
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              // NEWLY SELECTED MEDIA
              if (_selectedMedia.isNotEmpty) ...[
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text(context, 'New media'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final file = _selectedMedia[index];
                      final name = file.name.toLowerCase();
                      final isVideo = [
                        '.mp4',
                        '.mov',
                        '.avi',
                        '.mkv',
                        '.webm',
                        '.3gp',
                        '.m4v',
                      ].any((extension) => name.endsWith(extension));

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: isVideo
                                  ? Container(
                                      color: Colors.black87,
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(file.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: ColoredBox(
                                              color: Color(0xFFF2F2F2),
                                              child: Icon(
                                                Icons.broken_image_outlined,
                                              ),
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 19,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          if (isVideo)
                            const Positioned(
                              bottom: 5,
                              left: 5,
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 60),
              if (!widget.isEditing) ...[
                _buildFreePostsInfo(),
                const SizedBox(height: 15),
              ],
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.amber.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xfffcc001),
                          ),
                        )
                      : Text(
                          widget.isEditing
                              ? text(context, 'Save changes')
                              : text(context, 'Publish post'),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview({
    required bool isVideo,
    required VoidCallback onRemove,
    required Widget image,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 120, height: 120, child: image),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 19, color: Colors.redAccent),
            ),
          ),
        ),
        if (isVideo)
          const Positioned(
            bottom: 5,
            left: 5,
            child: Icon(Icons.videocam, color: Colors.white, size: 20),
          ),
      ],
    );
  }

  Widget _buildFreePostsInfo() {
    String message;

    if (isLoadingCredits) {
      message = textRead(context, 'Loading your credits...');
    } else if (freePostsRemaining > 0) {
      message =
          '${textRead(context, 'You still have')} '
          '$freePostsRemaining ${textRead(context, 'free posts')}';
    } else if (paidPostCredits > 0) {
      message =
          '${textRead(context, 'You have')} '
          '$paidPostCredits ${textRead(context, 'paid post credits')}';
    } else {
      message = textRead(
        context,
        'You have no free posts anymore. You need to pay to post.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffcc001).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
