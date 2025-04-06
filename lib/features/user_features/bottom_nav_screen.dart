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
      extendBody: true,
      backgroundColor: const Color(0xFFF5F5F5),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: Colors
            .transparent, // Must be transparent to let items go through behind
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF003366), // your actual nav bar color
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: selected,
              onTap: onSelected,
              selectedItemColor: const Color(0xFF4CAF93),
              unselectedItemColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    size: 26,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.map,
                    size: 26,
                  ),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    size: 26,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
