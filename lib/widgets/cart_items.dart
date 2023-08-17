import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String? productId;
  final String? title;
  final int? quantity;
  final double? price;
  final String? id;
  const CartItem(
      {Key? key,
      this.id,
      this.price,
      this.quantity,
      this.title,
      this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId!);
      },
      background: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Do you want to remove the item from the cart?'),
            title: Text('Are You Sure?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('NO'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('YES'),
              )
            ],
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: ListTile(
          leading: CircleAvatar(
              child: Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(child: Text('₹${price}')))),
          title: Text(title!),
          subtitle: Text('₹${(price! * quantity!).toStringAsFixed(2)}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
