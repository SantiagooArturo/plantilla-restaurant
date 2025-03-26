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
import 'package:perlaazul/pages/list_page.dart';
import 'dart:async';

// Clave global para manejar la recarga de la página
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Control de inicio de la aplicación
class AppState {
  // Esta variable siempre es true al iniciar la aplicación
  // Se resetea cada vez que la app se recarga en web
  static bool _isInitialLaunch = true;
  
  static bool get isInitialLaunch => _isInitialLaunch;
  
  static void markAsLaunched() {
    _isInitialLaunch = false;
  }
  
  // Este método ya no se necesita para web, porque queremos mostrar
  // el splash siempre al iniciar/recargar la app
  static void skipSplashOnInternalNav(String location) {
    // No hacemos nada, para permitir que el splash se muestre siempre
  }
}

void main() {
  // Reiniciar el estado al iniciar la aplicación
  // Esto es especialmente importante para web
  AppState._isInitialLaunch = true;
  
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

/// Pantalla de splash que muestra el logo del restaurante por 2 segundos
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar a la pantalla principal después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        AppState.markAsLaunched();
        
        // Uso GoRouter.of para asegurar que la navegación funcione correctamente
        // en el contexto de Flutter web
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/home');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo del restaurante
            Image.asset(
              'assets/images/perlaazul.jpeg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            // Nombre del restaurante
            const Text(
              'Perla Azul',
              style: TextStyle(
                fontFamily: 'Garamond',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E4975),
              ),
            ),
            const SizedBox(height: 8),
            // Texto de carga
            const Text(
              'Restaurante',
              style: TextStyle(
                fontFamily: 'Garamond',
                fontSize: 18,
                color: Color(0xFF0E4975),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define navigation routes using GoRouter
final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    // En web, siempre mostramos el splash al iniciar la app
    if (AppState.isInitialLaunch) {
      if (state.uri.toString() != '/Splash') {
        return '/Splash';
      }
    } else if (state.uri.toString() == '/Splash') {
      // Si ya se mostró el splash y se intenta volver a él, redirigir a home
      return '/home';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/Splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => WebWrapper(
        child: BaseScreen(currentIndex: 0, child: PiqueosPage()),
      ),
    ),
    GoRoute(
      path: '/Piqueos',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 0,
            child: PiqueosPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/Duos',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 1,
            child: DuosPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/Ceviches',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 2,
            child: CevichesPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/Chicharrones',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 3,
            child: ChicharronesPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/Fondos',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 4,
            child: FondosPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/SabadosYDomingos',
      builder: (context, state) {
        // Extrae el ID del plato de los parámetros de navegación
        final dishId = state.extra as int?;
        return WebWrapper(
          child: BaseScreen(
            currentIndex: 5,
            child: SabadosYDomingosPage(initialDishId: dishId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/listPage',
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
    // Al reconstruir el WebWrapper (como sucede en navegaciones internas),
    // no afectamos el estado de splash para la próxima recarga de la página
    return Center(
      child: SizedBox(
        width: 500, // Keep UI width limited for web
        child: child,
      ),
    );
  }
}