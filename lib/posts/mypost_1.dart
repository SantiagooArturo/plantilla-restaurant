import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

class MyPost extends StatefulWidget {
  final String videoUrl; // URL del video a reproducir
  
  // Constructor con parámetro obligatorio
  const MyPost({super.key, required this.videoUrl});
  
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> with WidgetsBindingObserver {
  // -- VARIABLES --
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _userPaused = false; // Flag para saber si el usuario pausó manualmente
  
  // -- CICLO DE VIDA --
  
  @override
  void initState() {
    super.initState();
    // Registramos observador para cambios de ciclo de vida
    WidgetsBinding.instance.addObserver(this);
    // Iniciamos el reproductor
    _cargarVideo();
  }
  
  @override
  void dispose() {
    // Limpieza para evitar memory leaks
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
  
  // -- MÉTODOS PRIVADOS --
  
  // Carga y prepara el video para reproducción
  Future<void> _cargarVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    
    try {
      // Configuración inicial
      await _controller.initialize();
      await _controller.setLooping(true);
      
      // Truco para web: empezar mudo para evitar bloqueos del navegador
      if (kIsWeb) {
        await _controller.setVolume(0.0);
      } else {
        await _controller.setVolume(1.0);
      }
      
      // Verificar que seguimos en pantalla
      if (!mounted) return;
      
      // Actualizar estado y empezar reproducción
      setState(() {
        _isInitialized = true;
        _userPaused = false;
      });
      
      // Iniciar reproducción inmediatamente
      _controller.play().then((_) {
        // Activar sonido en web después de comenzar
        if (kIsWeb && mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            _controller.setVolume(0.0);
          });
        }
      }).catchError((e) {
        print("Error al reproducir: $e");
      });
    } catch (e) {
      print("Error al inicializar: $e");
    }
  }
  
  // -- GESTIÓN DE CICLO DE VIDA --
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    
    if (state == AppLifecycleState.resumed) {
      // Solo reproducir si no fue pausado por el usuario
      if (!_userPaused) {
        _controller.play();
      }
    } else if (state == AppLifecycleState.paused) {
      // Guardar estado de reproducción actual antes de pausar
      _userPaused = !_controller.value.isPlaying;
      _controller.pause();
    }
  }
  
  // -- CONSTRUCCIÓN DE LA UI --
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isInitialized) return;
        
        // Actualizar flag de pausa manual y cambiar estado
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
            _userPaused = true; // El usuario pausó manualmente
          } else {
            _controller.play();
            _userPaused = false; // El usuario resumió manualmente
          }
        });
      },
      
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo negro base
          Container(color: Colors.black),
          
          // Video player - solo visible cuando está inicializado
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
          
          // Indicador de carga - solo visible durante inicialización
          if (!_isInitialized)
            const Center(child: CircularProgressIndicator()),
          
          // Botón de play - solo visible cuando el usuario pausa manualmente
          if (_isInitialized && _userPaused)
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