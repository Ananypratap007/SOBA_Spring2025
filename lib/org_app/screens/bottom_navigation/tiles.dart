import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const TilesPage({super.key});

  @override
  State<TilesPage> createState() => _TilesPageState();
}

class _TilesPageState extends State<TilesPage> {
  int _currentIndex = 1;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  void _onNavigationTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

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
    Responder(
      name: 'Alex Johnson',
      location: 'Tulsa, OK',
      assignedTo: 'Sarah Miller',
      date: 'March 3, 2025',
      time: 'Today, 7:15 PM',
      status: 'Available',
      image:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D',
    ),
    Responder(
      name: 'Maria Garcia',
      location: 'Lawton, OK',
      assignedTo: 'David Wilson',
      date: 'March 3, 2025',
      time: 'Today, 8:00 PM',
      status: 'On Break',
      image:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        onTap: _onNavigationTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(8.0, 52.0, 8.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 30),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    _SearchBar(const Color.fromARGB(255, 245, 245, 245)),
                  ],
                ),
              ),
              Expanded(
                child: Image.asset(
                  'assets/maps_placeholder.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ],
          ),

          // Draggable sheet
          Positioned.fill(
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                // You can handle scroll/extent changes here if needed
                return true;
              },
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.2, // Initial size (20% of screen)
                minChildSize: 0.2, // Minimum size (20% of screen)
                maxChildSize: 0.7, // Maximum size (70% of screen)
                snap: true, // Enable snapping
                snapSizes: const [0.2, 0.4, 0.7], // Snap points
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),

                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Responders',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${responders.length} Active',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // List of responders
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: responders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child:
                                    ResponderTile(responder: responders[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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

  const Responder({
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
  const ResponderTile({super.key, required this.responder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responder.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${responder.status}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[300],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${responder.location}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Color color;
  const _SearchBar(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: color,
          border: _border(const Color(0xFFF2F2F7)),
          enabledBorder: _border(const Color(0xFFF2F2F7)),
          hintText: 'Search here...',
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(width: 0.5, color: color),
        borderRadius: BorderRadius.circular(50),
      );
}
