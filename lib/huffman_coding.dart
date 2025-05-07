import 'dart:collection';
import 'dart:typed_data';
import 'dart:math' show log;
import 'package:ds_collection/ds_collection.dart';

// Huffman Tree Node class for encoding
class HuffmanNode implements Comparable<HuffmanNode> {
  int? value;
  int frequency;
  HuffmanNode? left, right;

  HuffmanNode({this.value, required this.frequency, this.left, this.right});

  @override
  int compareTo(HuffmanNode other) {
    return frequency - other.frequency;
  }
}

class HuffmanCoding {
  // Build Huffman tree from frequency map
  static HuffmanNode buildHuffmanTree(Map<int, int> frequencyMap) {
    // Create a priority queue for Huffman nodes
    final priorityQueue = HeapPriorityQueue();
    
    // Add all leaf nodes to the priority queue
    frequencyMap.forEach((value, frequency) {
      priorityQueue.add(HuffmanNode(value: value, frequency: frequency));
    });
    
    // Build the Huffman tree
    while (priorityQueue.length > 1) {
      // Extract two nodes with lowest frequency
      final left = priorityQueue.removeFirst();
      final right = priorityQueue.removeFirst();
      
      // Create a new internal node with these two nodes as children
      final parent = HuffmanNode(
        frequency: left.frequency + right.frequency,
        left: left,
        right: right
      );
      
      // Add the new node to the priority queue
      priorityQueue.add(parent);
    }
    
    // Return the root of the Huffman tree
    return priorityQueue.removeFirst();
  }
  
  // Generate Huffman codes from Huffman tree
  // Using List<int> for bits instead of String for better performance
  static Map<int, List<int>> generateHuffmanCodes(HuffmanNode root) {
    final Map<int, List<int>> huffmanCodes = {};
    _generateCodesRecursive(root, <int>[], huffmanCodes);
    return huffmanCodes;
  }
  
  // Helper method for generateHuffmanCodes
  // Now uses List<int> for codes (0 and 1 values) instead of Strings
  static void _generateCodesRecursive(HuffmanNode? node, List<int> code, Map<int, List<int>> huffmanCodes) {
    if (node == null) return;
    
    // If this is a leaf node, store its code
    if (node.value != null) {
      huffmanCodes[node.value!] = List<int>.from(code); // Make a copy to avoid reference issues
    }
    
    // Recursive calls for left and right children
    final leftCode = List<int>.from(code)..add(0);
    final rightCode = List<int>.from(code)..add(1);
    
    _generateCodesRecursive(node.left, leftCode, huffmanCodes);
    _generateCodesRecursive(node.right, rightCode, huffmanCodes);
  }
  
  // Encode data using Huffman codes - optimized version
  static List<bool> huffmanEncode(List<int> data, Map<int, List<int>> huffmanCodes) {
    // Direct bit collection instead of using string operations
    final List<bool> bitList = [];
    
    for (final value in data) {
      final code = huffmanCodes[value];
      if (code != null) {
        for (final bit in code) {
          bitList.add(bit == 1);
        }
      }
    }
    
    return bitList;
  }
  
  // Convert list of bits to compact byte array
  static Uint8List bitsToBytes(List<bool> bits) {
    final int byteCount = (bits.length + 7) ~/ 8;
    final bytes = Uint8List(byteCount);
    
    for (int i = 0; i < bits.length; i++) {
      if (bits[i]) {
        bytes[i ~/ 8] |= (1 << (7 - (i % 8)));
      }
    }
    
    return bytes;
  }
  
  // Performance-optimized version that handles negative values
  static Map<String, dynamic> compressData(List<int> data, {bool calculateMetrics = false}) {
    // Count frequency of each value
    final Map<int, int> frequencyMap = {};
    int minValue = 0;
    int maxValue = 0;
    
    for (final value in data) {
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
      frequencyMap[value] = (frequencyMap[value] ?? 0) + 1;
    }
    
    // Build Huffman tree and generate codes
    final huffmanTree = buildHuffmanTree(frequencyMap);
    final huffmanCodes = generateHuffmanCodes(huffmanTree);
    
    // Encode the data
    final encodedBits = huffmanEncode(data, huffmanCodes);
    final compressedBytes = bitsToBytes(encodedBits);
    
    // Build basic result
    final result = {
      'compressedData': compressedBytes,
      'huffmanCodes': huffmanCodes,
      'compressionRatio': data.length / compressedBytes.length,
      'valueRange': {'min': minValue, 'max': maxValue},
    };
    
    // Only calculate entropy metrics if explicitly requested
    if (calculateMetrics) {
      double originalEntropy = 0.0;
      for (final entry in frequencyMap.entries) {
        final probability = entry.value / data.length;
        originalEntropy -= probability * (log(probability) / log(2)); // log base 2
      }
      
      double huffmanEntropy = 0.0;
      huffmanCodes.forEach((symbol, code) {
        final frequency = frequencyMap[symbol] ?? 0;
        final probability = frequency / data.length;
        
        if (probability > 0) {
          final codeLength = code.length;
          huffmanEntropy += probability * codeLength;
        }
      });
      
      result.addAll({
        'uniqueSymbols': huffmanCodes.length,
        'originalEntropy': originalEntropy,
        'huffmanEntropy': huffmanEntropy,
        'encodingEfficiency': originalEntropy > 0 ? huffmanEntropy / originalEntropy : 0,
      });
    }
    
    return result;
  }
  
  // Optional: Convert the numeric bit representation back to strings for compatibility if needed
  static Map<int, String> convertNumericCodesToStrings(Map<int, List<int>> numericCodes) {
    final Map<int, String> stringCodes = {};
    numericCodes.forEach((key, value) {
      stringCodes[key] = value.map((bit) => bit.toString()).join('');
    });
    return stringCodes;
  }
}