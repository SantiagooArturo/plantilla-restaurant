import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyPost extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay; // Nuevo parámetro

  const MyPost({
    Key? key, 
    required this.videoUrl,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true; // Mantener el estado del video al hacer scroll

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(1.0);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        if (widget.autoPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      print("Error inicializando video: $e");
    }
  }

  @override
  void didUpdateWidget(MyPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Este es el punto clave - responde a cambios en autoPlay
    if (widget.autoPlay != oldWidget.autoPlay) {
      if (widget.autoPlay && _isInitialized) {
        _controller.play();
      } else if (!widget.autoPlay && _isInitialized) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    
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