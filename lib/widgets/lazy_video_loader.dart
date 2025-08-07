import 'package:flutter/material.dart';
import 'package:perlaazul/widgets/optimized_video_player.dart';

/// Widget que implementa carga perezosa de videos
/// Solo carga el video cuando está cerca de ser visible
class LazyVideoLoader extends StatefulWidget {
  final String videoUrl;
  final int index;
  final int currentIndex;
  final bool autoPlay;
  
  const LazyVideoLoader({
    super.key,
    required this.videoUrl,
    required this.index,
    required this.currentIndex,
    this.autoPlay = true,
  });

  @override
  State<LazyVideoLoader> createState() => _LazyVideoLoaderState();
}

class _LazyVideoLoaderState extends State<LazyVideoLoader> {
  bool _shouldLoad = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkShouldLoad();
  }

  @override
  void didUpdateWidget(LazyVideoLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _checkShouldLoad();
    }
  }

  void _checkShouldLoad() {
    // Solo cargar si el video está en el índice actual o muy cerca
    final distance = (widget.index - widget.currentIndex).abs();
    final shouldLoad = distance <= 1; // Solo actual y ±1
    
    if (shouldLoad && !_hasLoaded) {
      setState(() {
        _shouldLoad = true;
        _hasLoaded = true;
      });
    } else if (!shouldLoad && distance > 2) {
      // Si el video está muy lejos, liberar recursos
      setState(() {
        _shouldLoad = false;
        // Mantener _hasLoaded = true para evitar recargas innecesarias
      });
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Preparando video...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return _buildPlaceholder();
    }

    return OptimizedVideoPlayer(
      videoUrl: widget.videoUrl,
      autoPlay: widget.autoPlay && widget.index == widget.currentIndex,
      showControls: false,
    );
  }
}
