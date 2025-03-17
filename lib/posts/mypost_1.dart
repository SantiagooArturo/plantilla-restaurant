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
  
  // -- CICLO DE VIDA --
  
  // Se ejecuta al crear el widget
  @override
  void initState() {
    super.initState();
    // Nos suscribimos para monitorear el ciclo de vida
    WidgetsBinding.instance.addObserver(this);
    // Iniciamos la carga del reproductor
    _arrancarReproductor();
  }
  
  // Limpieza al destruir el widget
  @override
  void dispose() {
    // Cancelamos suscripción y liberamos recursos
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
  
  // -- MÉTODOS PRIVADOS --
  
  // Inicializa y configura el reproductor de video
  Future<void> _arrancarReproductor() async {
    // Crear controlador con la URL recibida
    _controller = VideoPlayerController.network(widget.videoUrl);
    
    try {
      // Configuración básica
      await _controller.initialize();
      await _controller.setLooping(true); // Repetir infinitamente
      
      // TRUCO PARA WEB: iniciar sin sonido evita restricciones
      if (kIsWeb) {
        await _controller.setVolume(0.0);
      } else {
        await _controller.setVolume(1.0);
      }
      
      // Actualizar estado solo si el widget sigue montado
      if (mounted) {
        setState(() => _isInitialized = true);
        
        // Pequeño retraso para asegurar que todo está listo
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return; // Verificación de seguridad
          
          // Intentar reproducir automáticamente
          _controller.play().then((_) {
            // En web, activar sonido después de iniciar
            if (kIsWeb) {
              Future.delayed(const Duration(seconds: 1), () {
                _controller.setVolume(0.0);
              });
            }
          }).catchError((error) {
            // Log en caso de error, pero no mostrar al usuario
            // ignore: avoid_print
            print(" Error de reproducción: $error");
          });
          
          // Actualizar UI
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      // Log en caso de error de inicialización
      // ignore: avoid_print
      print(" Error iniciando video: $e");
    }
  }
  
  // -- GESTIÓN DE CICLO DE VIDA --
  
  // Responder a cambios en el estado de la app (fondo/primer plano)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No hacer nada si el video no está listo
    if (!_isInitialized) return;
    
    // RESUMIDO: App vuelve a primer plano
    if (state == AppLifecycleState.resumed) {
      // Reanudar reproducción si estaba pausado
      if (!_controller.value.isPlaying) {
        _controller.play();
      }
    } 
    // PAUSADO: App va a segundo plano
    else if (state == AppLifecycleState.paused) {
      // Pausar si estaba reproduciéndose
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }
  
  // -- CONSTRUCCIÓN DE LA UI --
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Toggle play/pause al tocar la pantalla
      onTap: () {
        if (!_isInitialized) return;
        
        setState(() {
          // Alternar entre reproducir y pausar
          _controller.value.isPlaying 
              ? _controller.pause() 
              : _controller.play();
        });
      },
      
      // Estructura visual usando un stack para mantener capas 
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo negro para cuando el video no carga(por sea caso no cargue!)
          Container(color: Colors.black),
          
          // Video a pantalla completa (ajustado intentar no tocar ojo por que tiene dimsensiones exatcas)
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
          
          // Indicador de carga mientras se prepara el video
          if (!_isInitialized)
            const Center(child: CircularProgressIndicator()),
          
          // Botón de play cuando está pausado
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