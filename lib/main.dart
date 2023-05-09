import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model3d/ListProducts.dart';
import 'package:model3d/dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _storageKey = 'BasicAuth';

void main() {
  loadDotEnv();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRScanner(),
    );
  }
}

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: _storageKey);
    if (token != null) {
      setState(() {
        isLoggedIn = true;
      });
      _navigateToListProducts();
    }
  }

  Future<void> _storeAuthToken(String token) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: _storageKey, value: token);
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (isLoggedIn) {
        return; // already logged in
      }
        await _storeAuthToken(scanData.code ?? "");
        setState(() {
          isLoggedIn = true;
        });
        _navigateToListProducts();
    });
  }

  void _navigateToListProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListProducts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: SafeArea(
        child: isLoggedIn
            ? Center(
          child: Text('Vous êtes connectés'),
        )
            : QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.blue,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 300,
          ),
        ),
      ),
    );
  }
}

















/*import 'package:flutter/material.dart';
import 'package:model3d/ListProducts.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('AR Test'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocalAndWebObjectsWidget()),
                ); // Navigation vers la nouvelle page
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Consulter la liste des produits'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListProducts()),
                ); // Navigation vers la nouvelle page
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/