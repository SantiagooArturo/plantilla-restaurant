import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:perlaazul/posts/mypost_1.dart';

/// Página que muestra los fondos disponibles en el menú
/// Implementa carga optimizada de videos para mejor rendimiento
class FondosPage extends StatefulWidget {
  /// ID opcional del plato a mostrar inicialmente
  /// Se utiliza cuando se navega desde la lista del menú para mostrar un fondo específico
  final int? initialDishId;
  
  const FondosPage({
    super.key,
    this.initialDishId,
  });

  @override
  _FondosPageState createState() => _FondosPageState();
}

class _FondosPageState extends State<FondosPage> {
  // ===== Variables de estado y configuración =====
  late PageController _controller;
  List<dynamic> _videoList = [];
  final Map<int, MyPost> _videoCache = {};
  int _currentIndex = 0;
  static const int _preloadWindow = 1;
  final Set<int> _preloadedIndices = {};

  // ===== Métodos del ciclo de vida =====
  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoCache.clear();
    _preloadedIndices.clear();
    super.dispose();
  }

  // ===== Métodos para gestión de datos y videos =====
  /// Carga los datos de los platos desde JSON y configura la página inicial
  Future<void> _loadVideos() async {
    try {
      final String response = await rootBundle.loadString('assets/fondos.json');
      final List<dynamic> data = json.decode(response);

      if (!mounted) return;

      setState(() {
        _videoList = data;
      });

      // Determinar el índice inicial basado en initialDishId (si existe)
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

  /// Precarga videos adyacentes al índice actual para mejorar rendimiento
  Future<void> _preloadAdjacentVideos(int index) async {
    if (_videoList.isEmpty) return;
    
    // Calcula el rango de índices a precargar
    final startIndex = (index - _preloadWindow).clamp(0, _videoList.length - 1);
    final endIndex = (index + _preloadWindow).clamp(0, _videoList.length - 1);

    // Precargar videos en el rango
    for (var i = startIndex; i <= endIndex; i++) {
      if (!_preloadedIndices.contains(i)) {
        _videoCache[i] = MyPost(videoUrl: _videoList[i]['videoUrl']);
        _preloadedIndices.add(i);
      }
    }

    // Limpieza: eliminar videos fuera del rango de precarga
    _videoCache.removeWhere((key, _) {
      if (key < startIndex - 1 || key > endIndex + 1) {
        _preloadedIndices.remove(key);
        return true;
      }
      return false;
    });
  }

  /// Obtiene o crea un widget de video para un índice específico
  Widget _getVideoWidget(int index) {
    if (!_videoCache.containsKey(index)) {
      _videoCache[index] = MyPost(videoUrl: _videoList[index]['videoUrl']);
      _preloadedIndices.add(index);
    }
    return _videoCache[index]!;
  }

  // ===== Métodos de UI =====
  /// Muestra un diálogo con los ingredientes del plato
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
                // Título del plato
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Garamond', fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // Indicador de picante si aplica
                if (isSpicy)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red, size: 18),
                        SizedBox(width: 5),
                        Text(
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
                  children: ingredients.map((ingredient) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.lightBlue[100], borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      ingredient,
                      style: const TextStyle(fontFamily: 'Garamond', fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  )).toList(),
                ),
                
                // Botón de cerrar
                const SizedBox(height: 15),
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

  /// Muestra un diálogo con la información del restaurante
  void _showRestaurantInfo(BuildContext context) {
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
                // Encabezado con logo y nombre
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E4975).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.restaurant, color: Color(0xFF0E4975), size: 30),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Perla Azul Restaurant",
                        style: TextStyle(
                          fontFamily: 'Garamond',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Ubicación
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF0E4975), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Av. Carlos Valderrama 693, Trujillo 13008",
                        style: TextStyle(
                          fontFamily: 'Garamond',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Teléfono
                const Row(
                  children: [
                    Icon(Icons.phone, color: Color(0xFF0E4975), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "+51 975 123 456",
                      style: TextStyle(
                        fontFamily: 'Garamond',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Horario de atención
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time, color: Color(0xFF0E4975), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Lunes a Domingo: 12:00 PM - 10:00 PM",
                        style: TextStyle(
                          fontFamily: 'Garamond',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Especialidad
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: Color(0xFF0E4975), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Especialidad en mariscos y pescados frescos",
                        style: TextStyle(
                          fontFamily: 'Garamond',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // Botón para cerrar
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0E4975),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        fontFamily: 'Garamond',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
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
                    // 1. Video de fondo del plato
                    Positioned.fill(child: _getVideoWidget(index)),
                    
                    // 2. Botón de lista en la esquina superior derecha
                    Positioned(
                      top: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => GoRouter.of(context).go('/listPage'),
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
                    ),
                    
                    // 3. Botón de información del restaurante
                    Positioned(
                      top: 20,
                      right: 70,
                      child: GestureDetector(
                        onTap: () => _showRestaurantInfo(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
                          ),
                          child: const Center(
                            child: Icon(Icons.help, color: Color(0xFF0E4975), size: 24),
                          ),
                        ),
                      ),
                    ),
                    
                    // 4. Información del plato
                    Positioned(
                      bottom: 100,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 4.1. Título, indicador de picante y botón de información
                          Row(
                            children: [
                              // Título con Expanded para manejar textos largos
                              Expanded(
                                child: Text(
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
                              ),
                              
                              // Indicador de picante si aplica
                              const SizedBox(width: 8),
                              if (isSpicy) const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                              
                              // Botón de información
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showIngredients(context, video['title'], video['ingredients'], isSpicy),
                                child: Container(
                                  width: 40,
                                  height: 40,
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
                            ],
                          ),
                          
                          // 4.2. Descripción del plato
                          const SizedBox(height: 4),
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
                          
                          // 4.3. Precio del plato
                          const SizedBox(height: 4),
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
}