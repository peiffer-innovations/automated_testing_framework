import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// Represents an image from a test.
@immutable
class TestImage {
  TestImage({
    @required this.goldenCompatible,
    @required this.id,
    @required this.image,
  })  : assert(goldenCompatible != null),
        assert(id?.isNotEmpty == true),
        assert(image?.isNotEmpty == true),
        captureTime = DateTime.now().millisecondsSinceEpoch;

  /// The time the image was captured in UTC Millis.
  final int captureTime;

  /// Set to [true] if this image can be saved as a golden image.  Set to
  /// [false] if it contains dynamic data that can't be automatically handled
  /// and is meant to be manually reviewed instead.
  final bool goldenCompatible;

  /// The identifier for the screenshot
  final String id;

  /// The actual bytes from the image.
  final Uint8List image;

  /// A sha256 hash of the image bytes
  String get hash => sha256.convert(image).toString();
}
