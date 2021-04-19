import 'dart:convert';

import 'package:meta/meta.dart';

class Product {
  String id;
  String name;
  String description;
  double price;
  String image;
  bool favorite;
  int cartCount;

  Product(
      {@required this.id,
      @required this.name,
      @required this.description,
      @required this.price,
      @required this.image,
      this.favorite = false,
      this.cartCount = 0
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
        image: 'http://10.0.2.2:1337' + json['image']['url']);
  }
}
