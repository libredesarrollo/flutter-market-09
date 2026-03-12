import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/models/product.dart';
import 'package:tienda_app/widgets/cart_item.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key, required this.onInit});

  static const String ROUTE = "/cart";
  final VoidCallback onInit;

  @override
  State<IndexPage> createState() => _IndexPageState();
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
            title: const Text("Tu Carrito"),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.credit_card)),
              ],
            ),
          ),
          body: TabBarView(children: [_cartTab(state), _orderTab(state)]),
        ),
      ),
    );
  }

  Widget _cartTab(AppState state) {
    final List<Product> productsCart = state.productsCart;

    if (productsCart.isEmpty) {
      return const Center(child: Text("Tu carrito está vacío"));
    }

    return ListView.builder(
      itemCount: productsCart.length,
      itemBuilder: (_, index) => CartItem(product: productsCart[index]),
    );
  }

  Widget _orderTab(AppState state) {
    return const Center(
      child: Text("Sección de Órdenes (Próximamente)"),
    );
  }
}
