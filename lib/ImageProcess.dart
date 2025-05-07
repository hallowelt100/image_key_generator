import 'package:flutter/material.dart';
import 'dart:io'; 
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:image_key_generator/huffman_coding.dart';

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

  bool _isLoading = true;

  List<int>? _difference;
  double? _diffenrenceEntropy;
  Map<int, String>? _huffmanCodes;
  List<int>? _compressedDifference;
  double? _compressionRatio;
  double? _originalEntropy;
  double? _huffmanEntropy;
  double? _encodingEfficiency;

  @override
  void initState() {
    super.initState();
    _calculateImageDifference();
    _calculateImageEntropy();
  }

  // Apply Huffman coding to the difference data
  void _applyHuffmanCoding(List<int> diffValues) {
    // Use the optimized HuffmanCoding class with the new parameter
    final compressionResult = HuffmanCoding.compressData(diffValues, calculateMetrics: true);
    
    // Convert numeric codes to string format for display purposes
    final stringCodes = HuffmanCoding.convertNumericCodesToStrings(
      compressionResult['huffmanCodes'] as Map<int, List<int>>
    );
    
    setState(() {
      _huffmanCodes = stringCodes;
      _compressedDifference = compressionResult['compressedData'];
      _compressionRatio = compressionResult['compressionRatio'];
      _originalEntropy = compressionResult['originalEntropy'];
      _huffmanEntropy = compressionResult['huffmanEntropy'];
      _encodingEfficiency = compressionResult['encodingEfficiency'];
    });
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
        // Store the actual difference, including negative values
        int diff = pixels1[i] - pixels2[i];
        diffValues.add(diff);
      }

      _calculateDifferenceEntropy(diffValues);
      _applyHuffmanCoding(diffValues);

      setState(() {
        _isLoading = false;
        _difference = diffValues;
      });
    }
  }

  void _calculateDifferenceEntropy(List<int> diffValues) {
    // Find min and max values to determine histogram size
    int minValue = 0;
    int maxValue = 0;
    
    for (var diff in diffValues) {
      if (diff < minValue) minValue = diff;
      if (diff > maxValue) maxValue = diff;
    }
    
    // Create a histogram that can hold all values from min to max
    final int histogramSize = maxValue - minValue + 1;
    final histogram = List.filled(histogramSize, 0);
    
    // Count occurrences of each difference value
    for (var diff in diffValues) {
      // Calculate index relative to the minimum value
      int index = diff - minValue;
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
                      if (_compressionRatio != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Huffman Compression Ratio: ${_compressionRatio!.toStringAsFixed(2)}x",
                            style: const TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ),
                      if (_originalEntropy != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Original Data Entropy: ${_originalEntropy!.toStringAsFixed(3)} bits/symbol",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      if (_huffmanEntropy != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Huffman Codes Entropy: ${_huffmanEntropy!.toStringAsFixed(3)} bits/symbol",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {                    
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GenerateKeyScreen(imageData: _compressedDifference)
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
