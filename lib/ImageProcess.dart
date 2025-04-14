import 'package:flutter/material.dart';
import 'dart:io'; 
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';

class ImageProcess extends StatefulWidget {

  final String imagePath;

  const ImageProcess({super.key, required this.imagePath});

  @override
  State<ImageProcess> createState() => ImageProcessState();
}

class ImageProcessState extends State<ImageProcess> {
  double? _entropy;

  @override
  void initState() {
    super.initState();
    _calculateImageEntropy();
  }

  void _calculateImageEntropy() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      final histogram = List.filled(256, 0);
      for (var pixel in image.getBytes()) {
        histogram[pixel]++;
      }

      final totalPixels = image.width * image.height;
      double entropy = 0.0;
      for (var count in histogram) {
        if (count > 0) {
          final probability = count / totalPixels;
          entropy -= probability * (log(probability) / 2.302585092994046); // log base 10
        }
      }

      setState(() {
        _entropy = entropy;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Process the image"),
      ),
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
            const SizedBox(height: 20),
            if (_entropy != null)
              Text("Entropy: ${_entropy!.toStringAsFixed(3)} Bits"),
              if (_entropy !>= 5)
                Text("The Entropy is high, the image is likely to be random"),
              if (_entropy != null && _entropy! < 5)
                Text("The Entropy is low, the image is likely to be a pattern"),
          ],
        ),
      ),
    );
  }
}
