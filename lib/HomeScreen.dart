import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_key_generator/TakePicture.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;
  
  const HomeScreen({super.key, required this.camera});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Key Generator"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Take a picture to generate a key"),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(camera: widget.camera),
                  ),
                );
              }, 
              icon: const Icon(Icons.camera_alt),
              iconSize: 50,
              color: Colors.blue,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TakePictureScreen(camera: widget.camera),
              ),
      );
            },
        child: const Icon(Icons.camera_alt_outlined),
        ),
    );
  }
}
