import 'package:flutter/material.dart';
import 'package:model3d/AR.dart';
import 'Products.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  ProductDetails({required this.product});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<Map<String, dynamic>> futureProductDetails;

  @override
  void initState() {
    super.initState();
    futureProductDetails = fetchProductDetails(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureProductDetails,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> productDetails = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.product.name),
                  SizedBox(height: 20),
                  Text(productDetails['description']),
                  SizedBox(height: 20),
                  Text('\$${productDetails['price']}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ARObject()),
                      );
                    },
                    child: Text('Voir l''objet en réalité augmenté'),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

