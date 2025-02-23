import 'package:flutter/material.dart';
import 'package:soba_app/main.dart' hide MainApp;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: BottomBar(scheme: scheme, selected: 1),
      body: SlidingUpPanel(
        minHeight: 50,
        maxHeight: 450,
        borderRadius: BorderRadius.vertical(top: Radius.circular(dfRadius)),
        panel: Column(
            children: [
              // None :(
            ],
          ),
        body: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(dfInsets, 2.5*dfInsets, dfInsets, dfInsets),
              decoration: BoxDecoration(
                gradient: gradientOrange,
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 40), // TODO: Add functionality
                  Expanded(child: SizedBox.shrink()),
                  _SearchBar(scheme.primary),
                ],
              )
            ),
            Image.asset('assets/maps_placeholder.png', scale: 0.945),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.scheme,
    required this.selected,
  });

  final ColorScheme scheme;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: scheme.primary,
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

class _SearchBar extends StatelessWidget {
  final grey = const Color(0xFFF2F2F7);
  final Color color;
  _SearchBar(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.75*MediaQuery.of(context).size.width,
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: color,
          border: _border(grey),
          enabledBorder: _border(grey),
          hintText: 'Search here...',
          contentPadding: const EdgeInsets.symmetric(vertical: dfInsets/2),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
        ),
        onFieldSubmitted: (value) {},
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(12),
      );
}