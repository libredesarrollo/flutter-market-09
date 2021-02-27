import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {

  static const String ROUTE = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: Container(
        child: Text("Products"),
      ),
    );
  }
}
