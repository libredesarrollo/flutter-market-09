import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tienda_app/models/product.dart';
import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/redux/actions.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  static const String ROUTE = "/detail";

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _quantity = TextEditingController();
  bool _loadingCart = false;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productModal = ModalRoute.of(context)?.settings.arguments as Product?;
    if (productModal == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }

    if (_quantity.text.isEmpty) {
      _quantity.text = productModal.cartCount > 0 ? productModal.cartCount.toString() : "1";
    }

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (_, state) {
        final Product product = state.findOne(productModal);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  product.image,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 200),
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StoreConnector<AppState, VoidCallback>(
                      converter: (store) => () async {
                        final c = int.tryParse(_quantity.text) ?? 1;
                        setState(() => _loadingCart = true);
                        await store.dispatch(toggleCartProductAction(product, c));
                        if (mounted) setState(() => _loadingCart = false);
                      },
                      builder: (_, callback) {
                        return GestureDetector(
                          onTap: callback,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                child: TextField(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                  controller: _quantity,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (String value) {
                                    int? n = int.tryParse(value);
                                    if (n != null && n <= 0) {
                                      _quantity.text = "1";
                                    }
                                  },
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _loadingCart
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      product.cartCount >= 1
                                          ? Icons.shopping_cart
                                          : Icons.shopping_cart_outlined,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                    StoreConnector<AppState, VoidCallback>(
                      converter: (store) => () =>
                          store.dispatch(toggleFavoriteAction(product)),
                      builder: (_, callback) {
                        return GestureDetector(
                          onTap: callback,
                          child: Icon(
                            product.favorite
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 15.0),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 15.0),
                Text(
                  "${product.price.toString()} \$",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(product.description),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
