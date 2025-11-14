
import 'dart:convert';

List<Product> productFromJson(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) => jsonEncode(List<dynamic>.from(data.map((x) => x.toJson())));



class Product {
  final String serialNumber;
  final String description;
  final double quantity;

  //constructor de la clase 
  Product({
    required this.serialNumber,
    required this.description,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    serialNumber: json["serial_number"], 
    description: json["description"], 
    quantity: (json["quantity"] as num? ?? 0).toDouble(),
    );

  Map<String, dynamic> toJson() => {
    "serial_number": serialNumber,
    "description" : description,
    "quantity" : quantity,
  };




}
