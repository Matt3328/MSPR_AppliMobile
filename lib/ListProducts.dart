import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:model3d/main.dart';
import 'package:path_provider/path_provider.dart';
import 'Products.dart';
import 'ProductDetails.dart';


void resetAuth(BuildContext context) {
  final storage = FlutterSecureStorage();
  storage.delete(key: "BasicAuth");
  Navigator.push(
      context,
    MaterialPageRoute(builder: (context) => MyApp()),
  );
}

class ListProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Produits'),
          leading: IconButton(
            icon: Icon(Icons.pages),
            onPressed: () {
              resetAuth(context);
            },
          ),
        ),
        body: Center(
          child: FutureBuilder<List<Product>>(
            future: fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(products[index].name),
                      subtitle: Text(products[index].details['description']),
                      trailing: Text('\$${products[index].details['price']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetails(
                              product: products[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
