import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatefulWidget {
  final String imageBase64;

  const FullScreenImageScreen({super.key, required this.imageBase64});

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();

    imageBytes = base64Decode(widget.imageBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.memory(imageBytes, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
