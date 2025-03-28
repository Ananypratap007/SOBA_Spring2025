import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responders Status',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TilesPage(),
    );
  }
}

class TilesPage extends StatefulWidget {
  const TilesPage({Key? key}) : super(key: key);

  @override
  State<TilesPage> createState() => _TilesPageState();
}

class _TilesPageState extends State<TilesPage> {
  final List<Responder> responders = [
    Responder(
      name: 'Jack Furman',
      location: 'Norman, OK',
      assignedTo: 'Jane Doe',
      date: 'March 3, 2025',
      time: 'Today, 4:45 PM',
      status: 'En Route',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    Responder(
      name: 'Holden Moore',
      location: 'OK City, OK',
      assignedTo: 'Amanda Key',
      date: 'March 3, 2025',
      time: 'Today, 5:37 PM',
      status: 'On Site',
      image:
          'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D',
    ),
    Responder(
      name: 'Elle Smith',
      location: 'Noble, OK',
      assignedTo: 'Patrick DeVoe',
      date: 'March 3, 2025',
      time: 'Today, 6:30 PM',
      status: 'Returning',
      image:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SlidingUpPanel(
        minHeight: 100,
        maxHeight: 450,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        panel: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: responders.length,
          itemBuilder: (context, index) {
            return ResponderTile(responder: responders[index]);
          },
        ),
        body: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(8.0, 6.5 * 8.0, 8.0, 8.0),
                decoration: BoxDecoration(
                  color: (Colors.blue[900])!,
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back,
                        color: Colors.white,
                        size: 40), // TODO: Add functionality
                    Expanded(child: SizedBox.shrink()),
                    _SearchBar(Color.fromARGB(255, 245, 245, 245)),
                  ],
                )),
            Image.asset('assets/maps_placeholder.png',
                scale: 0.945, width: double.infinity, fit: BoxFit.fitWidth),
          ],
        ),
      ),
    );
  }
}

class Responder {
  final String name;
  final String location;
  final String assignedTo;
  final String date;
  final String time;
  final String status;
  final String image;

  Responder({
    required this.name,
    required this.location,
    required this.assignedTo,
    required this.date,
    required this.time,
    required this.status,
    required this.image,
  });
}

class ResponderTile extends StatelessWidget {
  final Responder responder;
  const ResponderTile({Key? key, required this.responder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('profile'),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.blue[900],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(responder.image),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(responder.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Status: ${responder.status}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[300])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      width: 0.75 * MediaQuery.of(context).size.width,
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: color,
          border: _border(grey),
          enabledBorder: _border(grey),
          hintText: 'Search here...',
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0 / 2),
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
