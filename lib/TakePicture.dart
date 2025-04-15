import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_key_generator/ImageProcess.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen ({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<String> capturedImages = [];
  
  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.veryHigh);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take 2 pictures")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text("Captured ${capturedImages.length}/2 images", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              if (capturedImages.length >= 2) {
                // Reset if we already have 2 images
                setState(() {
                  capturedImages = [];
                });
                return;
              }

              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                
                setState(() {
                  capturedImages.add(image.path);
                });
                
                if (capturedImages.length == 2) {
                  if (!context.mounted) return;
                  
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageProcess(
                        imagePath1: capturedImages[0],
                        imagePath2: capturedImages[1],
                      ),
                    ),
                  );
                }
              } catch (e) {
                print(e);
              }
            },
            child: Icon(capturedImages.length >= 2 ? Icons.refresh : Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Display the picture")),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Note: This class won't be used in the new flow
          // but keeping it for backward compatibility
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageProcess(
                imagePath1: imagePath,
                imagePath2: imagePath, // Duplicate for backward compatibility
              ),
            ),
          );
        },
        child: const Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}