import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:perlaazul/pages/ceviches.dart';
import 'package:perlaazul/pages/chicharrones.dart';
import 'package:perlaazul/pages/duos.dart';
import 'package:perlaazul/pages/fondos.dart';
import 'package:perlaazul/pages/piqueos.dart';
import 'package:perlaazul/pages/sabadosydomingos.dart';
import 'package:perlaazul/theme/apptheme.dart';
import 'package:perlaazul/basescreen.dart';
import 'package:perlaazul/pages/list_page.dart'; // Import the new List Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Perla Azul Restaurante",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      routerConfig: _router,
    );
  }
}

// Define navigation routes using GoRouter
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => WebWrapper(
        child: BaseScreen(currentIndex: 0, child: PiqueosPage()),
      ),
    ),
    GoRoute(
      path: '/Piqueos',
      builder: (context, state) => WebWrapper(
        child: BaseScreen(currentIndex: 0, child: PiqueosPage()),
      ),
    ),
    GoRoute(
      path: '/Duos',
      builder: (context, state) => const WebWrapper(
        child: BaseScreen(currentIndex: 1, child: DuosPage()),
      ),
    ),
    GoRoute(
      path: '/Ceviches',
      builder: (context, state) => const WebWrapper(
        child: BaseScreen(currentIndex: 2, child: CevichesPage()),
      ),
    ),
    GoRoute(
      path: '/Chicharrones',
      builder: (context, state) => const WebWrapper(
        child: BaseScreen(currentIndex: 3, child: ChicharronesPage()),
      ),
    ),
    GoRoute(
      path: '/Fondos',
      builder: (context, state) => const WebWrapper(
        child: BaseScreen(currentIndex: 4, child: FondosPage()),
      ),
    ),
    GoRoute(
      path: '/SabadosYDomingos',
      builder: (context, state) => const WebWrapper(
        child: BaseScreen(currentIndex: 5, child: SabadosYDomingosPage()),
      ),
    ),
    GoRoute(
      path: '/listPage', // Added List Page route
      builder: (context, state) => const WebWrapper(
        child: ListPage(),
      ),
    ),
  ],
);

class WebWrapper extends StatelessWidget {
  final Widget child;

  const WebWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500, // Keep UI width limited for web
        child: child,
      ),
    );
  }
}