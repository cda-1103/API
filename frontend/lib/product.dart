//inutilizada 
class Product {
  final String serialNumber;
  final String description;
  final String category;
  final String brand;
  final String type;
  final double quantity;
  final String location;

  //constructor de la clase 
  Product({
    required this.serialNumber,
    required this.description,
    required this.category,
    required this.brand,
    required this.type,
    required this.quantity,
    required this.location,

  });


  // conversion a un map para luego convertirla a un tipo json
  Map <String, dynamic> toJson(){
    return{
      'serial_number' : serialNumber,
      'description' : description,
      'category' : category,
      'brand': brand,
      'type' : type,
      'quantity' : quantity,
      'location' : location,
    };

  }
}
