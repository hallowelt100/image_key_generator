import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:asn1lib/asn1lib.dart' as asn1;

class GenerateKeyScreen extends StatefulWidget{
  
  final List<int>? imageData;
  
  const GenerateKeyScreen({super.key, 
    required this.imageData,
    });

  @override
  GenerateKeyScreenState createState() => GenerateKeyScreenState();
}

class GenerateKeyScreenState extends State<GenerateKeyScreen> {

  bool _isLoading = false;
  String? _publicKey;
  String? _privateKey;

  @override
  void initState() {
    super.initState();
    _generateKeyPair();
  }


  Future<void> _generateKeyPair() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<int> pixelValues = widget.imageData!;
      
      final entropy = Uint8List.fromList(pixelValues);
      final hash = sha256.convert(entropy).bytes;

      final secureRandom = FortunaRandom();
      secureRandom.seed(KeyParameter(Uint8List.fromList(hash)));

      final keyGen = RSAKeyGenerator()
        ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(
            BigInt.parse('65537'), // Public exponent
            2048, // Key size
            64, // Certainty
          ),
          secureRandom,
        ));

        final keyPair = keyGen.generateKeyPair();

        final publicKey = _encodeRSAPublicKeyToPem(keyPair.publicKey);
        final privateKey = _encodeRSAPrivateKeyToPem(keyPair.privateKey);

        setState(() {
          _publicKey = publicKey;
          _privateKey = privateKey;
          _isLoading = false;
        });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error generating key pair: $e");
    }
  }

  String _encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
    final algorithmSeq = asn1.ASN1Sequence();
    algorithmSeq.add(asn1.ASN1ObjectIdentifier([1, 2, 840, 113549, 1, 1, 1])); // RSA encryption OID
    algorithmSeq.add(asn1.ASN1Null()); // Null for RSA encryption

    final publicKeyAsn = asn1.ASN1Sequence();
    publicKeyAsn.add(asn1.ASN1Integer(publicKey.modulus!));
    publicKeyAsn.add(asn1.ASN1Integer(publicKey.exponent!));

    final publicKeyBitString = asn1.ASN1BitString(publicKeyAsn.encodedBytes);

    final topLevelSeq = asn1.ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeyBitString);

    final dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    final pemString = "-----BEGIN PUBLIC KEY-----\n"
      "$dataBase64\n"
      "-----END PUBLIC KEY-----";

      return pemString;
  }

  String _encodeRSAPrivateKeyToPem(RSAPrivateKey privateKey) {
    final version = asn1.ASN1Integer(BigInt.from(0));

    final privateKeySeq = asn1.ASN1Sequence();
    privateKeySeq.add(version);
    privateKeySeq.add(asn1.ASN1Integer(privateKey.modulus!));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.publicExponent!));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.privateExponent!));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.p!));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.q!));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.privateExponent! % (privateKey.p! - BigInt.one)));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.privateExponent! % (privateKey.q! - BigInt.one)));
    privateKeySeq.add(asn1.ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

    final dataBase64 = base64.encode(privateKeySeq.encodedBytes);
    final pemString = "-----BEGIN RSA PRIVATE KEY-----\n"
      "$dataBase64\n"
      "-----END RSA PRIVATE KEY-----";

    return pemString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Key'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'Generated Keys:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _isLoading ?
              const CircularProgressIndicator() :
              Text(
                      "Public Key:",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _publicKey!,
                      style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                    ),
                  ],),
              ),
              const SizedBox(height: 20),
              Text(
                      "Private Key:",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _privateKey!,
                      style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                    ),
                  ],
                  ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _publicKey!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Public Key copied to clipboard')),
                  );

                }, 
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                child: const Text('Copy Public Key'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _privateKey!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Private Key copied to clipboard')),
                  );
                }, 
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                child: const Text('Copy Private Key'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}