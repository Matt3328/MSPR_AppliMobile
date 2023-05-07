import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final response = await http.get(Uri.parse('http://192.168.1.18:8080/products'), headers: {"Accept-Charset": "utf-8"});
  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
    List<Product> products = [];
    jsonList.forEach((json) {
      Product product = Product.fromJson(json);
      products.add(product);
    });
    return products;
  } else {
    throw Exception('Failed to fetch products');
  }
}

Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  final response = await http.get(Uri.parse('http://192.168.1.18:8080/products/$productId'));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    return jsonResponse['details'];
  } else {
    throw Exception('Failed to load product details');
  }
}
