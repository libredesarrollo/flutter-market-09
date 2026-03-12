import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/redux/actions.dart';

import 'package:tienda_app/pages/login_page.dart';
import 'package:tienda_app/pages/product/detail_page.dart';
import 'package:tienda_app/pages/cart/index_page.dart' as cart_page;

enum FilterOptions { favorite, all }

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.onInit});

  static const String ROUTE = "/";
  final VoidCallback onInit;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _showOnlyFavorite = false;

  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size size = MediaQuery.of(context).size;

    int countItem = orientation == Orientation.landscape ? 3 : 2;
    if (size.width > 800.0) {
      countItem = 4;
    }

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.shopping_bag),
              onPressed: () {
                Navigator.pushNamed(context, cart_page.IndexPage.ROUTE);
              },
            ),
            centerTitle: true,
            title: state.user == null
                ? const Text("Productos")
                : Text(state.user!.email),
            actions: [
              PopupMenuButton(
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    _showOnlyFavorite = selectedValue == FilterOptions.favorite;
                  });
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: FilterOptions.all,
                    child: Text('Todos'),
                  ),
                  const PopupMenuItem(
                    value: FilterOptions.favorite,
                    child: Text('Favoritos'),
                  )
                ],
              ),
              state.user == null
                  ? IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () {
                        Navigator.pushNamed(context, LoginPage.ROUTE);
                      },
                    )
                  : StoreConnector<AppState, VoidCallback>(
                      converter: (store) =>
                          () => store.dispatch(logoutUserAction),
                      builder: (_, callback) {
                        return IconButton(
                          icon: const Icon(Icons.exit_to_app),
                          onPressed: callback,
                        );
                      },
                    )
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: (_showOnlyFavorite ? state.favorites() : state.products).length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: countItem,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemBuilder: (_, i) {
              final products = _showOnlyFavorite ? state.favorites() : state.products;
              final product = products[i];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, DetailPage.ROUTE, arguments: product);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GridTile(
                    header: GridTileBar(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            product.cartCount >= 1
                                ? Icons.shopping_cart
                                : Icons.shopping_cart_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18,
                          ),
                          Icon(
                            product.favorite
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18,
                          )
                        ],
                      ),
                    ),
                    footer: GridTileBar(
                      backgroundColor: Colors.black87,
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${product.price} \$"),
                    ),
                    child: Hero(
                      tag: product.id,
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
