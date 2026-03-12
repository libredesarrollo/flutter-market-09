import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tienda_app/models/app_state.dart';
import 'package:tienda_app/models/product.dart';
import 'package:tienda_app/redux/actions.dart';

class CartItem extends StatefulWidget {
  const CartItem({super.key, required this.product});

  final Product product;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late final TextEditingController _quantityController;

  @override
  void initState() {
    _quantityController =
        TextEditingController(text: widget.product.cartCount.toString());
    super.initState();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
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
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        confirmDismiss: (_) {
          return showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Eliminar Item"),
              content: const Text(
                  "¿Seguro que desea eliminar este producto del carrito?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Si'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => callback(),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  '\$${widget.product.price}',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            title: Text(widget.product.name),
            subtitle: Text('Total: \$${(widget.product.price * (int.tryParse(_quantityController.text) ?? 1)).toStringAsFixed(2)}'),
            trailing: SizedBox(
              width: 50,
              child: StoreConnector<AppState, void Function(int)>(
                converter: (store) => (int n) =>
                    store.dispatch(changeCartProductAction(widget.product, n)),
                builder: (_, updateCallback) => TextField(
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                  controller: _quantityController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final n = int.tryParse(value);
                    if (value.isNotEmpty && n != null && n > 0) {
                      updateCallback(n);
                      setState(() {});
                    } else if (value.isEmpty) {
                      // Optionally handle empty state
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
