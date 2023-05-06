import 'package:flutter/material.dart';
import 'AR.dart'; // Importe la nouvelle page

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage()));

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Aller à la nouvelle page'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocalAndWebObjectsWidget()),
            ); // Navigation vers la nouvelle page
          },
        ),
      ),
    );
  }
}
