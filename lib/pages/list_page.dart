import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Modelo que representa un plato del menú
class Dish {
  final int id;
  final String title;
  final String description;
  final String price;
  final List<String> ingredients;
  final bool spicy;
  final String videoUrl; // URL del video del plato

  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.ingredients,
    required this.spicy,
    required this.videoUrl,
  });

  // Crea un plato desde un JSON
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: json['price'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      spicy: json['spicy'] ?? false,
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}

// Widget para mostrar el precio de un plato
class PriceTag extends StatelessWidget {
  final String price;

  const PriceTag({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        'S/ $price',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.green,
        ),
      ),
    );
  }
}

// Widget para mostrar los ingredientes de un plato
class IngredientsList extends StatelessWidget {
  final List<String> ingredients;
  final bool isSpicy;

  const IngredientsList({
    super.key,
    required this.ingredients,
    required this.isSpicy,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...ingredients.map((ingredient) => _IngredientChip(text: ingredient)),
        if (isSpicy) const _SpicyChip(),
      ],
    );
  }
}

// Widget para mostrar un ingrediente individual
class _IngredientChip extends StatelessWidget {
  final String text;

  const _IngredientChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Widget para mostrar el indicador de picante
class _SpicyChip extends StatelessWidget {
  const _SpicyChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            'Picante',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra la información de un plato individual
/// Incluye título, precio, descripción, ingredientes y opción para ver el video
class DishCard extends StatelessWidget {
  final Dish dish;
  final String category;

  const DishCard({
    super.key, 
    required this.dish,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navegación dinámica a la página de categoría correspondiente
            // Se pasa el ID del plato para mostrar el video específico
            switch (category) {
              case 'ceviches':
                context.push('/Ceviches', extra: dish.id);
                break;
              case 'chicharrones':
                context.push('/Chicharrones', extra: dish.id);
                break;
              case 'fondos':
                context.push('/Fondos', extra: dish.id);
                break;
              case 'piqueos':
                context.push('/Piqueos', extra: dish.id);
                break;
              case 'sabadosydomingos':
                context.push('/SabadosYDomingos', extra: dish.id);
                break;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dish.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    PriceTag(price: dish.price),
                  ],
                ),
                if (dish.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    dish.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
                if (dish.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  IngredientsList(
                    ingredients: dish.ingredients,
                    isSpicy: dish.spicy,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver video',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar el título de una categoría
class CategoryHeader extends StatelessWidget {
  final String title;

  const CategoryHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 3,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

// Página principal del menú
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // Almacena los platos organizados por categoría
  Map<String, List<Dish>> categorizedDishes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  // Carga los platos desde los archivos JSON
  Future<void> _loadDishes() async {
    try {
      final categories = [
        'ceviches',
        'chicharrones',
        'fondos',
        'piqueos',
        'sabadosydomingos'
      ];

      for (final category in categories) {
        final jsonString = await rootBundle.loadString('assets/$category.json');
        final List<dynamic> jsonList = json.decode(jsonString);
        final dishes = jsonList.map((json) => Dish.fromJson(json)).toList();
        categorizedDishes[category] = dishes;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar los platos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Formatea el nombre de la categoría para mostrarlo si no lo mostrara en mayusculas y desordenado!
  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0E4975)),
          onPressed: () => GoRouter.of(context).go('/'),
          tooltip: 'Regresar',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categorizedDishes.length,
                itemBuilder: (context, index) {
                  final category = categorizedDishes.keys.elementAt(index);
                  final dishes = categorizedDishes[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryHeader(title: _formatCategoryName(category)),
                      ...dishes.map((dish) => DishCard(
                        dish: dish,
                        category: category,
                      )),
                    ],
                  );
                },
              ),
            ),
    );
  }
}