import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFF6F1FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarIcon(
            icon: Icons.home_outlined,
            filledIcon: Icons.home,
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarIcon(
            icon: Icons.shopping_cart_outlined,
            filledIcon: Icons.shopping_cart,
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarIcon(
            icon: Icons.search,
            filledIcon: Icons.search, // search has no filled variant, but you can use the same
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarIcon(
            icon: Icons.storefront_outlined,
            filledIcon: Icons.storefront,
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarIcon(
            icon: Icons.person_outlined,
            filledIcon: Icons.person,
            selected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatefulWidget {
  final IconData icon;
  final IconData filledIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.filledIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavBarIcon> createState() => _NavBarIconState();
}

class _NavBarIconState extends State<_NavBarIcon> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.85;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.selected ? widget.filledIcon : widget.icon,
                color: widget.selected ? const Color(0xFF00916E) : const Color(0xFF3A3740),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}