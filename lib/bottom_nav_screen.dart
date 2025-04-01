import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageWithBottomNav extends StatefulWidget {
  const PageWithBottomNav({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PageWithBottomNav> createState() => _PageWithBottomNavState();
}

class _PageWithBottomNavState extends State<PageWithBottomNav> {
  int _selected = 0;

  void _onSelected(int newValue) {
    setState(() {
      _selected = newValue;
      switch (_selected) {
        case 1:
          context.go('/map');
        case 2:
          context.go('/profile');
        case 0:
        default:
          context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomBar(
        scheme: Theme.of(context).colorScheme,
        selected: _selected,
        onSelected: _onSelected,
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.scheme,
    required this.selected,
    required this.onSelected,
  });

  final ColorScheme scheme;
  final int selected;
  final Function(int newValue) onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onSelected,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF003366),
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: selected,
    );
  }
}
