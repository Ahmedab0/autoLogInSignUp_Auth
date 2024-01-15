import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class Products with ChangeNotifier {
  List<Product> productsList = [];

  late String authToken;

  //Products(this.authToken, this.productsList);

  passingData(String authTok, List<Product> prodList) {
    authToken = authTok;
    productsList = prodList;
    notifyListeners();
  }

  // Get Data from DB
  Future<void> fetchData() async {
    final url =
        "https://restfullapi28sept2023-default-rtdb.firebaseio.com/product.json?auth=$authToken";
    //const url = "https://flutter-app-21-08-2023-default-rtdb.firebaseio.com/product.json";
    try {
      final http.Response res = await http.get(Uri.parse(url));
      final Map<String, dynamic> extractedData =
          json.decode(res.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        print('XXXXXXXXXXXXXXX : $prodId');
        print('YYYYYYYYYYYYYYY: $prodData');

        final prodIndex =
            productsList.indexWhere((element) => element.id == prodId);

        // the product is exist.. Update it
        if (prodIndex >= 0) {
          productsList[prodIndex] = Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          );
        } else {
          // the product not existing adding it to list
          productsList.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          ));
        }
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Up Date Date
  Future<void> updateData(String id) async {
    final url =
        "https://flutter-app-21-08-2023-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken";

    final prodIndex = productsList.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      // 1# update the product in DB
      await http.patch(Uri.parse(url),
          body: json.encode({
            "title": "new title 4",
            "description": "new description 2",
            "price": 1580.8,
            "imageUrl":
                "https://cdn.pixabay.com/photo/2015/06/19/21/24/the-road-815297__340.jpg",
          }));

      // 2# update the product in App
      productsList[prodIndex] = Product(
        id: id,
        title: "new title 4",
        description: "new description 2",
        price: 199.8,
        imageUrl:
            "https://cdn.pixabay.com/photo/2015/06/19/21/24/the-road-815297__340.jpg",
      );
      notifyListeners();
    } else {
      print(".Show toast.");
    }
  }

  // Post Date (addProduct)
  Future<void> add({
    required String id,
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    final url =
        'https://flutter-app-21-08-2023-default-rtdb.firebaseio.com/product.json?auth=$authToken';
    try {
      http.Response res = await http.post(
        Uri.parse(url),
        body: json.encode({
          "title": title,
          "description": description,
          "price": price,
          "imageUrl": imageUrl,
        }),
      );
      print(json.decode(res.body));

      productsList.add(
        Product(
          id: json.decode(res.body)['name'],
          title: title,
          description: description,
          price: price,
          imageUrl: imageUrl,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // delete data
  Future<void> delete(String id) async {
    final url =
        "https://flutter-app-21-08-2023-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken";

    final prodIndex = productsList.indexWhere((element) => element.id == id);
    Product? prodItem = productsList[prodIndex];
    // 1# remove product from App
    productsList.removeAt(prodIndex);
    notifyListeners();
    // 2# remove product from DB
    var res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      /// Ex: Net error
      // # insert product to App
      productsList.insert(prodIndex, prodItem);
      notifyListeners();
      print("Could not deleted item");

      /// show toast
    } else {
      prodItem = null;
      print("Item deleted");
    }
  }
} // Products

