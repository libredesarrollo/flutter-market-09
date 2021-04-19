import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:market/models/app_state.dart';
import 'package:market/models/product.dart';
import 'package:market/redux/actions.dart';

class CartItem extends StatefulWidget {
  final Product product;
  CartItem({@required this.product});

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final TextEditingController _quantity = TextEditingController();
  double totalPrice;

  @override
  void initState() {
    _quantity.text = widget.product.cartCount.toString();
    totalPrice = widget.product.price * widget.product.cartCount;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, VoidCallback>(
        converter: (store) =>
            () => store.dispatch(toggleCartProductAction(widget.product, 0)),
        builder: (_, callback) => Dismissible(
              key: ValueKey(widget.product.id),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: EdgeInsets.only(left: 20),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                color: Colors.red,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Text(
                        '\$${widget.product.price}',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  title: Text(widget.product.name),
                  subtitle: Text('Precio c/u \$${(widget.product.price)}'),
                  trailing: Wrap(
                    children: [
                      Container(
                        width: 30,
                        height: 18,
                        child: StoreConnector<AppState, VoidCallback>(
                          converter: (store) => () {
                            int n = int.tryParse(_quantity.text);
                            print(n);
                            store.dispatch(
                                changeCartProductAction(widget.product, n));
                          },
                          builder: (_, callback) => TextField(
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                            controller: _quantity,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                            ],
                            onChanged: (String value) {
                              int n = 1;
                              try {
                                n = int.parse(value);
                                if (n <= 0) {
                                  n = 1;
                                  _quantity.text = n.toString();
                                }
                                callback();
                              } catch (e) {}

                              setState(() {
                                totalPrice = widget.product.price * n;
                              });
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Text(' x \$${(widget.product.price)} = \$$totalPrice',
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                ),
              ),
              confirmDismiss: (_) {
                return showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Eliminar Item"),
                    content: Text(
                        "¿Seguro que desea eliminar el item del carrito de compras?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('No')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Si')),
                    ],
                  ),
                );
              },
              onDismissed: (direction) => callback(),
            ));
  }
}
