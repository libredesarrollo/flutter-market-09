import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:market/pages/product/detail_page.dart';
import 'package:market/redux/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:market/redux/reducers.dart';
import 'package:market/models/app_state.dart';

import 'package:market/pages/login_page.dart';
import 'package:market/pages/product/products_page.dart';
import 'package:market/pages/register_page.dart';

import 'package:market/pages/cart/index_page.dart' as cartPage;

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState.initial(), middleware: [thunkMiddleware]);

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final store;

  const MyApp({this.store});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: ThemeData(
            accentColor: Color(0xFFFF5722),
            primaryColorDark: Color(0xFF512DA8),
            primaryColor: Color(0xFF673AB7),
            textTheme: TextTheme(
                headline1:
                    TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                headline2:
                    TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                headline3: TextStyle(fontSize: 17.0),
                headline6: TextStyle(fontSize: 15.0),
                bodyText1: TextStyle(fontSize: 14.0),
                bodyText2: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey[300])),
            brightness: Brightness.dark),
        title: 'Tienda en Línea',
        initialRoute: ProductsPage.ROUTE,
        routes: {
          ProductsPage.ROUTE: (_) => ProductsPage(onInit: ()  {
                store.dispatch(getUserAction);
                store.dispatch(getProductsAction);
                
              }),
          LoginPage.ROUTE: (_) => LoginPage(),
          RegisterPage.ROUTE: (_) => RegisterPage(),
          DetailPage.ROUTE: (_) => DetailPage(),
          cartPage.IndexPage.ROUTE: (_) => cartPage.IndexPage(onInit: () {
                //
              }),
        },
      ),
    );
  }
}
