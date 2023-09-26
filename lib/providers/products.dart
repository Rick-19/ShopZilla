import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String? userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  // void showFavorite() {
  //   _showFavorites = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorites = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProduct([bool setFilter = false]) async {
    String filterProducts =
        setFilter ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shopping-app-df65a-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterProducts';
    try {
      var response = await http.get(Uri.parse(url));
      var extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'].toDouble(),
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavorite'],
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProducts(Product product) async {
    final url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'isFavorite': product.isFavourite,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          },
        ),
      );
      print(json.decode(response.body));
      _items.add(Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProd) async {
    var prodIndex = _items.indexWhere((element) => element.id == newProd.id);
    final url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    if (prodIndex >= 0) {
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProd.title,
            'description': newProd.description,
            'price': newProd.price,
            'imageUrl': newProd.imageUrl,
          }));
      _items[prodIndex] = newProd;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    var url =
        "https://shopping-app-df65a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    var existingIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
    notifyListeners();
    var response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could Not Delete Product!');
    }
    existingProduct = null;
  }
}
