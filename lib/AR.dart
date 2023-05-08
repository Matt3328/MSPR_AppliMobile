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
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'dart:io';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

class ARObject extends StatefulWidget {
  ARObject({Key? key}) : super(key: key);
  @override
  _ARObjectState createState() =>
      _ARObjectState();
}

class _ARObjectState extends State<ARObject> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  //String localObjectReference;
  ARNode? localObjectNode;
  //String webObjectReference;
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
        //appBar: AppBar(
        //  title: const Text('Local & Web Objects'),
        //),
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
      //customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: false,
      handleTaps: false,
      showAnimatedGuide: false,
    );
    this.arObjectManager!.onInitialize();


    //Download model to file system
    //httpClient = new HttpClient();
    //_downloadFile(
    //    "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
    //    "LocalDuck.glb");
    //String content = await rootBundle.loadString('assets/cofee_machine.glb');
    //copyGLBToLocalFolder('assets/cofee_machine.glb');
    //Future.delayed(Duration(seconds: 2));
    // Alternative to use type fileSystemAppFolderGLTF2:
    //_downloadAndUnpack(
    //    "https://drive.google.com/uc?export=download&id=1fng7yiK0DIR0uem7XkV2nlPSGH9PysUs",
    //    "Chicken_01.zip");
    //File file = await copyGLBToLocalFolder('high_detailed_mouse.glb');
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

  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient!.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    print("Downloading finished, path: " + '$dir/$filename');
    return file;
  }

  Future<String> getGLBFilePath(String filename) async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path + '/$filename';
  }

  Future<File> copyGLBToLocalFolder(String filename) async {
    String path = await getGLBFilePath(filename);
    ByteData data = await rootBundle.load('models/$filename');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    File file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _downloadAndUnpack(String url, String filename) async {
    var request = await httpClient!.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    print("Downloading finished, path: " + '$dir/$filename');

    // To print all files in the directory: print(Directory(dir).listSync());
    try {
      await ZipFile.extractToDirectory(
          zipFile: File('$dir/$filename'), destinationDir: Directory(dir));
      print("Unzipping successful");
    } catch (e) {
      print("Unzipping failed: " + e.toString());
    }
  }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    if (this.localObjectNode != null) {
      this.arObjectManager!.removeNode(this.localObjectNode!);
      this.localObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.fileSystemAppFolderGLB,
          uri: "cofee_machine.glb",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.5, 0.0, -2.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));

// Add the node to the ARObjectManager
      this.arObjectManager!.addNode(newNode);

// Store the node for future reference
      this.localObjectNode = newNode;
    }
  }

  Future<void> onWebObjectAtOriginButtonPressed() async {
    if (this.webObjectNode != null) {
      this.arObjectManager!.removeNode(this.webObjectNode!);
      this.webObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri:
          "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
          scale: Vector3(0.2, 0.2, 0.2));
      bool? didAddWebNode = await this.arObjectManager!.addNode(newNode);
      this.webObjectNode = (didAddWebNode!) ? newNode : null;
    }
  }

  Future<void> onFileSystemObjectAtOriginButtonPressed() async {
    if (this.fileSystemNode != null) {
      this.arObjectManager!.removeNode(this.fileSystemNode!);
      this.fileSystemNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.fileSystemAppFolderGLB,
          uri: "cofee_machine.glb",
          scale: Vector3(0.2, 0.2, 0.2),
          position: Vector3(0.5, 0.0, -2.0),
          rotation: Vector4(1.0, 0.0, 0.0, 0.0));

// Add the node to the ARObjectManager
      this.arObjectManager!.addNode(newNode);

// Store the node for future reference
      this.localObjectNode = newNode;
    }
  }

  Future<void> onLocalObjectShuffleButtonPressed() async {
    if (this.localObjectNode != null) {
      var newScale = Random().nextDouble() / 3;
      var newTranslationAxis = Random().nextInt(3);
      var newTranslationAmount = Random().nextDouble() / 3;
      var newTranslation = Vector3(0, 0, 0);
      newTranslation[newTranslationAxis] = newTranslationAmount;
      var newRotationAxisIndex = Random().nextInt(3);
      var newRotationAmount = Random().nextDouble();
      var newRotationAxis = Vector3(0, 0, 0);
      newRotationAxis[newRotationAxisIndex] = 1.0;

      final newTransform = Matrix4.identity();

      newTransform.setTranslation(newTranslation);
      newTransform.rotate(newRotationAxis, newRotationAmount);
      newTransform.scale(newScale);

      this.localObjectNode!.transform = newTransform;
    }
  }

  Future<void> onWebObjectShuffleButtonPressed() async {
    if (this.webObjectNode != null) {
      var newScale = Random().nextDouble() / 3;
      var newTranslationAxis = Random().nextInt(3);
      var newTranslationAmount = Random().nextDouble() / 3;
      var newTranslation = Vector3(0, 0, 0);
      newTranslation[newTranslationAxis] = newTranslationAmount;
      var newRotationAxisIndex = Random().nextInt(3);
      var newRotationAmount = Random().nextDouble();
      var newRotationAxis = Vector3(0, 0, 0);
      newRotationAxis[newRotationAxisIndex] = 1.0;

      final newTransform = Matrix4.identity();

      newTransform.setTranslation(newTranslation);
      newTransform.rotate(newRotationAxis, newRotationAmount);
      newTransform.scale(newScale);

      this.webObjectNode!.transform = newTransform;
    }
  }
}