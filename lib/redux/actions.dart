import 'dart:convert';

import 'package:market/models/product.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:market/models/app_state.dart';
import 'package:market/models/user.dart';

//*** Middleware
ThunkAction<AppState> getUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();

  final Map<String, dynamic> userMap = prefs.getString('email') == null
      ? null
      : ({
          'email': prefs.getString('email'),
          'jwt': prefs.getString('jwt'),
          'username': prefs.getString('username'),
          'id': prefs.getString('id'),
          'cart_id': prefs.getString('cart_id'),
          'favorite_id': prefs.getString('favorite_id'),
        });

  final user = userMap == null ? null : User.fromJson(userMap);

  store.dispatch(GetUserAction(user));
};

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

ThunkAction<AppState> getProductsAction = (Store<AppState> store) async {
  final res = await http.get("http://10.0.2.2:1337/products");
  final List<dynamic> resData = json.decode(res.body);

  final List<Product> products = [];
  resData.forEach((pm) {
    final Product p = Product.fromJson(pm);
    products.add(p);
  });

  store.dispatch(GetProductsAction(products));
};

ThunkAction<AppState> updateProductAction(Product product) {
  return (Store<AppState> store) async {
    //final List<Product> products = store.state.products;

    //final int index = products.indexWhere((p) => p.id == product.id);
    //products[index] = product;

    // final res = await http.get("http://10.0.2.2:1337/products");
    // final List<dynamic> resData = json.decode(res.body);

    store.dispatch(UpdateProductAction(product));
  };
}

ThunkAction<AppState> toggleCartProductAction(Product cartProduct, int count) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = store.state.productsCart;
    final User user = store.state.user;

    final int index = cartProducts.indexWhere((p) => cartProduct.id == p.id);

    if (index > -1) {
      cartProduct.cartCount = 0;
      cartProducts.removeAt(index);
    } else {
      cartProduct.cartCount = count;
      cartProducts.add(cartProduct);
    }

    final List<Map> cartProductsIds = cartProducts
        .map((p) => {'product_id': p.id, 'count': p.cartCount})
        .toList();

    print(cartProductsIds);

    final res =
        await http.put("http://10.0.2.2:1337/carts/${user.cartId}", body: {
      "products": json.encode(cartProductsIds),
    }, headers: {
      "Authorization": "Bearer ${user.jwt}"
    });

    print(res.statusCode);

    store.dispatch(TogleCartProductAction(cartProducts));
  };
}

ThunkAction<AppState> toggleFavoriteAction(Product productFavorite) {
  return (Store<AppState> store) async {
    final List<Product> products = store.state.products;
    final User user = store.state.user;

    final int index = products.indexWhere((p) => productFavorite.id == p.id);

    if (index > -1) {
      products[index].favorite = !products[index].favorite;
    }

    final List<Product> productsFavorite =
        products.where((p) => p.favorite).toList();

    final List<Map> productsFavoriteId =
        productsFavorite.map((p) => {'product_id': p.id}).toList();

    print(productsFavoriteId);

    final res = await http
        .put("http://10.0.2.2:1337/favorites/${user.favoriteId}", body: {
      "products": json.encode(productsFavoriteId),
    }, headers: {
      "Authorization": "Bearer ${user.jwt}"
    });

    print(res.statusCode);

    store.dispatch(ToggleFavoriteAction(products));
  };
}

ThunkAction<AppState> changeCartProductAction(Product cartProduct, int count) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = store.state.productsCart;
    final User user = store.state.user;

    final int index = cartProducts.indexWhere((p) => cartProduct.id == p.id);

    if (index > -1) {
      cartProducts[index].cartCount = count;
    }

    final List<Map> cartProductsIds = cartProducts
        .map((p) => {'product_id': p.id, 'count': p.cartCount})
        .toList();

    print(cartProductsIds);

    final res =
        await http.put("http://10.0.2.2:1337/carts/${user.cartId}", body: {
      "products": json.encode(cartProductsIds),
    }, headers: {
      "Authorization": "Bearer ${user.jwt}"
    });

    print(res.statusCode);

    store.dispatch(ChangeCartProductAction(cartProducts));
  };
}

ThunkAction<AppState> getProductsFavoriteAction =
    (Store<AppState> store) async {
  final User user = store.state.user;

  final res = await http.get(
      "http://10.0.2.2:1337/favorites/${user.favoriteId}",
      headers: {"Authorization": "Bearer ${user.jwt}"});

  print(res.statusCode);

  if (res.statusCode == 200) {
    final resData = json.decode(res.body);

    final resDataProducts = json.decode(resData['products']);

    return store.dispatch(GetProductsFavoriteAction(
        _setProductsIdToProductsFavorite(store, resDataProducts)));
  }
  store.dispatch(GetProductsFavoriteAction([]));
};

List<Product> _setProductsIdToProductsFavorite(
    Store<AppState> store, List<dynamic> productsString) {
  List<Product> products = store.state.products;

  productsString.forEach((pString) {
    final index =
        store.state.products.indexWhere((p) => p.id == pString['product_id']);

    if (index > -1) {
      store.state.products[index].favorite = true;
    }
  });

  return products;
}

ThunkAction<AppState> getProductsCartAction = (Store<AppState> store) async {
  final User user = store.state.user;

  final res = await http.get("http://10.0.2.2:1337/carts/${user.cartId}",
      headers: {"Authorization": "Bearer ${user.jwt}"});

  if (res.statusCode == 200) {
    final resData = json.decode(res.body);

    try {
      final resDataProducts = json.decode(resData['products']);

      return store.dispatch(GetProductsCartAction(
          _setProductsIdToProducts(store, resDataProducts)));
    } catch (e) {
      
    }
  }
  store.dispatch(GetProductsCartAction([]));
};

List<Product> _setProductsIdToProducts(
    Store<AppState> store, List<dynamic> productsString) {
  List<Product> productsCart = [];

  productsString.forEach((pString) {
    final index =
        store.state.products.indexWhere((p) => p.id == pString['product_id']);

    if (index > -1) {
      store.state.products[index].cartCount = pString['count'];
      productsCart.add(store.state.products[index]);
    }
  });

  return productsCart;
}

// *** acciones

class ToggleFavoriteAction {
  final List<Product> _products;

  ToggleFavoriteAction(this._products);

  dynamic get products => this._products;
}

class GetProductsCartAction {
  final List<Product> _productsCart;

  GetProductsCartAction(this._productsCart);

  dynamic get productsCart => this._productsCart;
}

class GetProductsFavoriteAction {
  final List<Product> _products;

  GetProductsFavoriteAction(this._products);

  dynamic get products => this._products;
}

class GetUserAction {
  final dynamic _user;

  dynamic get user => this._user;

  GetUserAction(this._user);
}

class LogoutUserAction {
  final dynamic _user;

  dynamic get user => this._user;

  LogoutUserAction(this._user);
}

class GetProductsAction {
  final List<Product> _products;

  GetProductsAction(this._products);

  dynamic get products => this._products;
}

class TogleCartProductAction {
  final List<Product> _cartProducts;

  TogleCartProductAction(this._cartProducts);

  dynamic get cartProducts => this._cartProducts;
}

class ChangeCartProductAction {
  final List<Product> _cartProducts;

  ChangeCartProductAction(this._cartProducts);

  dynamic get cartProducts => this._cartProducts;
}

class UpdateProductAction {
  final Product _product;

  UpdateProductAction(this._product);

  dynamic get product => this._product;
}
