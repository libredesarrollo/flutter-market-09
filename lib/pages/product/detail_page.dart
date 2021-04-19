import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:market/models/product.dart';
import 'package:market/models/app_state.dart';
import 'package:market/redux/actions.dart';

class DetailPage extends StatefulWidget {
  static const ROUTE = "/detail";

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _quantity = TextEditingController();

  bool _loadingCart = false;

  @override
  Widget build(BuildContext context) {
    Product productModal = ModalRoute.of(context).settings.arguments;
    _quantity.text =
        productModal.cartCount > 0 ? productModal.cartCount.toString() : "1";

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          final Product product = state.findOne(productModal);

          return Scaffold(
            appBar: AppBar(
              title: Text(product.name),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Image.network(product.image),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StoreConnector<AppState, VoidCallback>(
                          converter: (store) => () async {
                            //store.dispatch(updateProductAction(product));
                            final c = int.tryParse(_quantity.text);

                            setState(() {
                              _loadingCart = true;
                            });
                            await store
                                .dispatch(toggleCartProductAction(product, c));
                            setState(() {
                              _loadingCart = false;
                            });
                          },
                          builder: (_, callback) {
                            return GestureDetector(
                                onTap: () {
                                  callback();
                                },
                                child: Wrap(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 10.0),
                                      width: 30,
                                      height: 22,
                                      child: TextField(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        textAlign: TextAlign.center,
                                        controller: _quantity,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9]'))
                                        ],
                                        onChanged: (String value) {
                                          int n = 1;
                                          try {
                                            n = int.parse(value);
                                            if (n <= 0) {
                                              n = 1;
                                              _quantity.text = n.toString();
                                            }
                                          } catch (e) {}
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    _loadingCart
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator())
                                        : Icon(
                                            product.cartCount >= 1
                                                ? Icons.shopping_cart
                                                : Icons.shopping_cart_outlined,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                  ],
                                ));
                          },
                        ),
                        StoreConnector<AppState, VoidCallback>(
                          converter: (store) => () =>
                              store.dispatch(toggleFavoriteAction(product)),
                          builder: (_, callback) {
                            return GestureDetector(
                              onTap: () {
                                callback();
                              },
                              child: Icon(
                                product.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: Theme.of(context).accentColor,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      "${product.price.toString()} \$",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(product.description),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
