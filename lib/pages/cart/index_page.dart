import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:market/models/app_state.dart';
import 'package:market/models/product.dart';
import 'package:market/widgets/cart_item.dart';

class IndexPage extends StatefulWidget {
  static const ROUTE = "/cart";

  final Function() onInit;

  const IndexPage({this.onInit});

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  void initState() {
    widget.onInit();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) => Scaffold(
          appBar: AppBar(
            title: Text("Listado carrito"),
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.shopping_cart),
                ),
                Tab(
                  icon: Icon(Icons.credit_card),
                )
              ],
            ),
          ),
          body: TabBarView(children: [_cartTab(state), _orderTab(state)]),
        ),
      ),
    );
  }

  Widget _cartTab(AppState state) {
    List<Product> productsCart = state.productsCart;

    return ListView.builder(
        itemCount: productsCart.length,
        itemBuilder: (_, index) => CartItem(product: productsCart[index]));
  }

  Widget _orderTab(state) {
    // AppState state
    return Container(
      child: Text("Ordenes"),
    );
  }
}
