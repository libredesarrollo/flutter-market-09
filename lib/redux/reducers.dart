import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/models/product.dart';
import 'package:tienda_app/models/user.dart';
import 'package:tienda_app/redux/actions.dart';

AppState appReducer(AppState state, action) {
  return AppState(
      user: userReducer(state.user, action),
      products: productsReducer(state.products, action),
      productsCart: productsCartReducer(state.productsCart, action));
}

User? userReducer(User? user, action) {
  if (action is GetUserAction) return action.user;
  if (action is LogoutUserAction) return action.user;

  return user;
}

List<Product> productsReducer(List<Product> products, action) {
  if (action is GetProductsAction) {
    return action.products;
  } else if (action is UpdateProductAction) {
    return products
        .map((p) => p.id == action.product.id ? action.product : p)
        .toList();
  } else if (action is ToggleFavoriteAction) {
    return action.products;
  } else if (action is GetProductsFavoriteAction) {
    return action.products;
  }

  return products;
}

List<Product> productsCartReducer(List<Product> productsCart, action) {
  if (action is ToggleCartProductAction) {
    return action.cartProducts;
  } else if (action is GetProductsCartAction) {
    return action.productsCart;
  } else if (action is ChangeCartProductAction) {
    return action.cartProducts;
  } else if (action is ClearCartAction) {
    return [];
  }

  return productsCart;
}
