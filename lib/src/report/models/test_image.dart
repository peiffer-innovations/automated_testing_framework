import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// Represents an image from a test.
class TestImage {
  TestImage({
    @required this.image,
  })  : assert(image?.isNotEmpty == true),
        captureTime = DateTime.now().millisecondsSinceEpoch;

  /// The time the image was captured in UTC Millis.
  final int captureTime;

  /// The actual bytes from the image.
  final Uint8List image;

  /// A sha256 hash of the image bytes
  String get hash => sha256.convert(image).toString();
}
