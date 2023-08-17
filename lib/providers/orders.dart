import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  String productId;
  List<CartItem> products;
  double amount;
  DateTime dateTime;

  OrderItem(
      {required this.amount,
      required this.dateTime,
      required this.productId,
      required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String authToken;
  String userId;

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetProduct() async {
    var url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    var response = await http.get(Uri.parse(url));
    List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          productId: orderId,
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double amount) async {
    var timeStamp = DateTime.now();
    var url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    var response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProduct
              .map((e) => {
                    'title': e.title,
                    'id': e.id,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        amount: amount,
        dateTime: timeStamp,
        productId: json.decode(response.body)['name'],
        products: cartProduct,
      ),
    );
    notifyListeners();
  }

  void removeItem(String productId) {
    _orders.remove(productId);
    notifyListeners();
  }
}
