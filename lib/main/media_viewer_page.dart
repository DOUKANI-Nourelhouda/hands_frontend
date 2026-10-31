import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:hands/utils/langs.dart';

class MediaViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> media;
  final int initialIndex;

  const MediaViewerPage({
    super.key,
    required this.media,
    this.initialIndex = 0,
  });

  static const Color accent = Color(0xfffcc001);

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final PageController _pageController;

  int _currentIndex = 0;

  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoError = false;

  Map<String, dynamic> get _currentMedia => widget.media[_currentIndex];

  String get _currentUrl => _currentMedia['url']?.toString() ?? '';

  bool get _isCurrentVideo =>
      _currentMedia['type']?.toString().toLowerCase() == 'video';

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(0, widget.media.length - 1);

    _pageController = PageController(initialPage: _currentIndex);

    _initializeCurrentVideo();
  }

  Future<void> _disposeVideo() async {
    final oldController = _videoController;

    _videoController = null;
    _videoInitialized = false;
    _videoError = false;

    if (oldController != null) {
      await oldController.dispose();
    }
  }

  Future<void> _initializeCurrentVideo() async {
    await _disposeVideo();

    if (!mounted || !_isCurrentVideo || _currentUrl.isEmpty) {
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(_currentUrl));

    _videoController = controller;

    try {
      await controller.initialize();

      if (!mounted || _videoController != controller) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoInitialized = true;
      });

      await controller.play();
    } catch (_) {
      if (!mounted || _videoController != controller) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoError = true;
      });
    }
  }

  Future<void> _onPageChanged(int index) async {
    setState(() {
      _currentIndex = index;
    });

    await _initializeCurrentVideo();
  }

  @override
  void dispose() {
    _pageController.dispose();

    final controller = _videoController;
    _videoController = null;

    if (controller != null) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.media.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            text(context, 'No media available'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_currentIndex + 1} / ${widget.media.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.media.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final item = widget.media[index];
          final url = item['url']?.toString() ?? '';
          final isVideo = item['type']?.toString().toLowerCase() == 'video';

          if (url.isEmpty) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 55,
              ),
            );
          }

          if (isVideo) {
            // Only the current page owns an active video controller.
            if (index != _currentIndex) {
              return const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white70,
                  size: 65,
                ),
              );
            }

            return _buildVideo();
          }

          return _buildImage(url);
        },
      ),
    );
  }

  Widget _buildImage(String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const Center(
              child: CircularProgressIndicator(color: MediaViewerPage.accent),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 55,
                  ),
                  SizedBox(height: 12),
                  Text(
                    text(context, 'Could not load this photo'),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_videoError) {
      return Center(
        child: Text(
          text(context, 'Could not load this video.'),
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (!_videoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: MediaViewerPage.accent),
      );
    }

    final controller = _videoController!;

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),

            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return IconButton(
                  onPressed: () async {
                    if (value.isPlaying) {
                      await controller.pause();
                    } else {
                      if (value.isCompleted) {
                        await controller.seekTo(Duration.zero);
                      }

                      await controller.play();
                    }
                  },
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 65,
                  ),
                );
              },
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: MediaViewerPage.accent,
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
