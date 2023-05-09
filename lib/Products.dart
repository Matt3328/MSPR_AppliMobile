import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



class Product {
  final String id;
  final String name;
  final Map<String, dynamic> details;
  final int stock;
  final DateTime createdAt;

  Product({required this.id, required this.name, required this.details, required this.stock, required this.createdAt});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      details: json['details'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

Future<List<Product>> fetchProducts() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'BasicAuth');
  await dotenv.load();
  String apiBaseUrl = dotenv.env['API_BASE_URL']!;
  final response = await http.get(Uri.parse(apiBaseUrl + 'api/v1/products'), headers: {'Authorization': 'Basic $token'});
  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
    List<Product> products = [];
    jsonList.forEach((json) {
      Product product = Product.fromJson(json);
      products.add(product);
    });
    return products;
  } else {
    throw Exception('Erreur dans la récupération des produits');
  }
}

Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'BasicAuth');
  await dotenv.load();
  String apiBaseUrl = dotenv.env['API_BASE_URL']!;
  final response = await http.get(Uri.parse(apiBaseUrl + 'api/v1/products/$productId'), headers: {'Authorization': 'Basic $token'});

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    return jsonResponse['details'];
  } else {
    throw Exception('Erreur dans la récupération du produit');
  }
}
