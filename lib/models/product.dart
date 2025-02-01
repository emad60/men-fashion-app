class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final List<String>
      sizes; // For products that have string sizes (e.g., shirts, pants)
  final List<int> sizesnum; // For products (like shoes) that have numeric sizes

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.sizes,
    required this.sizesnum,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      image: json['image'],
      // If "sizes" field is missing (or null), default to an empty list.
      sizes: List<String>.from(json['sizes'] ?? []),
      // If "sizesnum" field is missing (or null), default to an empty list.
      sizesnum: List<int>.from(json['sizesnum'] ?? []),
    );
  }

  /// Returns available sizes as a list of strings.
  /// - For products that define sizes as strings, returns them directly.
  /// - For products that define sizes numerically (like shoes), converts them to strings.
  /// - Returns an empty list for products without sizes (like bags).
  List<String> get availableSizes {
    if (sizes.isNotEmpty) return sizes;
    if (sizesnum.isNotEmpty) return sizesnum.map((s) => s.toString()).toList();
    return [];
  }
}
