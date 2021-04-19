import 'package:market/models/app_state.dart';
import 'package:market/redux/actions.dart';

AppState appReducer(AppState state, action) {
  return AppState(
      user: userReducer(state.user, action),
      products: productsReducer(state.products, action),
      productsCart: productsCartReducer(state.productsCart, action));
}

userReducer(user, action) {
  if (action is GetUserAction) return action.user;
  if (action is LogoutUserAction) return action.user;

  return user;
}

productsReducer(products, action) {
  if (action is GetProductsAction)
    return action.products;
  else if (action is UpdateProductAction) {
    final int index = products.indexWhere((p) => p.id == action.product.id);
    products[index] = action.product;

    //NO VA A FUNCIONAR PORQUE ES UN LISTDO DE TIPO DYNAMIC products = products.map((p) => p.id == action.product.id ? action.product : p).toList();

    return products;
  }
  else if (action is ToggleFavoriteAction) {
    return action.products;
  }
  else if (action is GetProductsFavoriteAction) {
    return action.products;
  }

  return products;
}

productsCartReducer(productsCart, action) {
  if (action is TogleCartProductAction) {
    return action.cartProducts;
  } else if (action is GetProductsCartAction) {
    return action.productsCart;

  } else if (action is ChangeCartProductAction) {
    return action.cartProducts;
  }

  return productsCart;
}
