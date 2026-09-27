// image_viewer.dart — ZaytonaImageViewer
//
// Full-screen pinch-to-zoom image viewer. Built on Flutter's own
// InteractiveViewer — no zoom/lightbox package exists in this app yet.

import 'package:flutter/material.dart';

class ZaytonaImageViewer extends StatelessWidget {
  const ZaytonaImageViewer({super.key, required this.image});

  final ImageProvider image;

  static Future<void> show(BuildContext context, ImageProvider image) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ZaytonaImageViewer(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image(image: image, fit: BoxFit.contain),
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: 8,
            end: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
