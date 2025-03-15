import 'package:flutter/material.dart';
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

class TilesPage extends StatelessWidget {
  final List<Responder> responders = [
    Responder(
      name: 'Helena Furman',
      location: 'Norman, OK',
      assignedTo: 'Jane Doe',
      date: 'March 3, 2025',
      time: 'Today, 4:45 PM',
      status: 'En Route',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    Responder(
      name: 'Jack Moore',
      location: 'OK City, OK',
      assignedTo: 'Amanda Key',
      date: 'March 3, 2025',
      time: 'Today, 5:37 PM',
      status: 'On Site',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    Responder(
      name: 'Linda Smith',
      location: 'Noble, OK',
      assignedTo: 'Patrick DeVoe',
      date: 'March 3, 2025',
      time: 'Today, 6:30 PM',
      status: 'Returning',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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
        body: Stack(
          children: [
            Positioned.fill(
              child:
                  Image.asset('assets/maps_placeholder.png', fit: BoxFit.cover),
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.redAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Responders: 3',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Incident Reported: 0',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green[300],
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
                          color: Colors.blue[900])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
