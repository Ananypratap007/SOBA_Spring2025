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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update selected index when dependencies change
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    setState(() {
      switch (location) {
        case '/map':
          _selected = 1;
          break;
        case '/profile':
          _selected = 2;
          break;
        case '/':
        default:
          _selected = 0;
      }
    });
  }

  void _onSelected(int newValue) {
    setState(() {
      _selected = newValue;
      switch (_selected) {
        case 1:
          context.go('/map');
          break;
        case 2:
          context.go('/profile');
          break;
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
      // Remove extendBody if you don’t want the body to extend behind the bottom bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            const Color(0xFF003366), // your desired background color
        currentIndex: _selected,
        onTap: _onSelected,
        selectedItemColor: const Color(0xFF4CAF93),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 26),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 26),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
