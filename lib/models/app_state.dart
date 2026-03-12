import 'package:tienda_app/models/product.dart';
import 'package:tienda_app/models/user.dart';

class AppState {
  final User? user;
  final List<Product> products;
  final List<Product> productsCart;

  const AppState(
      {required this.user, required this.products, required this.productsCart});

  factory AppState.initial() {
    return AppState(user: null, products: [], productsCart: []);
  }

  List<Product> favorites() => products.where((p) => p.favorite).toList();
  //List<Product> carts() => products.where((p) => p.cartCount >= 1).toList();

  Product findOne(Product product) {
    final int index = products.indexWhere((p) => p.id == product.id);
    return products[index];
  }
}
