class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String image;
  final List<String> sizes;
  


  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.sizes,
    
  });

   factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: int.parse(json['id'].toString()), // Handles both string and int
    name: json['name'],
    price: double.parse(json['price'].toString()), // Handles both string and double
    category: json['category'],
    image: json['image'],
    sizes: List<String>.from(json['sizes'] ?? ['M']),
    
  );
}

}