import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyPost extends StatefulWidget {
  final String videoUrl; // Accepts a video URL

  const MyPost({super.key, required this.videoUrl});

  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  late VideoPlayerController _controller;
  bool _isInitialized = false; // Track if video is initialized

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) { // ✅ Prevent errors if widget was removed before initialization
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      })
      ..setLooping(true)
      ..setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.pause(); // ✅ Pause video before disposing to prevent errors
    _controller.dispose();
    super.dispose();
  }

  @override
 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      if (_isInitialized) {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      }
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Black background while loading
        Container(color: Colors.black),
        // Video player (only shows if initialized)
        if (_isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        // Loading indicator if video isn't ready
        if (!_isInitialized)
          const Center(child: CircularProgressIndicator()),
        // Play/Pause overlay icon (shows only when paused)
        if (_isInitialized && !_controller.value.isPlaying)
          const Icon(
            Icons.play_arrow,
            size: 80,
            color: Colors.white,
          ),
      ],
    ),
  );
}
}