import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:perlaazul/posts/mypost_1.dart';

/// Página que muestra los ceviches disponibles en el menú
/// Implementa carga optimizada de videos para mejor rendimiento
class CevichesPage extends StatefulWidget {
  /// ID opcional del plato a mostrar inicialmente
  /// Se utiliza cuando se navega desde la lista del menú para mostrar un ceviche específico
  final int? initialDishId;
  
  const CevichesPage({
    super.key,
    this.initialDishId,
  });

  @override
  _CevichesPageState createState() => _CevichesPageState();
}

class _CevichesPageState extends State<CevichesPage> {
  // Controlador para manejar la navegación entre videos
  late PageController _controller;
  // Lista que almacena todos los ceviches con sus detalles
  List<dynamic> _videoList = [];
  // Cache de widgets de video para optimizar memoria
  final Map<int, MyPost> _videoCache = {};
  // Índice del video actual
  int _currentIndex = 0;
  // Ventana de precarga (videos antes y después del actual)
  static const int _preloadWindow = 1;
  // Lista para almacenar índices de videos precargados
  final Set<int> _preloadedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    // Limpiamos los recursos al destruir la página
    _controller.dispose();
    _videoCache.clear();
    super.dispose();
  }

  /// Carga los datos de los videos y configura la página inicial
  /// Si se proporciona un initialDishId, muestra el video correspondiente
  Future<void> _loadVideos() async {
    try {
      // Cargamos el archivo JSON con los datos de los ceviches
      final String response = await rootBundle.loadString('assets/ceviches.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        _videoList = data;
      });

      // Configurar página inicial basada en ID o default
      final initialIndex = widget.initialDishId != null
          ? _videoList.indexWhere((video) => video['id'] == widget.initialDishId)
          : 0;
      
      _controller = PageController(
        initialPage: initialIndex != -1 ? initialIndex : 0,
        viewportFraction: 1.0,
      );

      _currentIndex = _controller.initialPage;
      await _preloadAdjacentVideos(_currentIndex);
      
    } catch (e) {
      debugPrint('Error al cargar los videos: $e');
    }
  }

  /// Precarga los videos adyacentes al índice actual
  Future<void> _preloadAdjacentVideos(int index) async {
    if (_videoList.isEmpty) return;
    
    final startIndex = (index - _preloadWindow).clamp(0, _videoList.length - 1);
    final endIndex = (index + _preloadWindow).clamp(0, _videoList.length - 1);

    // Precargar videos en el rango calculado
    for (var i = startIndex; i <= endIndex; i++) {
      if (!_preloadedIndices.contains(i)) {
        _videoCache[i] = MyPost(
          videoUrl: _videoList[i]['videoUrl'],
        );
        _preloadedIndices.add(i);
      }
    }

    // Limpiar videos fuera del rango de precarga
    _videoCache.removeWhere((key, _) {
      if (key < startIndex - 1 || key > endIndex + 1) {
        _preloadedIndices.remove(key);
        return true;
      }
      return false;
    });
  }

  /// Muestra un diálogo con los ingredientes del ceviche seleccionado
  /// Incluye indicador de picante si corresponde
  void _showIngredients(BuildContext context, String title, List<dynamic> ingredients, bool isSpicy) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del ceviche
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Garamond', fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Indicador de picante si corresponde
                if (isSpicy)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.red, size: 18),
                        const SizedBox(width: 5),
                        const Text(
                          "Picante",
                          style: TextStyle(fontFamily: 'Garamond', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                // Lista de ingredientes
                const Text("Ingredientes", style: TextStyle(fontFamily: 'Garamond', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ingredients
                      .map(
                        (ingredient) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.lightBlue[100], borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontFamily: 'Garamond', fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 15),
                // Botón para cerrar el diálogo
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: _videoList.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _preloadAdjacentVideos(index);
              },
              itemBuilder: (context, index) {
                final video = _videoList[index];
                final bool isSpicy = video['spicy'] ?? false;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video principal
                    Positioned.fill(child: _getVideoWidget(index)),
                    // Botones de información y lista en la parte superior
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        children: [
                          // Botón de información (ingredientes)
                          GestureDetector(
                            onTap: () => _showIngredients(context, video['title'], video['ingredients'], isSpicy),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
                              ),
                              child: const Center(
                                child: Icon(Icons.info_outline, color: Color(0xFF0E4975), size: 24),
                              ),
                            ),
                          ),
                          // Botón para volver a la lista
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).go('/listPage');
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
                              ),
                              child: const Center(
                                child: Icon(Icons.list, color: Color(0xFF0E4975), size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Información del ceviche en la parte inferior
                    Positioned(
                      bottom: 100,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título con indicador de picante
                          Row(
                            children: [
                              Text(
                                video['title'],
                                style: const TextStyle(
                                  fontFamily: 'Garamond',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(width: 8),
                              if (isSpicy) const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Descripción del ceviche
                          Text(
                            video['description'],
                            style: const TextStyle(
                              fontFamily: 'Garamond',
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))],
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          // Precio del ceviche
                          Text(
                            "S/ ${video['price']}",
                            style: const TextStyle(
                              fontFamily: 'Garamond',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))],
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  /// Obtiene o crea el widget de video para un índice
  Widget _getVideoWidget(int index) {
    if (!_videoCache.containsKey(index)) {
      _videoCache[index] = MyPost(
        videoUrl: _videoList[index]['videoUrl'],
      );
      _preloadedIndices.add(index);
    }
    return _videoCache[index]!;
  }
}