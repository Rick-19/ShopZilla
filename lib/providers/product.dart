import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String? title;
  final String? id;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.description,
    required this.imageUrl,
    this.isFavourite = false,
    required this.title,
    required this.price,
  });

  void setFavVal(bool oldStatus) {
    isFavourite = oldStatus;
    notifyListeners();
  }

  Future<void> toggleFavourite(String authToken) async {
    var oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    var url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    try {
      var response = await http.patch(Uri.parse(url),
          body: json.encode({
            'isFavorite': isFavourite,
          }));
      if (response.statusCode >= 400) {
        setFavVal(oldStatus);
      }
    } catch (_) {
      setFavVal(oldStatus);
    }
  }
}
