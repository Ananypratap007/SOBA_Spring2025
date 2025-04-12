import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

const double dfInsets = 20;
const double dfRadius = 20;
const Color blue = Color(0xff003366);
const Color teal = Color(0xff03DAA2);

class TilesScreen extends StatefulWidget {
  const TilesScreen({super.key});

  @override
  State<TilesScreen> createState() => _TilesScreenState();
}

class _TilesScreenState extends State<TilesScreen> {
  final MapController _mapController = MapController();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

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
          'https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?w=500&auto=format&fit=crop&q=60',
    ),
    Responder(
      name: 'Jack Moore',
      lat: 35.4689,
      lng: -97.5195,
      loc: "Oklahoma City, OK",
      status: 'On Site',
      image:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop',
    ),
    Responder(
      name: 'Linda Smith',
      lat: 35.0137,
      lng: -97.3611,
      loc: "Purcell, OK",
      status: 'Returning',
      image:
          'https://images.unsplash.com/photo-1742504886132-dbdc985233b1?w=500&auto=format&fit=crop&q=60',
    ),
  ];

  @override
  void dispose() {
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(
                    dfInsets, 2.5 * dfInsets, dfInsets, dfInsets),
                color: blue,
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _mapController.move(_dfLocation, _dfZoom);
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: blue),
                    ),
                    const Spacer(),
                    _SearchBar(blue),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
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
                    ),
                    MarkerLayer(
                      markers: responders
                          .map((responder) => Marker(
                                point: LatLng(responder.lat, responder.lng),
                                width: 50,
                                height: 50,
                                child: GestureDetector(
                                  onTap: () async {
                                    String locationName = responder.loc;
                                    try {
                                      List<Placemark> placemarks =
                                          await placemarkFromCoordinates(
                                        responder.lat,
                                        responder.lng,
                                      );
                                      if (placemarks.isNotEmpty) {
                                        Placemark place = placemarks.first;
                                        locationName =
                                            "${place.locality}, ${place.administrativeArea}";
                                      }
                                    } catch (_) {}

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
                                                "Location: $locationName \n${responder.lat}, ${responder.lng}"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: dfRadius / 1.15,
                                    backgroundImage:
                                        NetworkImage(responder.image),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            snap: true,
            snapSizes: const [0.2, 0.4, 0.7],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: responders.length,
                  itemBuilder: (context, index) => _ResponderTile(
                    responder: responders[index],
                    onTap: () {
                      _mapController.move(
                          LatLng(responders[index].lat, responders[index].lng),
                          _dfZoom + 5);
                    },
                  ),
                ),
              );
            },
          ),
        ],
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

  Responder(
      {required this.name,
      required this.lat,
      required this.lng,
      required this.loc,
      required this.status,
      required this.image});
}

class _ResponderTile extends StatefulWidget {
  final Responder responder;
  final VoidCallback? onTap;

  const _ResponderTile({super.key, required this.responder, this.onTap});

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
          widget.responder.lat, widget.responder.lng);
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
      borderRadius: BorderRadius.circular(dfRadius),
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.responder.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Status: ${widget.responder.status}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: teal)),
                    Text('Location: $locationName',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
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
  final Color color;
  const _SearchBar(this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.7 * MediaQuery.of(context).size.width,
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: color,
          border: _border(const Color(0xFFF2F2F7)),
          enabledBorder: _border(const Color(0xFFF2F2F7)),
          hintText: 'Search here...',
          contentPadding: const EdgeInsets.symmetric(vertical: dfInsets / 2),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
