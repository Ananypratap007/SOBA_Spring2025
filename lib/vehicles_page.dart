import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/vehicle.dart'; // Import the Vehicle model

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Vehicle> vehicles = [];

  // Function to add a new vehicle
  void addVehicle() {
    setState(() {
      vehicles.add(Vehicle(make: '', model: '', licensePlate: '', color: ''));
    });
  }

  // Function to pick an image from gallery
  Future<void> pickImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        vehicles[index].image = File(pickedFile.path);
      });
    }
  }

  // Function to edit vehicle details
  void editVehicle(int index) {
    TextEditingController makeController =
        TextEditingController(text: vehicles[index].make);
    TextEditingController modelController =
        TextEditingController(text: vehicles[index].model);
    TextEditingController licenseController =
        TextEditingController(text: vehicles[index].licensePlate);
    TextEditingController colorController =
        TextEditingController(text: vehicles[index].color);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Vehicle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: makeController,
                  decoration: InputDecoration(labelText: "Make")),
              TextField(
                  controller: modelController,
                  decoration: InputDecoration(labelText: "Model")),
              TextField(
                  controller: licenseController,
                  decoration: InputDecoration(labelText: "License Plate")),
              TextField(
                  controller: colorController,
                  decoration: InputDecoration(labelText: "Color")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  vehicles[index] = Vehicle(
                    make: makeController.text,
                    model: modelController.text,
                    licensePlate: licenseController.text,
                    color: colorController.text,
                    image: vehicles[index].image,
                  );
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Information"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addVehicle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: vehicles[index].image != null
                          ? FileImage(vehicles[index].image!)
                          : null,
                      child: vehicles[index].image == null
                          ? Icon(Icons.car_repair,
                              size: 30, color: Colors.black54)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Make: ${vehicles[index].make}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Model: ${vehicles[index].model}"),
                          Text("License Plate: ${vehicles[index].licensePlate}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Color: ${vehicles[index].color}"),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => editVehicle(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, size: 20),
                      onPressed: () => pickImage(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
