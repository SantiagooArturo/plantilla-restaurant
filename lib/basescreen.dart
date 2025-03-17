import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BaseScreen extends StatelessWidget {
  final Widget child; // The page that will be displayed
  final int currentIndex; // The selected tab index

  const BaseScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          child, // The page content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E4975).withOpacity(0.3),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: SalomonBottomBar(
                      currentIndex: currentIndex,
                      onTap: (index) => _handleNavigation(context, index),
                      selectedItemColor: const Color(0xFF0E4975),
                      unselectedItemColor: const Color(0xFF0E4975).withOpacity(0.5),
                      selectedColorOpacity: 0.15,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      items: [
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Piqueos'),
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Duos'),
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Ceviches'),
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Chicharrones'),
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Fondos'),
                        _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Sabados y Domingos'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create navigation items
  SalomonBottomBarItem _buildNavItem(IconData icon, IconData activeIcon, String title) {
    return SalomonBottomBarItem(
      icon: Icon(icon, size: 20),
      activeIcon: Icon(activeIcon, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Handles navigation when a bottom bar item is tapped
  void _handleNavigation(BuildContext context, int index) {
    if (currentIndex == index) return;

    switch (index) {
      case 0:
        context.go('/Piqueos');
        break;
      case 1:
        context.go('/Duos');
        break;
      case 2:
        context.go('/Ceviches');
        break;
      case 3:
        context.go('/Chicharrones');
        break;
      case 4:
        context.go('/Fondos');
        break;
      case 5:
        context.go('/SabadosYDomingos');
        break;
    }
  }
}