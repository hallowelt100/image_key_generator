import 'package:flutter/material.dart';
import 'package:image_key_generator/ImageProcess.dart';

class GenerateKeyScreen extends StatefulWidget{
  const GenerateKeyScreen({super.key, 
    required this.selectedImage,
    });

  final SelectedImage? selectedImage;

  @override
  GenerateKeyScreenState createState() => GenerateKeyScreenState();
}

class GenerateKeyScreenState extends State<GenerateKeyScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Key'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selected Image: ${widget.selectedImage}'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}