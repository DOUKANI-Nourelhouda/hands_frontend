import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaViewerPage extends StatefulWidget {
  final String url;
  final bool isVideo;

  const MediaViewerPage({super.key, required this.url, required this.isVideo});

  static const Color accent = Color(0xfffcc001);

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    try {
      await _controller.initialize();

      if (!mounted) {
        await _controller.dispose();
        return;
      }

      setState(() {
        _videoInitialized = true;
      });

      await _controller.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _videoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.isVideo && _videoInitialized) {
      _controller.dispose();
    } else if (widget.isVideo && _videoError) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.isVideo ? 'Video' : 'Photo'),
      ),
      body: Center(child: widget.isVideo ? _buildVideo() : _buildImage()),
    );
  }

  Widget _buildImage() {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Image.network(
        widget.url,
        fit: BoxFit.contain,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const Center(
            child: CircularProgressIndicator(color: MediaViewerPage.accent),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
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
                  'Could not load this photo',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideo() {
    if (_videoError) {
      return const Text(
        'Could not load this video.',
        style: TextStyle(color: Colors.white),
      );
    }

    if (!_videoInitialized) {
      return const CircularProgressIndicator(color: MediaViewerPage.accent);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),

            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      if (value.isPlaying) {
                        _controller.pause();
                      } else {
                        if (value.isCompleted) {
                          _controller.seekTo(Duration.zero);
                        }
                        _controller.play();
                      }
                    });
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
                _controller,
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
