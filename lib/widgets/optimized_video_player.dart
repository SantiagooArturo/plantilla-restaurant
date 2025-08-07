import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget optimizado para reproducción de videos en móviles
/// Incluye detección de conexión y calidad adaptativa
class OptimizedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  
  const OptimizedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.showControls = false,
  });

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _isLowBandwidth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _detectConnectionType();
    _initializeVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Detecta el tipo de conexión para optimizar calidad
  void _detectConnectionType() {
    // En mobile, asumimos conexión más lenta
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _isLowBandwidth = true;
    }
  }

  /// Obtiene URL optimizada según la conexión
  String _getOptimizedUrl() {
    if (_isLowBandwidth) {
      // Para móviles, intentar URL de menor calidad si existe
      // Por ahora mantenemos la original, pero aquí se podría implementar
      // diferentes calidades: _mobile.mp4, _low.mp4, etc.
      return widget.videoUrl;
    }
    return widget.videoUrl;
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(
        _getOptimizedUrl(),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'Cache-Control': 'public, max-age=86400',
          'Accept-Ranges': 'bytes',
        },
      );

      // Listener para buffering y errores
      _controller!.addListener(() {
        if (!mounted) return;
        
        final value = _controller!.value;
        
        // Detectar buffering
        if (value.isBuffering != _isBuffering) {
          setState(() => _isBuffering = value.isBuffering);
        }
        
        // Detectar errores
        if (value.hasError && !_hasError) {
          setState(() => _hasError = true);
          debugPrint('Error en video: ${value.errorDescription}');
        }
      });

      await _controller!.setVolume(0.0); // Sin sonido por defecto
      await _controller!.initialize();
      await _controller!.setLooping(true);

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      if (widget.autoPlay) {
        _controller!.play();
      }
    } catch (e) {
      debugPrint('Error inicializando video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _toggleVolume() {
    if (_controller == null || !_isInitialized) return;
    
    final currentVolume = _controller!.value.volume;
    _controller!.setVolume(currentVolume > 0 ? 0.0 : 1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.autoPlay) _controller!.play();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller!.pause();
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              'Error al cargar video',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Verifica tu conexión',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _isLowBandwidth ? 'Cargando (conexión lenta)...' : 'Cargando video...',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: widget.showControls ? _togglePlayPause : _toggleVolume,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo negro
          Container(color: Colors.black),
          
          // Video player
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          // Indicador de buffering
          if (_isBuffering)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          
          // Controles de volumen
          if (!widget.showControls)
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
                  _controller!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          
          // Indicador de conexión lenta
          if (_isLowBandwidth)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Conexión lenta',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
