import 'package:flutter/material.dart';
import 'dart:io';  // Für den Zugriff auf File

class ImageProcess extends StatefulWidget {

  final String imagePath;

  const ImageProcess({super.key, required this.imagePath});

  @override
  State<ImageProcess> createState() => ImageProcessState();
}

class calculateEntropy {

}

class ImageProcessState extends State<ImageProcess> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Process the image"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Placeholder"),
            const SizedBox(height: 20),
            Image.file(
              File(widget.imagePath),
              height: 300,
              fit: BoxFit.contain,
            ),
          ]
        ),
      ),
    );
  }
}
