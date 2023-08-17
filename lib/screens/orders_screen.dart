import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _ordersFuture;

  Future fetchAndSet() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetProduct();
  }

  @override
  void initState() {
    setState(() {
      _ordersFuture = fetchAndSet();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            /*if (!snapshot.hasData)
              return Center(
                child: Text('No Orders to Show!'),
              );*/
            if (snapshot.error != null) {
              return Center(
                child: Text('No Orders to Show!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) {
                  return ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (context, index) => OrderItem(
                      order: orderData.orders[index],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
