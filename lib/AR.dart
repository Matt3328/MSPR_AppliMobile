import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:io';

class ARObject extends StatefulWidget {
  ARObject({Key? key}) : super(key: key);
  @override
  _ARObjectState createState() =>
      _ARObjectState();
}

class _ARObjectState extends State<ARObject> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARNode? localObjectNode;
  ARNode? webObjectNode;
  ARNode? fileSystemNode;
  HttpClient? httpClient;


  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Réalité Augmenté'),
        ),
        body: Container(
            child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              ),
            ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) async{
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: false,
      showAnimatedGuide: false,
    );
    this.arObjectManager!.onInitialize();

    var newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: "assets/models/scene.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.5, 0.0, -2.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0));

// Add the node to the ARObjectManager
    this.arObjectManager!.addNode(newNode);

// Store the node for future reference
    this.localObjectNode = newNode;

  }
}