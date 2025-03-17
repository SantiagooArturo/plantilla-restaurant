import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:perlaazul/posts/mypost_1.dart';

class CevichesPage extends StatefulWidget {
  final int? initialDishId;
  
  const CevichesPage({
    super.key,
    this.initialDishId,
  });

  @override
  _CevichesPageState createState() => _CevichesPageState();
}

class _CevichesPageState extends State<CevichesPage> {
  late PageController _controller;
  List<dynamic> _videoList = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final String response = await rootBundle.loadString('assets/ceviches.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      _videoList = data;
    });

    // Si tenemos un ID inicial, buscamos su índice y movemos el PageController a esa posición
    if (widget.initialDishId != null) {
      final initialIndex = _videoList.indexWhere((video) => video['id'] == widget.initialDishId);
      if (initialIndex != -1) {
        _controller = PageController(initialPage: initialIndex);
      }
    } else {
      _controller = PageController(initialPage: 0);
    }
  }

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
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'Garamond', fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
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
              itemBuilder: (context, index) {
                final video = _videoList[index];
                final bool isSpicy = video['spicy'] ?? false;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(child: MyPost(videoUrl: video['videoUrl'])),
                    // Info & List Buttons (Switched Positions)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        children: [
                          // Info Button (Moved to the Left)
                          GestureDetector(
                            onTap: () => _showIngredients(context, video['title'], video['ingredients'], isSpicy),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8), // Adjusted margin for spacing
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
                          // List Button (Moved to the Right)
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
                    // Title, Spicy Indicator, Description, and Price overlay
                    Positioned(
                      bottom: 100,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with Spicy Indicator
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
                          // Description
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
                          // Price
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