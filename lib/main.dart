import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:tienda_app/pages/product/detail_page.dart';
import 'package:tienda_app/redux/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:tienda_app/redux/reducers.dart';
import 'package:tienda_app/models/app_state.dart';

import 'package:tienda_app/pages/login_page.dart';
import 'package:tienda_app/pages/product/products_page.dart';
import 'package:tienda_app/pages/register_page.dart';

import 'package:tienda_app/pages/cart/index_page.dart' as cart_page;

void main() {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware],
  );

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF673AB7),
            primary: const Color(0xFF673AB7),
            secondary: const Color(0xFFFF5722),
            brightness: Brightness.dark,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 17.0),
            titleLarge: TextStyle(fontSize: 15.0),
            bodyLarge: TextStyle(fontSize: 14.0),
            bodyMedium: TextStyle(
                fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
        title: 'Tienda en Línea',
        initialRoute: ProductsPage.ROUTE,
        routes: {
          ProductsPage.ROUTE: (_) => ProductsPage(onInit: () {
                store.dispatch(getUserAction);
                store.dispatch(getProductsAction);
              }),
          LoginPage.ROUTE: (_) => const LoginPage(),
          RegisterPage.ROUTE: (_) => const RegisterPage(),
          DetailPage.ROUTE: (_) => const DetailPage(),
          cart_page.IndexPage.ROUTE: (_) => cart_page.IndexPage(onInit: () {
                // Initial logic for cart page if needed
              }),
        },
      ),
    );
  }
}
