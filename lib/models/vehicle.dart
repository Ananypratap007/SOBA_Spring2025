import 'dart:io';

class Vehicle {
  String make;
  String model;
  String licensePlate;
  String color;
  File? image;

  Vehicle({
    required this.make,
    required this.model,
    required this.licensePlate,
    required this.color,
    this.image,
  });
}
