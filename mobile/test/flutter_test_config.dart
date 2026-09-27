import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// flutter_test renders text with a fallback test font by default, whose
// line-height metrics differ from the real bundled fonts — a layout test
// can pass here and still overflow on a real device (see the catalog-grid
// overflow bug this caught). Loading the real fonts makes text measurement
// in tests match what actually ships.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() async {
    await _loadFont('MADE Tommy Soft', 'assets/fonts/MADETommySoft.otf');
    await _loadFont('Vazirmatn', 'assets/fonts/Vazirmatn.ttf');
  });
  await testMain();
}

Future<void> _loadFont(String family, String assetPath) async {
  final bytes = await File(assetPath).readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}
