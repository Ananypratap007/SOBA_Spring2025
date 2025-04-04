import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

const double dfInsets = 20;
const double dfRadius = 20;
const Color blue = Color(0xff003366);
const Color teal = Color(0xff03DAA2);

final MapController _mapController = MapController();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responders Status',
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
  late Future<List<_ResponderTile>> responderTiles;
  static const LatLng _dfLocation = LatLng(35.2043, -97.4453);
  static const double _dfZoom = 9.0;

  final List<Responder> responders = [
    Responder(
      name: 'Helena Furman',
      lat: 35.138056,
      lng: -97.369444,
      loc: "Noble, OK",
      status: 'En Route',
      image:
          'https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDEyN3x0b3dKWkZza3BHZ3x8ZW58MHx8fHx8',
    ),
    Responder(
      name: 'Jack Moore',
      lat: 35.4689,
      lng: -97.5195,
      loc: "Oklahoma City, OK",
      status: 'On Site',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    Responder(
      name: 'Linda Smith',
      lat: 35.0137,
      lng: -97.3611,
      loc: "Purcell, OK",
      status: 'Returning',
      image:
          'https://images.unsplash.com/photo-1742504886132-dbdc985233b1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDM0fHRvd0paRnNrcEdnfHxlbnwwfHx8fHw%3D',
    ),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: blue,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(dfRadius)),
        panel: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: responders.length,
          itemBuilder: (context, index) {
            return _ResponderTile(
              responder: responders[index],
              onTap: () {
                // Navigate to responder's location
                LatLng responderLocation =
                    LatLng(responders[index].lat, responders[index].lng);
                _mapController.move(responderLocation, _dfZoom + 5);
              },
            );
          },
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _dfLocation,
                initialZoom: _dfZoom,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.soba.app',
                  errorImage: const NetworkImage(
                      'https://tile.openstreetmap.org/0/0/0.png'),
                ),
                MarkerLayer(
                  markers: responders
                      .map((responder) => Marker(
                            point: LatLng(responder.lat,
                                responder.lng), // Responder's coordinates
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () {
                                print("${responder.name} tapped!");
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(responder.name),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Status: ${responder.status}"),
                                        Text(
                                            "Location: ${responder.loc} \n${responder.lat}, ${responder.lng}"),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Close"),
                                      )
                                    ],
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: dfRadius / 1.15,
                                    backgroundImage:
                                        NetworkImage(responder.image),
                                  ),
                                  IntrinsicWidth(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit
                                            .scaleDown, // Ensures text fits in one line
                                        child: Text(
                                          responder
                                              .name, // Name adapts to length
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis, // Prevents multi-line wrapping
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(
                    dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
                decoration: BoxDecoration(
                  color: blue,
                ),
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        // Reset map to default location
                        _mapController.move(_dfLocation, _dfZoom);
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: blue),
                    ),
                    Expanded(child: SizedBox.shrink()),
                    _SearchBar(
                      blue,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class Responder {
  final String name;
  final double lat;
  final double lng;
  final String loc;
  final String status;
  final String image;

  Responder({
    required this.name,
    required this.lat,
    required this.lng,
    required this.loc,
    required this.status,
    required this.image,
  });
}

class _ResponderTile extends StatefulWidget {
  final Responder responder;
  final VoidCallback? onTap;

  const _ResponderTile({Key? key, required this.responder, this.onTap})
      : super(key: key);

  @override
  State<_ResponderTile> createState() => _ResponderTileState();
}

class _ResponderTileState extends State<_ResponderTile> {
  String locationName = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _fetchLocationName();
  }

  Future<void> _fetchLocationName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.responder.lat,
        widget.responder.lng,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationName = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        locationName = widget.responder.loc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(dfRadius), // Add ripple effect border
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dfRadius)),
        color: blue,
        child: Padding(
          padding: const EdgeInsets.all(dfInsets),
          child: Row(
            children: [
              CircleAvatar(
                radius: 2 * dfRadius,
                backgroundImage: NetworkImage(widget.responder.image),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.responder.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(
                      'Status: ${widget.responder.status}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: teal),
                    ),
                    Text(
                      'Location: $locationName',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
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
          contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
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
        borderRadius: BorderRadius.circular(dfRadius),
      );
}
