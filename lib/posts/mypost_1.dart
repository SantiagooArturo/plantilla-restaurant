import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

/// Widget que maneja la reproducción de videos individuales
/// Implementa optimizaciones para carga rápida y manejo eficiente de recursos
class MyPost extends StatefulWidget {
  final String videoUrl;
  
  const MyPost({
    super.key, 
    required this.videoUrl,
  });
  
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    
    try {
      // Inicializar con volumen 0 para permitir autoplay
      await _controller.setVolume(0.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
      
      _controller.play();
      
    } catch (e) {
      debugPrint("Error al inicializar: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.play();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller.pause();
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isInitialized) return;
        
        if (_controller.value.volume > 0) {
          _controller.setVolume(0.0);
        } else {
          _controller.setVolume(1.0);
        }
      },
      
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          
          if (_isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          
          if (!_isInitialized || _isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          
          // Indicador de sonido
          if (_isInitialized)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}