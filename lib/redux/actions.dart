import 'dart:convert';

import 'package:tienda_app/models/product.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/models/user.dart';
import 'package:flutter/foundation.dart';

//*** Middleware

/// ThunkAction to fetch user from SharedPreferences
ThunkAction<AppState> getUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();

  final email = prefs.getString('email');
  if (email == null) {
    store.dispatch(GetUserAction(null));
    return;
  }

  final userMap = {
    'email': email,
    'jwt': prefs.getString('jwt'),
    'username': prefs.getString('username'),
    'id': prefs.getString('id'),
    'cart_id': prefs.getString('cart_id'),
    'favorite_id': prefs.getString('favorite_id'),
  };

  final user = User.fromJson(userMap);
  store.dispatch(GetUserAction(user));
};

/// ThunkAction to logout user and clear SharedPreferences
ThunkAction<AppState> logoutUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('email');
  await prefs.remove('id');
  await prefs.remove('jwt');
  await prefs.remove('username');
  await prefs.remove('cart_id');
  await prefs.remove('favorite_id');

  store.dispatch(LogoutUserAction(null));
};

/// ThunkAction to fetch products from API
ThunkAction<AppState> getProductsAction = (Store<AppState> store) async {
  try {
    final res = await http.get(Uri.parse("http://10.0.2.2:1337/products"));
    if (res.statusCode == 200) {
      final List<dynamic> resData = json.decode(res.body);
      final products = resData.map((pm) => Product.fromJson(pm)).toList();
      store.dispatch(GetProductsAction(products));
    }
  } catch (e) {
    debugPrint("Error fetching products: $e");
  }
};

/// ThunkAction to update a product
ThunkAction<AppState> updateProductAction(Product product) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateProductAction(product));
  };
}

/// ThunkAction to toggle a product in the cart
ThunkAction<AppState> toggleCartProductAction(Product cartProduct, int count) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = List.from(store.state.productsCart);
    final User? user = store.state.user;

    if (user == null) return;

    final int index = cartProducts.indexWhere((p) => cartProduct.id == p.id);

    if (index > -1) {
      cartProducts.removeAt(index);
    } else {
      cartProducts.add(cartProduct.copyWith(cartCount: count));
    }

    final List<Map<String, dynamic>> cartProductsIds = cartProducts
        .map((p) => {'product_id': p.id, 'count': p.cartCount})
        .toList();

    try {
      final res = await http.put(
        Uri.parse("http://10.0.2.2:1337/carts/${user.cartId}"),
        body: {"products": json.encode(cartProductsIds)},
        headers: {"Authorization": "Bearer ${user.jwt}"},
      );
      debugPrint("Toggle Cart Status: ${res.statusCode}");
      store.dispatch(ToggleCartProductAction(cartProducts));
    } catch (e) {
      debugPrint("Error toggling cart: $e");
    }
  };
}

/// ThunkAction to toggle a favorite product
ThunkAction<AppState> toggleFavoriteAction(Product productFavorite) {
  return (Store<AppState> store) async {
    final List<Product> products = List.from(store.state.products);
    final User? user = store.state.user;
    if (user == null) return;

    final int index = products.indexWhere((p) => productFavorite.id == p.id);

    if (index > -1) {
      var p = products[index];
      products[index] = p.copyWith(favorite: !p.favorite);
    }

    final List<Product> productsFavorite =
        products.where((p) => p.favorite).toList();

    final List<Map<String, dynamic>> productsFavoriteId =
        productsFavorite.map((p) => {'product_id': p.id}).toList();

    try {
      final res = await http.put(
        Uri.parse("http://10.0.2.2:1337/favorites/${user.favoriteId}"),
        body: {"products": json.encode(productsFavoriteId)},
        headers: {"Authorization": "Bearer ${user.jwt}"},
      );
      debugPrint("Toggle Favorite Status: ${res.statusCode}");
      store.dispatch(ToggleFavoriteAction(products));
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  };
}

/// ThunkAction to change quantity of a product in the cart
ThunkAction<AppState> changeCartProductAction(Product cartProduct, int count) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = List.from(store.state.productsCart);
    final User? user = store.state.user;
    if (user == null) return;

    final int index = cartProducts.indexWhere((p) => cartProduct.id == p.id);

    if (index > -1) {
      cartProducts[index] = cartProducts[index].copyWith(cartCount: count);
    }

    final List<Map<String, dynamic>> cartProductsIds = cartProducts
        .map((p) => {'product_id': p.id, 'count': p.cartCount})
        .toList();

    try {
      final res = await http.put(
        Uri.parse("http://10.0.2.2:1337/carts/${user.cartId}"),
        body: {"products": json.encode(cartProductsIds)},
        headers: {"Authorization": "Bearer ${user.jwt}"},
      );
      debugPrint("Change Cart Status: ${res.statusCode}");
      store.dispatch(ChangeCartProductAction(cartProducts));
    } catch (e) {
      debugPrint("Error changing cart quantity: $e");
    }
  };
}

/// ThunkAction to fetch favorite products
ThunkAction<AppState> getProductsFavoriteAction = (Store<AppState> store) async {
  final User? user = store.state.user;
  if (user == null) return;

  try {
    final res = await http.get(
        Uri.parse("http://10.0.2.2:1337/favorites/${user.favoriteId}"),
        headers: {"Authorization": "Bearer ${user.jwt}"});

    if (res.statusCode == 200) {
      final resData = json.decode(res.body);
      final resDataProducts = json.decode(resData['products']);
      store.dispatch(GetProductsFavoriteAction(
          _setProductsIdToProductsFavorite(store, resDataProducts)));
    } else {
      store.dispatch(GetProductsFavoriteAction([]));
    }
  } catch (e) {
    debugPrint("Error fetching favorites: $e");
    store.dispatch(GetProductsFavoriteAction([]));
  }
};

List<Product> _setProductsIdToProductsFavorite(
    Store<AppState> store, List<dynamic> productsString) {
  List<Product> products = List.from(store.state.products);

  for (var pString in productsString) {
    final index = products.indexWhere((p) => p.id == pString['product_id']);
    if (index > -1) {
      products[index] = products[index].copyWith(favorite: true);
    }
  }

  return products;
}

/// ThunkAction to fetch cart products
ThunkAction<AppState> getProductsCartAction = (Store<AppState> store) async {
  final User? user = store.state.user;
  if (user == null) return;

  try {
    final res = await http.get(Uri.parse("http://10.0.2.2:1337/carts/${user.cartId}"),
        headers: {"Authorization": "Bearer ${user.jwt}"});

    if (res.statusCode == 200) {
      final resData = json.decode(res.body);
      final resDataProducts = json.decode(resData['products']);
      store.dispatch(GetProductsCartAction(
          _setProductsIdToProducts(store, resDataProducts)));
    } else {
      store.dispatch(GetProductsCartAction([]));
    }
  } catch (e) {
    debugPrint("Error fetching cart: $e");
    store.dispatch(GetProductsCartAction([]));
  }
};

List<Product> _setProductsIdToProducts(
    Store<AppState> store, List<dynamic> productsString) {
  List<Product> productsCart = [];
  List<Product> allProducts = store.state.products;

  for (var pString in productsString) {
    final index = allProducts.indexWhere((p) => p.id == pString['product_id']);
    if (index > -1) {
      productsCart.add(allProducts[index].copyWith(cartCount: pString['count']));
    }
  }

  return productsCart;
}

// *** Acciones

class ToggleFavoriteAction {
  final List<Product> products;
  ToggleFavoriteAction(this.products);
}

class GetProductsCartAction {
  final List<Product> productsCart;
  GetProductsCartAction(this.productsCart);
}

class GetProductsFavoriteAction {
  final List<Product> products;
  GetProductsFavoriteAction(this.products);
}

class GetUserAction {
  final User? user;
  GetUserAction(this.user);
}

class LogoutUserAction {
  final User? user;
  LogoutUserAction(this.user);
}

class GetProductsAction {
  final List<Product> products;
  GetProductsAction(this.products);
}

class ToggleCartProductAction {
  final List<Product> cartProducts;
  ToggleCartProductAction(this.cartProducts);
}

class ChangeCartProductAction {
  final List<Product> cartProducts;
  ChangeCartProductAction(this.cartProducts);
}

class UpdateProductAction {
  final Product product;
  UpdateProductAction(this.product);
}

class ClearCartAction {}
