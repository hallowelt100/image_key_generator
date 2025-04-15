import 'package:flutter/material.dart';
import 'dart:io'; 
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';

import 'package:image_key_generator/GenerateKey.dart';

enum SelectedImage { image1, image2, difference }

class ImageProcess extends StatefulWidget {
  final String imagePath1;
  final String imagePath2;

  const ImageProcess({
    super.key, 
    required this.imagePath1, 
    required this.imagePath2
  });

  @override
  State<ImageProcess> createState() => ImageProcessState();
}

class ImageProcessState extends State<ImageProcess> {
  double? _entropy1;
  double? _entropy2;

  double? _diffenrenceEntropy;

  @override
  void initState() {
    super.initState();
    _calculateImageDifference();
    _calculateImageEntropy();
  }

  void _calculateImageDifference() async {
    final file1 = File(widget.imagePath1);
    final file2 = File(widget.imagePath2);
    final bytes1 = await file1.readAsBytes();
    final bytes2 = await file2.readAsBytes();
    final image1 = img.decodeImage(Uint8List.fromList(bytes1));
    final image2 = img.decodeImage(Uint8List.fromList(bytes2));

    if (image1 != null && image2 != null) {
      final pixels1 = image1.getBytes();
      final pixels2 = image2.getBytes();

      int minLength = min(pixels1.length, pixels2.length);
      
      // Create a list to store the difference values for entropy calculation
      List<int> diffValues = [];
      
      for (int i = 0; i < minLength; i++) {
        int diff = (pixels1[i] - pixels2[i]).abs();
        diffValues.add(diff);
      }

      _calculateDifferenceEntropy(diffValues);
    }
  }

  void _calculateDifferenceEntropy(List<int> diffValues) {
    final histogram = List.filled(256, 0);
    
    // Count occurrences of each difference value
    for (var diff in diffValues) {
      // Ensure the difference value is within 0-255 range
      int index = min(diff, 255);
      histogram[index]++;
    }

    double entropy = 0.0;
    final totalValues = diffValues.length;
    
    for (var count in histogram) {
      if (count > 0) {
        final probability = count / totalValues;
        entropy -= probability * (log(probability) / 2.302585092994046); // log base 10
      }
    }

    setState(() {
      _diffenrenceEntropy = entropy;
    });
  }

  void _calculateImageEntropy() async {
    // Process first image
    final file1 = File(widget.imagePath1);
    final bytes1 = await file1.readAsBytes();
    final image1 = img.decodeImage(Uint8List.fromList(bytes1));

    if (image1 != null) {
      final histogram1 = List.filled(256, 0);
      for (var pixel in image1.getBytes()) {
        histogram1[pixel]++;
      }

      final totalPixels1 = image1.width * image1.height;
      double entropy1 = 0.0;
      for (var count in histogram1) {
        if (count > 0) {
          final probability = count / totalPixels1;
          entropy1 -= probability * (log(probability) / 2.302585092994046); // log base 10
        }
      }

      // Process second image
      final file2 = File(widget.imagePath2);
      final bytes2 = await file2.readAsBytes();
      final image2 = img.decodeImage(Uint8List.fromList(bytes2));

      double entropy2 = 0.0;
      if (image2 != null) {
        final histogram2 = List.filled(256, 0);
        for (var pixel in image2.getBytes()) {
          histogram2[pixel]++;
        }

        final totalPixels2 = image2.width * image2.height;
        for (var count in histogram2) {
          if (count > 0) {
            final probability = count / totalPixels2;
            entropy2 -= probability * (log(probability) / 2.302585092994046); // log base 10
          }
        }
      }

      setState(() {
        _entropy1 = entropy1;
        _entropy2 = entropy2;
      });
    }
  }

  SelectedImage? _selectedImage = SelectedImage.image1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Comparison"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Image Comparison Results",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text("Image 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Image.file(
                      File(widget.imagePath1),
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    if (_entropy1 != null)
                      Text("Entropy: ${_entropy1!.toStringAsFixed(3)} Bits", 
                          style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            
            // Second Image
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text("Image 2", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Image.file(
                      File(widget.imagePath2),
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    if (_entropy2 != null)
                      Text("Entropy: ${_entropy2!.toStringAsFixed(3)} Bits", 
                          style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            ],
            ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("Difference Comparison", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_diffenrenceEntropy != null)
                        Text("Difference Entropy: ${_diffenrenceEntropy!.toStringAsFixed(3)} Bits",
                            style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  ),
                ),
                const Text("Generate the key using..."),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title: const Text("Image 1"),
                      leading: Radio<SelectedImage>(
                        value: SelectedImage.image1, 
                        groupValue: _selectedImage, 
                        onChanged: (SelectedImage? value) {
                          setState(() {
                            _selectedImage = value;
                          });
                        },
                        ),
                    ),
                    ListTile(
                      title: const Text("Image 2"),
                      leading: Radio<SelectedImage>(
                        value: SelectedImage.image2,
                        groupValue: _selectedImage,
                        onChanged: (SelectedImage? value) {
                          setState(() {
                            _selectedImage = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text("Difference"),
                      leading: Radio<SelectedImage>(
                        value: SelectedImage.difference,
                        groupValue: _selectedImage,
                        onChanged: (SelectedImage? value) {
                          setState(() {
                            _selectedImage = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GenerateKeyScreen(selectedImage: _selectedImage,)
            ),
          );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  child: const Text("Generate the key"),
                ),
          ],
        ),
      ),
    );
  }
}
