import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class FullScreenImageScreen extends StatefulWidget {
  final String imageBase64;

  const FullScreenImageScreen({super.key, required this.imageBase64});

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  bool _isDownloading = false;

  Future<void> _downloadBase64Image() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // LOGIKA DOWNLOAD KHUSUS PLATFORM WEB BROWSER
      if (kIsWeb) {
        final String base64Data = widget.imageBase64.contains(',')
            ? widget.imageBase64
            : 'data:image/jpeg;base64,${widget.imageBase64}';
        final anchor = html.AnchorElement(href: base64Data)
          ..setAttribute(
            'download',
            'laporan_fasum_${DateTime.now().millisecondsSinceEpoch}.jpg',
          )
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        _showSuccessSnackBar();
        return;
      }

      // LOGIKA DOWNLOAD KHUSUS PLATFORM DEVICE MOBILE (ANDROID/IOS)
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final bytes = base64Decode(widget.imageBase64);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'laporan_fasum_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await Gal.putImage(filePath);
      _showSuccessSnackBar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh gambar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar berhasil diunduh ke perangkat!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.memory(
                base64Decode(widget.imageBase64),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: _isDownloading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'Download ke Perangkat',
                            onPressed: _downloadBase64Image,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
