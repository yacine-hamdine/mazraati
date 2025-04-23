import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const SearchScreen(),
    const StoreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onCenterTap: () {
          // Handle center button tap
        },
      ),
    );
  }
}
