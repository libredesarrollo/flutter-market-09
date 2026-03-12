class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool favorite;
  final int cartCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.favorite = false,
    this.cartCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    try {
      price = json['price'];
    } catch (e) {
      price = json['price'].toDouble();
    }

    return Product(
        id: json['_id'],
        name: json['name'],
        description: json['description'],
        price: price,
        image: 'http://10.0.2.2:1337${json['image']['url']}');
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    bool? favorite,
    int? cartCount,
  }) {
    return Product(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        image: image ?? this.image,
        favorite: favorite ?? this.favorite,
        cartCount: cartCount ?? this.cartCount);
  }
}
