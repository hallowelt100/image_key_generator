import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "HomeScreen.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: HomeScreen(camera: firstCamera),
    )
  );
}
