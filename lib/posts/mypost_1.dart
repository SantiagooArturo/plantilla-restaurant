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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            // Forzar reproducción inmediata después de inicializar
            _controller.play();
          });
        }
      })
      ..setLooping(true)
      ..setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

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
          Container(color: Colors.black),
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
          if (!_isInitialized)
            const Center(child: CircularProgressIndicator()),
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