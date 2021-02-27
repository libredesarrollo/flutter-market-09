import 'package:flutter/material.dart';
import 'package:market/pages/login_page.dart';
import 'package:market/pages/product/products_page.dart';
import 'package:market/pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          accentColor: Color(0xFFFF5722),
          primaryColorDark: Color(0xFF512DA8),
          primaryColor: Color(0xFF673AB7),
          textTheme: TextTheme(
              headline1: TextStyle(fontSize: 35.0, fontWeight:  FontWeight.bold),
              headline2: TextStyle(fontSize: 21.0, fontWeight:  FontWeight.bold),
              headline3: TextStyle(fontSize: 17.0),
              headline6: TextStyle(fontSize: 15.0),
              bodyText1: TextStyle(fontSize: 14.0),
              bodyText2: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey[300])),
          brightness: Brightness.dark),
      title: 'Tienda en Línea',
      initialRoute: LoginPage.ROUTE,
      routes: {
        ProductsPage.ROUTE: (_) => ProductsPage(),
        LoginPage.ROUTE: (_) => LoginPage(),
        RegisterPage.ROUTE: (_) => RegisterPage()
      },
    );
  }
}
